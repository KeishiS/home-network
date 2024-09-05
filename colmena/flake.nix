{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        vscode-server.url = "github:nix-community/nixos-vscode-server";
        ragenix.url = "github:yaxitech/ragenix";

        my-secrets = {
            url = "github:KeishiS/my-secrets/main";
            flake = false;
        };
        home-scripts = {
            url = "github:KeishiS/home-scripts/main";
            flake = false;
        };
    };

    outputs = { nixpkgs, ... }@inputs: {
        colmena = {
            meta = {
                nixpkgs = import nixpkgs {
                    system = "x86_64-linux";
                    overlays = [];
                };
                specialArgs = inputs;
            };

            defaults = {...}: {
                imports = [
                    ./common.nix
                ];
            };

            nixos-sandi-lenovo = {
                deployment = {
                    targetHost = "nixos-sandi-lenovo";
                    targetUser = "sandi";
                    buildOnTarget = true;
                };

                imports = [
                    # ./common.nix
                    ./lenovo/configuration.nix
                ];
            };

            nixos-sandi-N100 = {
                deployment = {
                    targetHost = "nixos-sandi-N100";
                    targetUser = "sandi";
                    buildOnTarget = true;
                };

                imports = [
                    # ./common.nix
                    ./N100/configuration.nix
                ];
            };

            nixos-sandi-rpi4 = {
                deployment = {
                    targetHost = "nixos-sandi-rpi4";
                    targetUser = "sandi";
                    buildOnTarget = true;
                };

                imports = [
                    ./rpi4/configuration.nix
                ];
            };
        };
    };
}
