{ pkgs, ... }: {
  xdg.configFile."ghostty/config.ghostty".text = ''
    font-family = "EnvyCodeR Nerd Font Mono"
    background-opacity = 0.7
    background-blur = true
  '';
}
