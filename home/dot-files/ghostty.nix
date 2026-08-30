{ pkgs, ... }: {
  xdg.configFile."ghostty/config.ghostty".text = ''
    font-family = "JetBrains Mono"
    background-opacity = 1
    background-blur = false
  '';
}
