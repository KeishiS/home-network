{ config, lib, pkgs, ... }:

{
    imports = [
        ./hardware-configuration.nix
        ./portunus.nix
        ./container.nix
    ];
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    boot = {
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];

        initrd = {
            availableKernelModules = [
                "xhci_pci" "ahci" "nvme" "usb_storage"
                "usbhid" "sd_mod" "sdhci_pci"
            ];
            kernelModules = [ ];
        };

        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };
    };

    networking.hostName = "nixos-sandi-N100";

    services.openssh = {
        extraConfig = ''
            AllowAgentForwarding yes
            StreamLocalBindUnlink yes
        '';
    };

    environment.systemPackages = with pkgs; [
        openssl
    ];
}
