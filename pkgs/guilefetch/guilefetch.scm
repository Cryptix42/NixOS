;;; guilefetch --- a small, extensible system information printer
;;;
;;; The program is built from four layers, bottom to top:
;;;
;;;   1. Primitives     -- safe file/command reading, string helpers.
;;;   2. Configuration  -- an option table plus a mutable entry registry.
;;;   3. Entries        -- one procedure per line of output.
;;;   4. Rendering      -- glue the logo and the info block side by side.
;;;
;;; Everything above layer 2 is data, so a config file (see LOAD-CONFIG!)
;;; can add, replace, or reorder entries without touching this source.

(define-module (guilefetch)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 format)
  #:use-module (ice-9 ftw)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:export (main
            ;; The config-file API.
            define-entry register-entry! entry-names
            set-option! get-option
            set-order! set-logo! set-logo-file!
            ;; Useful when writing your own entries.
            run-command read-file-lines first-line
            colorize format-bytes percentage))


;;; ----------------------------------------------------------------------
;;; 1. Primitives
;;; ----------------------------------------------------------------------

(define (safe thunk)
  "Run THUNK, returning #f instead of raising.  Every probe in this file
goes through here: a missing file or absent binary should cost one line of
output, never the whole run."
  (catch #t thunk (lambda _ #f)))

(define (read-file-lines path)
  "Lines of PATH as a list of strings, or '() if unreadable."
  (or (safe (lambda ()
              (call-with-input-file path
                (lambda (port)
                  (let loop ((acc '()))
                    (let ((line (read-line port)))
                      (if (eof-object? line)
                          (reverse acc)
                          (loop (cons line acc)))))))))
      '()))

(define (first-line path)
  "First line of PATH, or #f."
  (let ((lines (read-file-lines path)))
    (and (pair? lines) (car lines))))

(define (run-command program . args)
  "Run PROGRAM with ARGS and return its trimmed stdout, or #f if it could
not be run or exited non-zero.  The child inherits stderr, so anything it
complains about lands on the terminal -- the Nix wrapper is what guarantees
these programs exist on PATH."
  (safe
   (lambda ()
     (let* ((port   (apply open-pipe* OPEN_READ program args))
            (text   (get-string-all port))
            (status (close-pipe port)))
       (and (eqv? 0 (status:exit-val status))
            (string-trim-right text))))))

(define (command-lines program . args)
  "Like RUN-COMMAND but split into non-empty lines."
  (let ((out (apply run-command program args)))
    (if out
        (filter (lambda (s) (not (string-null? s)))
                (string-split out #\newline))
        '())))

(define (whitespace-fields str)
  "Split STR on runs of spaces and tabs."
  (filter (lambda (s) (not (string-null? s)))
          (string-split str (lambda (c) (or (char=? c #\space)
                                            (char=? c #\tab))))))

(define (after-substring str sub)
  "The part of STR following the first occurrence of SUB, or #f."
  (let ((i (string-contains str sub)))
    (and i (substring str (+ i (string-length sub))))))

(define (before-substring str sub)
  "The part of STR preceding the first occurrence of SUB, or STR itself."
  (let ((i (string-contains str sub)))
    (if i (substring str 0 i) str)))

(define (replace-substring str old new)
  "Replace every occurrence of OLD in STR with NEW.  NEW must not contain
OLD, or this loops forever -- fine for the fixed tables used below."
  (let loop ((s str))
    (let ((i (string-contains s old)))
      (if i
          (loop (string-append (substring s 0 i)
                               new
                               (substring s (+ i (string-length old)))))
          s))))

(define (squeeze-spaces str)
  (let loop ((s (string-trim-both str)))
    (if (string-contains s "  ")
        (loop (replace-substring s "  " " "))
        s)))

(define (key-value-line lines key separator)
  "Value of the first line in LINES starting with KEY, split on SEPARATOR."
  (let ((line (find (lambda (l) (string-prefix? key l)) lines)))
    (and line
         (let ((i (string-index line separator)))
           (and i (string-trim-both (substring line (1+ i))))))))

(define (format-bytes n)
  (let loop ((n (exact->inexact n))
             (units '("B" "KiB" "MiB" "GiB" "TiB" "PiB")))
    (if (or (< n 1024.0) (null? (cdr units)))
        (format #f "~,1f ~a" n (car units))
        (loop (/ n 1024.0) (cdr units)))))

(define (percentage part whole)
  (if (zero? whole)
      0
      (inexact->exact (round (* 100 (/ part whole))))))


;;; ----------------------------------------------------------------------
;;; 2. Configuration: options, entry registry, ordering
;;; ----------------------------------------------------------------------

(define %options (make-hash-table))

(define (set-option! key value) (hash-set! %options key value))
(define* (get-option key #:optional (default #f)) (hash-ref %options key default))

;; Defaults.  A config file overrides any of these with SET-OPTION!.
(for-each (lambda (pair) (set-option! (car pair) (cdr pair)))
          '((accent-color    . "1;36")   ; ANSI SGR code for labels/title
            (label-color     . "1")
            (label-width     . 10)       ; 0 disables label padding
            (gap             . 3)        ; spaces between logo and info
            (logo-align      . top)      ; top | center
            (color?          . #t)
            (storage-mounts  . ("/"))
            (separator       . ": ")))

(define (colorize code text)
  (if (and (get-option 'color?) code (not (string-null? code)))
      (string-append "\x1b[" code "m" text "\x1b[0m")
      text))

;; An entry is one line (or a small group of lines) of output.  THUNK is
;; called at render time and may return:
;;
;;   #f or ""            -- entry is skipped entirely
;;   a string            -- rendered as "LABEL: string"
;;   a list of (l . v)   -- rendered as one "l: v" line per pair, which is
;;                          how the storage entry handles several mounts
;;
;; A LABEL of #f prints the value with no label and no separator (used by
;; the title and rule entries).
(define-record-type <entry>
  (make-entry name label thunk)
  entry?
  (name  entry-name)
  (label entry-label)
  (thunk entry-thunk))

(define %entries (make-hash-table))

(define (register-entry! name label thunk)
  (hash-set! %entries name (make-entry name label thunk)))

(define (entry-names)
  (hash-fold (lambda (k v acc) (cons k acc)) '() %entries))

(define-syntax define-entry
  (syntax-rules ()
    ((_ name label body ...)
     (register-entry! 'name label (lambda () body ...)))))

;; The order list is the single source of truth for what gets printed.
;; Unknown names are ignored, so you can leave placeholders in it.
(define %order
  '(title rule hostname os kernel packages cpu gpu ram storage
          shell editor terminal wm gui-shell))

(define (set-order! names) (set! %order names))

;; The logo is just a list of strings; any width, any height.
(define %logo
  '("      ,-----.      "
    "     /  ,-.  \\     "
    "    |  ( λ )  |    "
    "     \\  `-'  /     "
    "      `--,--'      "
    "     _.-'   '-._   "
    "    '-.._____..-'  "))

(define (set-logo! lines) (set! %logo lines))

(define (set-logo-file! path)
  "Use the contents of PATH as the logo.  Any size; blank lines kept."
  (let ((lines (read-file-lines path)))
    (when (pair? lines) (set! %logo lines))))


;;; ----------------------------------------------------------------------
;;; 3. Entries
;;; ----------------------------------------------------------------------

(define (current-user) (safe (lambda () (passwd:name (getpwuid (getuid))))))

(define-entry title #f
  (let ((user (or (current-user) (getenv "USER") "?"))
        (host (or (safe gethostname) "?")))
    (string-append (colorize (get-option 'accent-color) user)
                   "@"
                   (colorize (get-option 'accent-color) host))))

(define-entry rule #f
  ;; Width matches the title, ignoring the colour escapes around it.
  (let* ((user (or (current-user) "?"))
         (host (or (safe gethostname) "?"))
         (n    (+ 1 (string-length user) (string-length host))))
    (make-string n #\-)))

(define-entry hostname "Host"
  (or (safe gethostname) #f))

(define-entry os "OS"
  (let* ((lines  (read-file-lines "/etc/os-release"))
         (pretty (key-value-line lines "PRETTY_NAME=" #\=))
         (name   (and pretty (string-trim-both pretty #\"))))
    (and name
         (string-append name " " (utsname:machine (uname))))))

(define-entry kernel "Kernel"
  (let ((u (uname)))
    (string-append (utsname:sysname u) " " (utsname:release u))))

(define-entry packages "Packages"
  ;; The closure of the current system generation.  This is the same number
  ;; fastfetch reports for NixOS.  It shells out to nix-store and is the
  ;; slowest entry here (tens to hundreds of ms) -- drop it from the order
  ;; list, or swap in a cheaper count, if that bothers you.
  (let ((lines (command-lines "nix-store" "--query" "--requisites"
                              "/run/current-system")))
    (and (pair? lines)
         (format #f "~a (nix-system)" (length lines)))))

(define (cpu-max-ghz)
  (let ((khz (first-line "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq")))
    (and khz
         (safe (lambda () (format #f "~,2f GHz" (/ (string->number khz) 1e6)))))))

(define-entry cpu "CPU"
  (let* ((lines (read-file-lines "/proc/cpuinfo"))
         (model (key-value-line lines "model name" #\:))
         (cores (length (filter (lambda (l) (string-prefix? "processor" l)) lines)))
         (freq  (cpu-max-ghz)))
    (and model
         (let ((name (squeeze-spaces
                      (fold (lambda (junk s) (replace-substring s junk ""))
                            (before-substring model " @ ")
                            '("(R)" "(TM)" " CPU" " Processor")))))
           (string-append name
                          (format #f " (~a)" cores)
                          (if freq (string-append " @ " freq) ""))))))

(define %gpu-name-cleanups
  '(("Corporation "                 . "")
    ("Advanced Micro Devices, Inc. " . "AMD ")
    ("[AMD/ATI] "                   . "")
    ("Integrated Graphics Controller" . "Integrated Graphics")))

(define-entry gpu "GPU"
  ;; lspci is on PATH courtesy of the Nix wrapper.  Reading /sys directly
  ;; would only get us numeric PCI IDs, which still need pci.ids to name.
  (let* ((interesting? (lambda (line)
                         (any (lambda (kind) (string-contains line kind))
                              '("VGA compatible controller"
                                "3D controller"
                                "Display controller"))))
         (clean (lambda (line)
                  (let ((device (after-substring line ": ")))
                    (and device
                         (squeeze-spaces
                          (fold (lambda (pair s)
                                  (replace-substring s (car pair) (cdr pair)))
                                (before-substring device " (rev ")
                                %gpu-name-cleanups))))))
         (gpus (filter-map clean (filter interesting? (command-lines "lspci")))))
    (match-lines "GPU" gpus)))

(define (match-lines label values)
  "Turn a list of VALUES into either one line, or one labelled line each."
  (cond ((null? values) #f)
        ((null? (cdr values)) (car values))
        (else (map (lambda (v i) (cons (format #f "~a ~a" label i) v))
                   values
                   (iota (length values) 1)))))

(define-entry ram "RAM"
  (let* ((lines (read-file-lines "/proc/meminfo"))
         (kb    (lambda (key)
                  (let ((v (key-value-line lines key #\:)))
                    (and v (* 1024 (string->number (car (whitespace-fields v))))))))
         (total (kb "MemTotal:"))
         (avail (kb "MemAvailable:")))
    (and total avail
         (let ((used (- total avail)))
           (format #f "~a / ~a (~a%)"
                   (format-bytes used) (format-bytes total)
                   (percentage used total))))))

(define (disk-usage mount)
  "Used/total bytes for MOUNT as a pair, via POSIX df output."
  (let ((lines (command-lines "df" "-P" "-k" mount)))
    (and (>= (length lines) 2)
         (let ((fields (whitespace-fields (cadr lines))))
           (and (>= (length fields) 3)
                (cons (* 1024 (string->number (list-ref fields 2)))    ; used
                      (* 1024 (string->number (list-ref fields 1))))))))) ; total

(define-entry storage "Disk"
  (filter-map
   (lambda (mount)
     (let ((usage (disk-usage mount)))
       (and usage
            (cons (format #f "Disk (~a)" mount)
                  (format #f "~a / ~a (~a%)"
                          (format-bytes (car usage))
                          (format-bytes (cdr usage))
                          (percentage (car usage) (cdr usage)))))))
   (get-option 'storage-mounts)))

(define-entry shell "Shell"
  (let ((path (or (safe (lambda () (passwd:shell (getpwuid (getuid)))))
                  (getenv "SHELL"))))
    (and path (basename path))))

(define-entry editor "Editor"
  (let ((cmd (or (getenv "VISUAL") (getenv "EDITOR"))))
    ;; $EDITOR may carry flags, e.g. "code --wait".
    (and cmd (basename (car (whitespace-fields cmd))))))

;;; Process inspection, shared by the terminal / WM / GUI shell entries.

(define (process-name pid)
  (first-line (format #f "/proc/~a/comm" pid)))

(define (parent-pid pid)
  (let ((ppid (key-value-line (read-file-lines (format #f "/proc/~a/status" pid))
                              "PPid:" #\:)))
    (and ppid (string->number ppid))))

(define* (find-ancestor match? #:optional (limit 12))
  "Walk up the process tree from this process, returning the first name
satisfying MATCH?, or #f."
  (let loop ((pid (getppid)) (depth 0))
    (and pid (> pid 1) (< depth limit)
         (let ((name (process-name pid)))
           (cond ((and name (match? name)) name)
                 (else (loop (parent-pid pid) (1+ depth))))))))

(define (running-process names)
  "The first of NAMES that is currently running, or #f.  One pass over
/proc; comm is truncated to 15 characters by the kernel, so keep the
entries in NAMES short."
  (let ((live (filter-map (lambda (dir)
                            (and (string->number dir) (process-name dir)))
                          (or (scandir "/proc") '()))))
    (find (lambda (name) (member name live)) names)))

(define %terminals
  '("ghostty" "foot" "alacritty" "kitty" "wezterm" "wezterm-gui" "contour"
    "konsole" "gnome-terminal-" "xfce4-terminal" "st" "urxvt" "xterm"
    "tmux: server" "screen"))

(define-entry terminal "Terminal"
  (or (getenv "TERM_PROGRAM")                       ; Ghostty et al. set this
      (find-ancestor (lambda (name) (member name %terminals)))
      (getenv "TERM")))

(define %window-managers
  '("niri" "sway" "Hyprland" "river" "labwc" "wayfire" "cosmic-comp" "weston"
    "kwin_wayland" "kwin_x11" "gnome-shell" "mutter" "xfwm4"
    "i3" "bspwm" "dwm" "awesome" "xmonad" "openbox"))

(define-entry wm "WM"
  (let ((wm      (or (running-process %window-managers)
                     (getenv "XDG_CURRENT_DESKTOP")
                     (getenv "DESKTOP_SESSION")))
        (session (cond ((getenv "WAYLAND_DISPLAY") "Wayland")
                       ((getenv "DISPLAY") "X11")
                       (else #f))))
    (and wm (if session (format #f "~a (~a)" wm session) wm))))

(define %gui-shells
  '("noctalia-shell" "quickshell" "waybar" "ags" "eww" "ironbar"
    "plasmashell" "gnome-shell" "xfce4-panel" "polybar" "tint2"))

(define-entry gui-shell "GUI Shell"
  (running-process %gui-shells))


;;; ----------------------------------------------------------------------
;;; 4. Rendering
;;; ----------------------------------------------------------------------

(define (visible-length str)
  "Length of STR in printed columns, skipping ANSI CSI sequences.  Assumes
one column per character, which holds for box drawing and Latin text but
not for East Asian glyphs or emoji."
  (let ((len (string-length str)))
    (let loop ((i 0) (n 0))
      (cond
       ((>= i len) n)
       ((char=? (string-ref str i) #\esc)
        (if (and (< (1+ i) len) (char=? (string-ref str (1+ i)) #\[))
            (let skip ((j (+ i 2)))
              (cond ((>= j len) n)
                    ((char<=? #\@ (string-ref str j) #\~) (loop (1+ j) n))
                    (else (skip (1+ j)))))
            (loop (+ i 2) n)))
       (else (loop (1+ i) (1+ n)))))))

(define (pad-right str width)
  (string-append str (make-string (max 0 (- width (visible-length str))) #\space)))

(define (format-info-line label value)
  (if label
      (let* ((width  (get-option 'label-width))
             (padded (if (and width (> width 0))
                         (pad-right label width)
                         label)))
        (string-append (colorize (get-option 'label-color) padded)
                       (get-option 'separator)
                       value))
      value))

(define (entry->lines entry)
  "Render ENTRY into zero or more finished output lines."
  (let ((value (safe (entry-thunk entry))))
    (cond
     ((not value) '())
     ((string? value) (if (string-null? value)
                          '()
                          (list (format-info-line (entry-label entry) value))))
     ((list? value) (map (lambda (pair)
                           (format-info-line (car pair) (cdr pair)))
                         value))
     (else '()))))

(define (info-lines)
  (append-map (lambda (name)
                (let ((entry (hash-ref %entries name)))
                  (if entry (entry->lines entry) '())))
              %order))

(define (align-blocks left right)
  "Pad LEFT and RIGHT to the same number of rows, honouring 'logo-align."
  (let* ((rows (max (length left) (length right)))
         (pad  (lambda (block)
                 (let ((missing (- rows (length block))))
                   (if (and (eq? (get-option 'logo-align) 'center)
                            (> missing 0))
                       (let ((top (quotient missing 2)))
                         (append (make-list top "")
                                 block
                                 (make-list (- missing top) "")))
                       (append block (make-list missing "")))))))
    (values (pad left) (pad right))))

(define (render)
  "The finished output as a list of lines."
  (let* ((logo (if (get-option 'no-logo?) '() %logo))
         (info (info-lines)))
    (if (null? logo)
        info
        (let ((width (fold max 0 (map visible-length logo))))
          (call-with-values (lambda () (align-blocks logo info))
            (lambda (logo info)
              (map (lambda (l r)
                     (string-trim-right
                      (string-append (pad-right l width)
                                     (make-string (get-option 'gap) #\space)
                                     r)))
                   logo info)))))))


;;; ----------------------------------------------------------------------
;;; Config loading and entry point
;;; ----------------------------------------------------------------------

(define (load-config! path)
  "Evaluate PATH inside this module, so it can call SET-OPTION!,
DEFINE-ENTRY, SET-ORDER!, SET-LOGO-FILE! and friends directly.  The config
is code, not data -- a new entry is one DEFINE-ENTRY plus its name in the
order list."
  (when (and path (file-exists? path))
    (save-module-excursion
     (lambda ()
       (set-current-module (resolve-module '(guilefetch)))
       (primitive-load path)))))

(define (default-config-path)
  (or (getenv "GUILEFETCH_CONFIG")
      (string-append (or (getenv "XDG_CONFIG_HOME")
                         (string-append (or (getenv "HOME") ".") "/.config"))
                     "/guilefetch/config.scm")))

(define %usage
  "usage: guilefetch [options]

  --config FILE   load FILE instead of the default config
  --logo FILE     read the ASCII logo from FILE
  --no-logo       print the information block only
  --no-color      disable ANSI colour
  --list          list the names of all registered entries
  --help          show this message
")

(define (main args)
  (let loop ((args (if (pair? args) (cdr args) '()))
             (config (default-config-path))
             (logo #f)
             (action 'print))
    (cond
     ((null? args)
      (load-config! config)
      (when logo (set-logo-file! logo))
      (case action
        ((help) (display %usage))
        ((list) (for-each (lambda (n) (format #t "~a\n" n))
                          (sort (map symbol->string (entry-names)) string<?)))
        (else (for-each (lambda (line) (display line) (newline)) (render)))))
     (else
      (let ((arg (car args)) (rest (cdr args)))
        (cond
          ((string=? arg "--config")
             (if (pair? rest)
               (loop (cdr rest) (car rest) logo action)
               (loop '() config logo 'help)))
          ((string=? arg "--logo")
           (if (pair? rest)
               (loop (cdr rest) config (car rest) action)
               (loop '() config logo 'help)))
         ((string=? arg "--no-logo")
          (set-option! 'no-logo? #t) (loop rest config logo action))
         ((string=? arg "--no-color")
          (set-option! 'color? #f) (loop rest config logo action))
         ((string=? arg "--list")   (loop rest config logo 'list))
         (else                      (loop rest config logo 'help))))))))
