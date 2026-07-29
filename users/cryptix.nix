{ config, pkgs, inputs, ... }:

{

  users.users.cryptix = {
    isNormalUser = true;
    description = "Jonathan";
    extraGroups = [ "guixBuild" "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ 
      python315
      llvm
      odin
      emacs
      nim
      sbcl
      chez
      gcc
      clang
      reaper
      miktex
      texstudio
      vscodium
      foliate
      prismlauncher
      obsidian
      krita
      guile
      kdePackages.ark
    ];
  };

  home-manager.users.cryptix = { config, ... }: {
    imports = [
      ../modules/niri.nix
      ../home/dot-files/ghostty.nix
    ];
    myHome.niri = {
      enable = true;
      prefNoCsd = true;
      terminal = "ghostty";
      spawnAtStartup = [ "noctalia" ];
      gaps = 4;
      windowRules = [
        { geometryCornerRadius = [ 8 8 0 0 ]; clipToGeometry = true; }
        {
          matches = [ { is-focused = false; } ];
          excludes = [ { app-id = "zen"; } ];
          backgroundEffect.blur = true;
          opacity = 0.8;
        }
      ];
      binds = {
      "Mod+Shift+Slash"                = ''show-hotkey-overlay'';
      "Mod+T"                          = ''spawn "${config.myHome.niri.terminal}"'';
      "Mod+D"                          = ''spawn "${config.myHome.niri.launcher}"'';
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
    home.stateVersion = "25.11";
  };
}
