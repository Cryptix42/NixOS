;;; Entry point.  Kept separate from the module so the Nix wrapper can
;;; point at a path instead of passing a Scheme expression through
;;; makeWrapper, which does not quote --add-flags values.

(use-modules (guilefetch))

(main (command-line))
