
{ pkgs, ... }: {
  xdg.configFile."niri/config.kdl".text = ''
    input { 
      keyboard { 
        xkb {};
        numlock 
      }
      mouse {
        // off
        // natural-scroll
        // accel-speed 0.2
        // accel-profile "flat"
        // scroll-method "no-scroll"
      } 
    }
    output "HDMI-A-1" {
      mode "1920x1080@60"
      scale 1
      transform "normal"
      position x=0 y=0  
    }
    output "DP-1" { 
      mode "2560x1440@144"
      scale 1
      transform "normal" 
      position x=1080 y=0
    }
    layout {
      gaps 4
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
      focus-ring {
        //off
        width 1
        active-color "#ffffff"
        inactive-color "#000000"
      }      
      border {
        off  
        width 4
        active-color "#ffc87f"
        inactive-color "#505050"
        urgent-color "#9b0000"
      }  
      shadow {
        // on
        // draw-behind-window true
        // pixels and match the CSS box-shadow properties.
        softness 30
        spread 5
        offset x=0 y=5
        color "#0007"
      }
       struts {
        // left 64
        // right 64
        // top 64
        // bottom 64
      }
    } 
    window-rule {
      geometry-corner-radius 8 8 0 0
      clip-to-geometry true
    }  
    window-rule {
      match is-focused=false
      background-effect { 
        blur true 
      }
    }
    // Add lines like this to spawn processes at startup.
    // Note that running niri as a session supports xdg-desktop-autostart,
    // which may be more convenient to use.
    // See the binds section below for more spawn examples.
    
    // This line starts waybar, a commonly used bar for Wayland compositors.
    //spawn-at-startup "waybar"
    
    // To run a shell command (with variables, pipes, etc.), use spawn-sh-at-startup:
    spawn-at-startup "noctalia"
    
    hotkey-overlay {
      // Uncomment this line to disable the "Important Hotkeys" pop-up at startup.
      skip-at-startup
    }
    prefer-no-csd
    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
    animations {
      // Uncomment to turn off all animations.
      //off    
      // Slow down all animations by this factor. Values below 1 speed them up instead.
      // slowdown 3.0
    }
    binds {
      Mod+Shift+Slash { show-hotkey-overlay; }
      Mod+Escape hotkey-overlay-title="DMS Lockscreen" { spawn-sh "dms ipc call lock lock"; }
      Mod+T hotkey-overlay-title="Open a Terminal: Ghostty" { spawn-sh "ghostty"; }
      Mod+D hotkey-overlay-title="Run an Application: fuzzel" { spawn "fuzzel"; }
      Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }
      Super+Alt+S allow-when-locked=true hotkey-overlay-title=null { spawn-sh "pkill orca || exec orca"; }
      XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
      XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
      XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
      XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
      XF86AudioPlay        allow-when-locked=true { spawn-sh "playerctl play-pause"; }
      XF86AudioStop        allow-when-locked=true { spawn-sh "playerctl stop"; }
      XF86AudioPrev        allow-when-locked=true { spawn-sh "playerctl previous"; }
      XF86AudioNext        allow-when-locked=true { spawn-sh "playerctl next"; }
      XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
      XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }
      Mod+O repeat=false { toggle-overview; }
      Mod+Q repeat=false { close-window; }
      Mod+Left  { focus-column-left; }
      Mod+Down  { focus-window-down; }
      Mod+Up    { focus-window-up; }
      Mod+Right { focus-column-right; }
      Mod+H     { focus-column-left; }
      Mod+J     { focus-window-down; }
      Mod+K     { focus-window-up; }
      Mod+L     { focus-column-right; }
      Mod+Ctrl+Left  { move-column-left; }
      Mod+Ctrl+Down  { move-window-down; }
      Mod+Ctrl+Up    { move-window-up; }
      Mod+Ctrl+Right { move-column-right; }
      Mod+Ctrl+H     { move-column-left; }
      Mod+Ctrl+J     { move-window-down; }
      Mod+Ctrl+K     { move-window-up; }
      Mod+Ctrl+L     { move-column-right; }
      // Mod+J     { focus-window-or-workspace-down; }
      // Mod+K     { focus-window-or-workspace-up; }
      // Mod+Ctrl+J     { move-window-down-or-to-workspace-down; }
      // Mod+Ctrl+K     { move-window-up-or-to-workspace-up; }
      Mod+Home { focus-column-first; }
      Mod+End  { focus-column-last; }
      Mod+Ctrl+Home { move-column-to-first; }
      Mod+Ctrl+End  { move-column-to-last; }
      Mod+Shift+Left  { focus-monitor-left; }
      Mod+Shift+Down  { focus-monitor-down; }
      Mod+Shift+Up    { focus-monitor-up; }
      Mod+Shift+Right { focus-monitor-right; }
      Mod+Shift+H     { focus-monitor-left; }
      Mod+Shift+J     { focus-monitor-down; }
      Mod+Shift+K     { focus-monitor-up; }
      Mod+Shift+L     { focus-monitor-right; }
      Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
      Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
      Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
      Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
      Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
      Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
      Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
      Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }
      // Mod+Shift+Ctrl+Left  { move-window-to-monitor-left; }
      // ...
      // And you can also move a whole workspace to another monitor:
      // Mod+Shift+Ctrl+Left  { move-workspace-to-monitor-left; }
      // ...
      Mod+Page_Down      { focus-workspace-down; }
      Mod+Page_Up        { focus-workspace-up; }
      Mod+U              { focus-workspace-down; }
      Mod+I              { focus-workspace-up; }
      Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
      Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
      Mod+Ctrl+U         { move-column-to-workspace-down; }
      Mod+Ctrl+I         { move-column-to-workspace-up; }
      // Alternatively, there are commands to move just a single window:
      // Mod+Ctrl+Page_Down { move-window-to-workspace-down; }
      // ...
      Mod+Shift+Page_Down { move-workspace-down; }
      Mod+Shift+Page_Up   { move-workspace-up; }
      Mod+Shift+U         { move-workspace-down; }
      Mod+Shift+I         { move-workspace-up; }
      // You can bind mouse wheel scroll ticks using the following syntax.
      // These binds will change direction based on the natural-scroll setting.
      // To avoid scrolling through workspaces really fast, you can use
      // the cooldown-ms property. The bind will be rate-limited to this value.
      // You can set a cooldown on any bind, but it's most useful for the wheel.
      Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
      Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
      Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
      Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }
      Mod+WheelScrollRight      { focus-column-right; }
      Mod+WheelScrollLeft       { focus-column-left; }
      Mod+Ctrl+WheelScrollRight { move-column-right; }
      Mod+Ctrl+WheelScrollLeft  { move-column-left; }
      // Usually scrolling up and down with Shift in applications results in
      // horizontal scrolling; these binds replicate that.
      Mod+Shift+WheelScrollDown      { focus-column-right; }
      Mod+Shift+WheelScrollUp        { focus-column-left; }
      Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
      Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }
      Mod+Ctrl+1 { move-column-to-workspace 1; }
      Mod+Ctrl+2 { move-column-to-workspace 2; }
      Mod+Ctrl+3 { move-column-to-workspace 3; }
      Mod+Ctrl+4 { move-column-to-workspace 4; }
      Mod+Ctrl+5 { move-column-to-workspace 5; }
      Mod+Ctrl+6 { move-column-to-workspace 6; }
      Mod+Ctrl+7 { move-column-to-workspace 7; }
      Mod+Ctrl+8 { move-column-to-workspace 8; }
      Mod+Ctrl+9 { move-column-to-workspace 9; }
      Mod+BracketLeft  { consume-or-expel-window-left; }
      Mod+BracketRight { consume-or-expel-window-right; }
      Mod+Comma  { consume-window-into-column; }
      Mod+Period { expel-window-from-column; }
      Mod+R { switch-preset-column-width; }
      Mod+Shift+R { switch-preset-window-height; }
      Mod+Ctrl+R { reset-window-height; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+Ctrl+F { expand-column-to-available-width; }
      Mod+C { center-column; }
      Mod+Ctrl+C { center-visible-columns; }
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }
      Mod+V       { toggle-window-floating; }
      Mod+Shift+V { switch-focus-between-floating-and-tiling; }
      Mod+W { toggle-column-tabbed-display; }
      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }  
      Mod+Shift+E { quit; }
      Ctrl+Alt+Delete { quit; }
      Mod+Shift+P { power-off-monitors; }
    }
  '';
}
