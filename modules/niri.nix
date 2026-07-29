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
      default = { };
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
