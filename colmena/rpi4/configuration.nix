{ lib, pkgs, nixos-hardware, ... }:
{
    imports = [
        nixos-hardware.nixosModules.raspberry-pi-4
        ./hardware-configuration.nix
        ./nginx.nix
        ./ldap.nix
    ];
    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

    hardware = {
        raspberry-pi."4".apply-overlays-dtmerge.enable = true;
        deviceTree =  {
        enable = true;
        filter = "*rpi-4-*.dtb";
        };
    };

    # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
    boot = {
        kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
        kernelModules = [];
        extraModulePackages = [];

        initrd = {
            availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" "uas" ];
            kernelModules = [ ];
        };

        loader = {
            grub.enable = false;
            generic-extlinux-compatible.enable = true;
        };
    };

    networking.hostName = "nixos-sandi-raspi4";

    environment.systemPackages = with pkgs; [
        libraspberrypi
        raspberrypi-eeprom
    ];

    services.openssh = {
        extraConfig = ''
            AllowAgentForwarding yes
            StreamLocalBindUnlink yes
        '';
    };
}
