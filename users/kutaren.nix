{ config, inputs, pkgs, ... }:
{
  users.users.kutaren = {
    isNormalUser = true;
    description = "Cameron";
    extraGroups = [ "guixBuild" "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ 

      ## Interpreted programming languages ##    
      python315

      ## GUI Tools ##
      emacs # Extensable text editor + LISP interpreter 
      reaper # Digital audio workstation (nonfree)
      vscodium # General purpose IDE
      foliate # Ebook and PDF reader
      prismlauncher # Minecraft client
      obsidian # Markdown notes app
      inputs.zen-browser.packages.x86_64-linux.default # Visually minimal Firefox browser
      localsend # LAN filesharing
      ghostty # Terminal emulator
      feh # Minimal image viewer
      mpv # Minimal video player
      zathuraPkgs.zathuraWrapper # Minimal document viewer with plugins (PDF, PostScript, DjVu, etc)

      ## TUI and CLI Tools ##
      btop # TUI process monitor
      gdu # TUI disk analyzer
      yazi # TUI file explorer
      superfile # TUI file explorer
      micro-full # TUI multibuffer text editor
      fileshare # CLI LAN file sharing
      eza # text colored alt to ls
      bat # text colored alt to cat
      dsearch # CLI fuzzy find filesystem search  
      fzf # CLI fuzzy find filesystem search
    ];
  };

  services.guix.enable = false;

}
