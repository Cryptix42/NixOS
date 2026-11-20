# Noctalia settings, mirrored from the GUI by the dmopp/settings-to-nix plugin
# (/home/cryptix/.local/state/noctalia/settings.toml). Every export overwrites this file.
#
# This file is your backup: keep it somewhere safe, for example in git.
#
# To restore, run this as your user in the directory of this file:
#   $(nix-build --no-out-link ./noctalia-settings.nix)/bin/noctalia-restore-settings
# It replaces settings.toml (the old one is kept as settings.toml.bak-<time>).
# Then restart Noctalia; it installs the plugins listed here again on startup.
{ pkgs ? import <nixpkgs> { } }:
let
  settings = {
    bar.default = {
      background_opacity = 0.69999998435378075;
      center = [
        "workspaces"
        "clock"
        "tray"
        "clipboard"
        "file-search"
        "bar"
        "updates"
        "status"
      ];
      concave_edge_corners = true;
      end = [ "network" "bluetooth" "volume" "brightness" "wallpaper" "wallhaven" ];
      font_family = "0xProto Nerd Font Mono";
      font_weight = 700;
      margin_edge = 0;
      margin_ends = 0;
      padding = 8;
      panel_overlap = 0;
      radius = 7;
      radius_bottom_left = 12;
      radius_bottom_right = 12;
      radius_top_left = 0;
      radius_top_right = 0;
      start = [ "session" "control-center" "launcher" "sysmon" "battery" "widget" ];
    };
    config_version = 19;
    desktop_widgets.enabled = false;
    dock.background_opacity = 0.59999998658895493;
    location.address = "Emigsville, PA";
    lockscreen = {
      blur_intensity = 0.099999997764825821;
      blurred_desktop = true;
      tint_intensity = 0.4999999888241291;
    };
    lockscreen_widgets = {
      enabled = false;
      grid = {
        cell_size = 16;
        major_interval = 4;
        visible = true;
      };
      schema_version = 2;
      widget."lockscreen-login-box@eDP-1" = {
        box_height = 196.0;
        box_width = 720.0;
        cx = 960.0;
        cy = 961.0;
        output = "eDP-1";
        placement_height = 1080.0;
        placement_width = 1920.0;
        rotation = 0.0;
        settings = {
          background_color = "surface_container";
          background_opacity = 0.88;
          background_radius = 12.0;
          center_password_text = false;
          input_opacity = 1.0;
          input_radius = 6.0;
          layout = "regular";
          show_caps_lock = true;
          show_keyboard_layout = true;
          show_login_button = true;
          show_media = true;
          show_session_buttons = true;
          show_unlock_hint = true;
          show_weather = true;
        };
        type = "login_box";
      };
      widget_order = [ "lockscreen-login-box@eDP-1" ];
    };
    notification.background_opacity = 0.59999998658895493;
    osd.background_opacity = 0.59999998658895493;
    plugin_settings = {
      "dmopp/nixos-updates" = {
        flake_dir = "/home/cryptix/NixOS";
        update_command = "nix flake update --flake /home/cryptix/NixOS && sudo nixos-rebuild switch --flake /home/cryptix/NixOS && flatpak update -y";
      };
      "dmopp/settings-to-nix".target_path = "/home/cryptix/NixOS/modules/noctalia-settings.nix";
      "mindnbytes/nix-status".flake_dir = "/home/cryptix/NixOS";
    };
    plugins.enabled = [
      "noctalia/wallhaven"
      "mindnbytes/nix-status"
      "dmopp/settings-to-nix"
      "dmopp/nixos-updates"
      "naijnus/flatpak-bg"
      "nightwatch75/file-search"
      "samuelskovbakke/calculator-plus"
    ];
    shell = {
      niri_overview_type_to_launch_enabled = true;
      panel.transparency_mode = "glass";
      password_style = "random";
      polkit_agent = true;
      settings_show_advanced = true;
    };
    theme = {
      mode = "dark";
      source = "wallpaper";
      templates = {
        builtin_ids = [
          "alacritty"
          "btop"
          "cava"
          "emacs"
          "gtk3"
          "gtk4"
          "ghostty"
          "kitty"
          "niri"
          "qt"
          "umbriel"
        ];
        community_ids = [
          "qutebrowser"
          "zen-browser"
          "discord"
          "libreoffice"
          "micro"
          "obsidian"
          "vscode"
          "prismlauncher"
          "steam"
          "fuzzel"
          "fastfetch"
          "obs"
          "zathura"
          "fzf"
          "tmux"
          "yazi"
        ];
      };
      wallpaper_scheme = "m3-rainbow";
    };
    wallpaper = {
      directory = "~/Pictures/wallpapers";
      fill_color = "on_secondary";
      fill_mode = "span";
      transition_on_startup = true;
    };
    widget = {
      bar.type = "naijnus/flatpak-bg:bar";
      file-search.type = "nightwatch75/file-search:file-search";
      status.type = "mindnbytes/nix-status:status";
      updates.type = "dmopp/nixos-updates:updates";
      wallhaven.type = "noctalia/wallhaven:wallhaven";
      widget.type = "samuelskovbakke/calculator-plus:widget";
    };
  };
  settingsToml = (pkgs.formats.toml { }).generate "noctalia-settings.toml" settings;
in
(pkgs.writeShellScriptBin "noctalia-restore-settings" ''
  set -eu
  PATH=${pkgs.coreutils}/bin:$PATH
  if [ -n "''${NOCTALIA_STATE_HOME:-}" ]; then
    dir="$NOCTALIA_STATE_HOME/noctalia"
  elif [ -n "''${XDG_STATE_HOME:-}" ]; then
    dir="$XDG_STATE_HOME/noctalia"
  else
    dir="$HOME/.local/state/noctalia"
  fi
  mkdir -p "$dir"
  if [ -e "$dir/settings.toml" ]; then
    backup="$dir/settings.toml.bak-$(date +%Y%m%d-%H%M%S)"
    cp "$dir/settings.toml" "$backup"
    echo "Previous settings saved to $backup"
  fi
  tmp=$(mktemp "$dir/.settings.toml.XXXXXX")
  cat ${settingsToml} > "$tmp"
  chmod 644 "$tmp"
  mv "$tmp" "$dir/settings.toml"
  # Skip the first-run wizard; it would write its own choices over the restored ones.
  touch "$dir/.setup-complete"
  echo "Noctalia settings restored to $dir/settings.toml."
  echo "Restart Noctalia so it installs the plugins from the restored settings."
'') // { inherit settings; }
