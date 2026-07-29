# home/modules/niri.nix
{ config, osConfig, lib, ... }:

let
  cfg = config.myHome.niri;

  # --- outputs formatter -----------------------------------------------------------
  renderOutput = name: o:
    let
      lines = lib.filter (x: x != null) [
        (if !o.enable                then "off"                                        else null)
        (if o.mode != null           then ''mode "${o.mode}"''                          else null)
        "scale ${toString o.scale}"
        (if o.transform != null      then ''transform "${o.transform}"''                else null)
        (if o.position != null       then "position x=${toString o.position.x} y=${toString o.position.y}" else null)
        (if o.variableRefreshRate    then "variable-refresh-rate"                       else null)
      ];
      body = lib.concatMapStringsSep "\n" (l: "    ${l}") lines;
    in ''
      output "${name}" {
      ${body}
      }'';

  outputsBlock = lib.concatStringsSep "\n\n" (lib.mapAttrsToList renderOutput cfg.outputs);

  # --- spawn-at-startup formatter ---------------------------------------------------
  renderSpawn = s:
    let args = if lib.isString s then [ s ] else s;
    in "spawn-at-startup " + lib.concatMapStringsSep " " (a: ''"${a}"'') args;
  spawnBlock = lib.concatMapStringsSep "\n" renderSpawn cfg.spawnAtStartup;

  # --- binds and small one liners formatter --------------------------------------------------------------

  bindsBlock = ''
    binds {
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: a: "    ${k} { ${a}; }") cfg.binds)}
    }'';

  prefer-no-csd = if cfg.prefNoCsd then "prefer-no-csd" else "";

  # --- window rules formatter ------------------------------------------------------
  renderMatchVal = v:
    if lib.isBool v then lib.boolToString v
    else if lib.isInt  v then toString v
    else ''"${v}"'';                       # strings quoted; pass regex as r#"..."# yourself

  renderMatchLine = kw: m:
    "${kw} " + lib.concatStringsSep " "
      (lib.mapAttrsToList (k: v: "${k}=${renderMatchVal v}") m);

  renderRule = r:
    let
      bg = r.backgroundEffect;
      bgInner = lib.filter (x: x != null) [
        (if bg.blur       != null then "blur ${lib.boolToString bg.blur}"       else null)
        (if bg.xray       != null then "xray ${lib.boolToString bg.xray}"       else null)
        (if bg.noise      != null then "noise ${toString bg.noise}"            else null)
        (if bg.saturation != null then "saturation ${toString bg.saturation}"   else null)
      ];
      bgBlock = if bgInner == [ ] then [ ]
              else [ "background-effect {" ] ++ map (l: "    ${l}") bgInner ++ [ "}" ];

      body =
           map (renderMatchLine "match")   r.matches
        ++ map (renderMatchLine "exclude") r.excludes
        ++ lib.optional (r.geometryCornerRadius != [ ])
             ("geometry-corner-radius " + lib.concatMapStringsSep " " toString r.geometryCornerRadius)
        ++ lib.optional (r.clipToGeometry != null)
             "clip-to-geometry ${lib.boolToString r.clipToGeometry}"
        ++ lib.optional (r.opacity != null)
             "opacity ${toString r.opacity}"
        ++ bgBlock
        ++ lib.optional (r.extra != "") r.extra;
    in ''
      window-rule {
      ${lib.concatMapStringsSep "\n" (l: "    ${l}") body}
      }'';

  windowRulesBlock = lib.concatMapStringsSep "\n\n" renderRule cfg.windowRules;

  # ========================================== the generated file default ================================================
  configText = ''
    // Managed by home-manager — myHome.niri. Edits here are overwritten.

    input {
        keyboard { xkb {}; }
        touchpad {
            tap
            natural-scroll
        }
        focus-follows-mouse
    }

    ${outputsBlock}

    layout {
        gaps ${toString cfg.gaps}
        center-focused-column "never"
        preset-column-widths {
          proportion 0.25
          proportion 0.33333
          proportion 0.5
          proportion 0.66667
          proportion 0.75
          proportion 1.0
        }
        preset-window-heights {
          proportion 0.33333
          proportion 0.5
          proportion 0.66667
          proportion 1.0
        }
        default-column-width { proportion 0.5; }
        focus-ring { width 2; }
    }

    ${windowRulesBlock}

    hotkey-overlay {
      skip-at-startup
    }
    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
    ${prefer-no-csd}

    ${spawnBlock}

    ${bindsBlock}

    ${cfg.extraConfig}
  '';
# ============================================= generated default file end =====================================================
in {
  options.myHome.niri = {
    enable = lib.mkEnableOption "niri config generation";

    prefNoCsd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Prefer no client side decorations";
    };

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "alacritty";
      description = "Command bound to Mod+Return.";
    };

    launcher = lib.mkOption {
      type = lib.types.str;
      default = "fuzzel";
      description = "Command bound to Mod+D.";
    };

    gaps = lib.mkOption {
      type = lib.types.int;
      default = 16;
    };

    spawnAtStartup = lib.mkOption {
      type = with lib.types; listOf (either str (listOf str));
      default = [ ];
      example = [ "waybar" [ "swaybg" "-i" "/path/bg.png" ] ];
      description = "Each entry is a bare command or a list of [command args...].";
    };

    windowRules = lib.mkOption {
      default = [ ];
      description = "niri window rules, rendered in list order (later rules override earlier).";
      type = lib.types.listOf (lib.types.submodule { options = {
        matches = lib.mkOption {
          type = lib.types.listOf (lib.types.attrsOf (lib.types.oneOf [ lib.types.bool lib.types.int lib.types.str ]));
          default = [ ];
          description = "Each attrset is one `match` directive (keys AND-ed); multiple entries OR together.";
        };
        excludes = lib.mkOption {
          type = lib.types.listOf (lib.types.attrsOf (lib.types.oneOf [ lib.types.bool lib.types.int lib.types.str ]));
          default = [ ];
        };
        geometryCornerRadius = lib.mkOption {
          type = lib.types.listOf lib.types.int;
          default = [ ];
          description = "1 value (all corners) or 4 (top-left top-right bottom-right bottom-left).";
        };
        clipToGeometry = lib.mkOption { type = lib.types.nullOr lib.types.bool; default = null; };
        opacity = lib.mkOption {
          type = with lib.types; nullOr (either int float);
          default = null;
          description = "Window opacity 0.0–1.0. Needed for background blur to be visible.";
        };
        backgroundEffect = lib.mkOption {
          default = { };
          type = lib.types.submodule { options = {
            blur       = lib.mkOption { type = lib.types.nullOr lib.types.bool; default = null; };
            xray       = lib.mkOption { type = lib.types.nullOr lib.types.bool; default = null; };
            noise      = lib.mkOption { type = with lib.types; nullOr (either int float); default = null; };
            saturation = lib.mkOption { type = with lib.types; nullOr (either int float); default = null; };
          }; };
        };
        extra = lib.mkOption { type = lib.types.lines; default = ""; description = "Raw KDL inside this rule."; };
      }; });
    };

    outputs = lib.mkOption {
      default = { };
      description = "Per-connector output config. Omit `mode` to let niri auto-pick the highest advertised mode.";
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkOption { type = lib.types.bool; default = true; };
          mode = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "2560x1440@144";
            description = ''Resolution with optional refresh, e.g. "1920x1080@60". Null → niri picks the highest EDID mode.'';
          };
          scale = lib.mkOption { type = with lib.types; either int float; default = 1.0; };
          position = lib.mkOption {
            default = null;
            type = lib.types.nullOr (lib.types.submodule {
              options = {
                x = lib.mkOption { type = lib.types.int; };
                y = lib.mkOption { type = lib.types.int; };
              };
            });
          };
          transform = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; example = "90"; };
          variableRefreshRate = lib.mkOption { type = lib.types.bool; default = false; };
        };
      });
    };

    binds = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;   # "Mod+Return" -> ''spawn "alacritty"''
      default = {
      "Mod+Shift+Slash"                = ''show-hotkey-overlay'';
      "Mod+T"                          = ''spawn "${cfg.terminal}"'';
      "Mod+D"                          = ''spawn "${cfg.launcher}"'';
      "Mod+O"                          = ''toggle-overview'';
      "Mod+Q"                          = ''close-window'';
      "Mod+Left"                       = ''focus-column-left'';
      "Mod+Down"                       = ''focus-window-down'';
      "Mod+Up"                         = ''focus-window-up'';
      "Mod+Right"                      = ''focus-column-right'';
      "Mod+H"                          = ''focus-column-left'';
      "Mod+J"                          = ''focus-window-down'';
      "Mod+K"                          = ''focus-window-up'';
      "Mod+L"                          = ''focus-column-right'';
      "Mod+Ctrl+Left"                  = ''move-column-left'';
      "Mod+Ctrl+Down"                  = ''move-window-down'';
      "Mod+Ctrl+Up"                    = ''move-window-up'';
      "Mod+Ctrl+Right"                 = ''move-column-right'';
      "Mod+Ctrl+H"                     = ''move-column-left'';
      "Mod+Ctrl+J"                     = ''move-window-down'';
      "Mod+Ctrl+K"                     = ''move-window-up'';
      "Mod+Ctrl+L"                     = ''move-column-right'';
      "Mod+Home"                       = ''focus-column-first'';
      "Mod+End"                        = ''focus-column-last'';
      "Mod+Ctrl+Home"                  = ''move-column-to-first'';
      "Mod+Ctrl+End"                   = ''move-column-to-last'';
      "Mod+Shift+Left"                 = ''focus-monitor-left'';
      "Mod+Shift+Down"                 = ''focus-monitor-down'';
      "Mod+Shift+Up"                   = ''focus-monitor-up'';
      "Mod+Shift+Right"                = ''focus-monitor-right'';
      "Mod+Shift+H"                    = ''focus-monitor-left'';
      "Mod+Shift+J"                    = ''focus-monitor-down'';
      "Mod+Shift+K"                    = ''focus-monitor-up'';
      "Mod+Shift+L"                    = ''focus-monitor-right'';
      "Mod+Shift+Ctrl+Left"            = ''move-column-to-monitor-left'';
      "Mod+Shift+Ctrl+Down"            = ''move-column-to-monitor-down'';
      "Mod+Shift+Ctrl+Up"              = ''move-column-to-monitor-up'';
      "Mod+Shift+Ctrl+Right"           = ''move-column-to-monitor-right'';
      "Mod+Shift+Ctrl+H"               = ''move-column-to-monitor-left'';
      "Mod+Shift+Ctrl+J"               = ''move-column-to-monitor-down'';
      "Mod+Shift+Ctrl+K"               = ''move-column-to-monitor-up'';
      "Mod+Shift+Ctrl+L"               = ''move-column-to-monitor-right'';
      "Mod+Page_Down"                  = ''focus-workspace-down'';
      "Mod+Page_Up"                    = ''focus-workspace-up'';
      "Mod+U"                          = ''focus-workspace-down'';
      "Mod+I"                          = ''focus-workspace-up'';
      "Mod+Ctrl+Page_Down"             = ''move-column-to-workspace-down'';
      "Mod+Ctrl+Page_Up"               = ''move-column-to-workspace-up'';
      "Mod+Ctrl+U"                     = ''move-column-to-workspace-down'';
      "Mod+Ctrl+I"                     = ''move-column-to-workspace-up'';
      "Mod+Shift+Page_Down"            = ''move-workspace-down'';
      "Mod+Shift+Page_Up"              = ''move-workspace-up'';
      "Mod+Shift+U"                    = ''move-workspace-down'';
      "Mod+Shift+I"                    = ''move-workspace-up'';
      "Mod+WheelScrollDown"            = ''focus-workspace-down'';
      "Mod+WheelScrollUp"              = ''focus-workspace-up'';
      "Mod+Ctrl+WheelScrollDown"       = ''move-column-to-workspace-down'';
      "Mod+Ctrl+WheelScrollUp"         = ''move-column-to-workspace-up'';
      "Mod+WheelScrollRight"           = ''focus-column-right'';
      "Mod+WheelScrollLeft"            = ''focus-column-left'';
      "Mod+Ctrl+WheelScrollRight"      = ''move-column-right'';
      "Mod+Ctrl+WheelScrollLeft"       = ''move-column-left'';
      "Mod+Shift+WheelScrollDown"      = ''focus-column-right'';
      "Mod+Shift+WheelScrollUp"        = ''focus-column-left'';
      "Mod+Ctrl+Shift+WheelScrollDown" = ''move-column-right'';
      "Mod+Ctrl+Shift+WheelScrollUp"   = ''move-column-left'';
      "Mod+BracketLeft"                = ''consume-or-expel-window-left'';
      "Mod+BracketRight"               = ''consume-or-expel-window-right'';
      "Mod+Comma"                      = ''consume-window-into-column'';
      "Mod+Period"                     = ''expel-window-from-column'';
      "Mod+R"                          = ''switch-preset-column-width'';
      "Mod+Shift+R"                    = ''switch-preset-window-height'';
      "Mod+Ctrl+R"                     = ''reset-window-height'';
      "Mod+F"                          = ''maximize-column'';
      "Mod+Shift+F"                    = ''fullscreen-window'';
      "Mod+Ctrl+F"                     = ''expand-column-to-available-width'';
      "Mod+C"                          = ''center-column'';
      "Mod+Ctrl+C"                     = ''center-visible-columns'';
      "Mod+V"                          = ''toggle-window-floating'';
      "Mod+Shift+V"                    = ''switch-focus-between-floating-and-tiling'';
      "Mod+W"                          = ''toggle-column-tabbed-display'';
      "Print"                          = ''screenshot'';
      "Ctrl+Print"                     = ''screenshot-screen'';
      "Alt+Print"                      = ''screenshot-window'';
      "Mod+Shift+E"                    = ''quit'';
      "Mod+Shift+P"                    = ''power-off-monitors'';
      };
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Raw KDL appended verbatim — the escape hatch for anything the options don't cover.";
    };
  };

  config = lib.mkIf cfg.enable {

# This block takes the options set in the hostsname.nix defined by host-display.nix module and sets them as the output defaults
    myHome.niri.outputs = lib.mapAttrs (_: m: lib.mkDefault {
      mode = m.mode;
      position = { x = m.x; y = m.y; };
    }) (osConfig.myHost.monitors or { });

# Takes all the text generated above and outputs it to a file
    xdg.configFile."niri/config.kdl".text = configText;
  };
}
