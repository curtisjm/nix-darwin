{
    description = "Citrus MBP nix-darwin system flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        nix-darwin.url = "github:nix-darwin/nix-darwin/master";
        nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

        nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    };

    outputs =
        inputs@{
        self,
        nix-darwin,
        nixpkgs,
        nix-homebrew,
        }:
        let
            configuration =
                { pkgs, ... }:
                {
                    # List packages installed in system profile. To search by name, run:
                    # $ nix-env -qaP | grep wget
                    environment.systemPackages = [
                        pkgs.neovim
                        pkgs.ffmpeg
                        pkgs.git
                        pkgs.gh
                        pkgs.tmux
                        pkgs.ripgrep
                        pkgs.aerospace
                        pkgs.fd
                        pkgs.fzf
                        pkgs.go
                        pkgs.python3
                        pkgs.ruff
                        pkgs.nil
                        pkgs.cargo
                        pkgs.rustc
                        pkgs.docker
                        pkgs.stow
                    ];

                    system.primaryUser = "curtis";
                    security.pam.services.sudo_local.touchIdAuth = true;
                    system.keyboard = {
                        enableKeyMapping = true;
                        remapCapsLockToEscape = true;
                    };

                    homebrew = {
                        enable = true;
                        brews = [ "node" ];
                        casks = [
                            "arc"
                            "discord"
                            "obsidian"
                            "karabiner-elements"
                            "ghostty"
                            "raycast"
                            "proton-pass"
                        ];
                        taps = [ ];
                        masApps = { };
                        onActivation.cleanup = "zap";
                        onActivation.autoUpdate = true;
                        onActivation.upgrade = true;
                    };

                    system.defaults = {
                        dock.autohide = true;
                        dock.persistent-apps = [ ];
                        dock.tilesize = 50;
                        loginwindow.GuestEnabled = false;
                        NSGlobalDomain.AppleICUForce24HourTime = true;
                        NSGlobalDomain.AppleInterfaceStyle = "Dark";
                        NSGlobalDomain.KeyRepeat = 2;
                        NSGlobalDomain.InitialKeyRepeat = 12;
                        NSGlobalDomain.ApplePressAndHoldEnabled = false;
                        finder.AppleShowAllExtensions = true;
                        CustomUserPreferences = {
                            "com.apple.symbolichotkeys" = {
                                AppleSymbolicHotKeys = {
                                    # Disable 'Cmd + Space' for Spotlight Search
                                    "64" = {
                                        enabled = false;
                                    };
                                };
                            };
                        };
                    };

                    nixpkgs.config.allowUnfree = true;

                    fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

                    # Necessary for using flakes on this system.
                    nix.settings.experimental-features = "nix-command flakes";

                    # Enable alternative shell support in nix-darwin.
                    # programs.fish.enable = true;

                    # Set Git commit hash for darwin-version.
                    system.configurationRevision = self.rev or self.dirtyRev or null;

                    # Used for backwards compatibility, please read the changelog before changing.
                    # $ darwin-rebuild changelog
                    system.stateVersion = 6;

                    # The platform the configuration will be used on.
                    nixpkgs.hostPlatform = "aarch64-darwin";
                };
        in
            {
            # Build darwin flake using:
            # $ darwin-rebuild build --flake .#mbp
            darwinConfigurations."mbp" = nix-darwin.lib.darwinSystem {
                modules = [
                    configuration

                    nix-homebrew.darwinModules.nix-homebrew
                    {
                        nix-homebrew = {
                            # Install Homebrew under the default prefix
                            enable = true;

                            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                            enableRosetta = true;

                            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
                            # mutableTaps = false;

                            # User owning the Homebrew prefix
                            user = "curtis";

                        };
                    }

                ];
            };
        };
}
