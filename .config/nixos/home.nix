{ pkgs, vars, ... }:
let
  brave = (pkgs.brave.override {
    # NOTE: Enable this bad boy to get rid of weird tab scrolling:
    # brave://flags/#scrollable-tabstrip
    commandLineArgs = [ "--force-device-scale-factor=1.5" ];
  });
in {
  imports = [ ./home-modules/plasma.nix ];

  home.username = "${vars.username}";
  home.homeDirectory = "/home/${vars.username}";

  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.sessionVariables.BROWSER = "brave";

  home.packages = with pkgs; [
    (spotify.override { deviceScaleFactor = 1.5; })
    bat
    # install with `betterdiscord install`
    betterdiscordctl
    blesh
    brave
    cargo
    clang-tools
    delta
    deno
    discord
    emmet-language-server
    fastfetch
    firefox
    gopls
    lua-language-server
    marksman
    nil
    nixfmt-classic
    nodePackages_latest.bash-language-server
    nodePackages_latest.typescript-language-server
    nodejs_21
    prettierd
    python311Packages.pycodestyle
    python311Packages.pyflakes
    python311Packages.python-lsp-server
    python311Packages.yapf
    ripgrep
    rustc
    shellcheck
    shfmt
    stylua
    tree-sitter
    typescript
    unzip
    vscode-langservers-extracted
    wget
    wl-clipboard
    xz
  ];

  xdg.enable = true;

  xdg.configFile = let
    appId = "org.kde.plasma.browser_integration.json";
    source =
      "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/${appId}";
  in {
    "BraveSoftware/Brave-Browser/NativeMessagingHosts/${appId}".source = source;
  };

  xdg.mimeApps = {
    enable = true;
    associations.added = { "application/pdf" = [ "brave-browser.desktop" ]; };
    defaultApplications = {
      "application/pdf" = [ "brave-browser.desktop" ];
      "image/png" = "brave-browser.desktop";
      "image/jpeg" = "brave-browser.desktop";
      "image/gif" = "brave-browser.desktop";
      "image/svg+xml" = "brave-browser.desktop";
      "text/plain" = "brave-browser.desktop";
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
    };
  };

  programs.chromium = {
    enable = true;
    package = brave;
    extensions = [
      { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # Plasma integration
      {
        # Bypass paywalls
        id = "dcpihecpambacapedldabdbpakmachpb";
        updateUrl =
          "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/src/updates/updates.xml";
      }
      {
        # Vimium
        id = "dbepggeogbaibhgnhhndojpepiihcmeb";
        # Mappings:
        # map <c-h> previousTab
        # map <c-H> moveTabLeft
        # map <c-L> moveTabRight
        # map <c-l> nextTab
        # map :q<enter> removeTab
      }
    ];
  };

  programs.bash = {
    enable = true;
    initExtra = (builtins.readFile ./home-modules/bash/bashrc) + ''
      source "${pkgs.git}/share/bash-completion/completions/git"
      __git_complete g __git_main
      __git_complete d __git_main
      __git_complete dots __git_main
    '';
    profileExtra = builtins.readFile ./home-modules/bash/profile;
  };
}
