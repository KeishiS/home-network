{
    description = "deployment for home servers";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        
        deploy-rs = {
            url = "github:serokell/deploy-rs";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.utils.follows = "flake-utils";
        };
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, deploy-rs, nixos-hardware, ... }@inputs: {
        nixosConfigurations = {
            nixos-sandi-N100 = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./N100/configuration.nix
                ];
            };

            nixos-sandi-lenovo = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./lenovo/configuration.nix
                ];
            };

            /* nixos-sandi-raspi4 = nixpkgs.lib.nixosSystem {
                system = "aarch64-linux";
                modules = [
                    nixos-hardware.nixosModules.raspberry-pi-4
                    ./raspi4/configuration.nix
                ];
            }; */
        };

        deploy = {
            sshUser = "sandi";
            user = "root";
            remoteBuild = true;

            nodes = {
                nixos-sandi-N100 = {
                    hostname = "nixos-sandi-N100";
                    profiles.system = {
                        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixos-sandi-N100;
                    };
                };
                
                nixos-sandi-lenovo = {
                    hostname = "nixos-sandi-lenovo";
                    profiles.system = {
                        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixos-sandi-lenovo;
                    };
                };

                /* nixos-sandi-raspi4 = {
                    hostname = "nixos-sandi-raspi4";
                    profiles.system = {
                        path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.nixos-sandi-raspi4;
                    };
                }; */
            };
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
