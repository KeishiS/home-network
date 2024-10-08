{ config, lib, pkgs, vscode-server, ragenix, ... }:

{
    imports = [
        ./hardware-configuration.nix
        ./nfs.nix
        ./ldap.nix
        vscode-server.nixosModules.default
    ];
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    boot = {
        kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
        kernelModules = [ "kvm-amd" ];
        extraModulePackages = [ ];
        supportedFilesystems = [ "zfs" ];
        zfs.forceImportRoot = false;

        initrd = {
            availableKernelModules = [
              "nvme" "ehci_pci" "xhci_pci" "ahci"
              "usbhid" "usb_storage" "sd_mod"
            ];
            kernelModules = [ ];
        };

        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };
    };

  networking.hostName = "nixos-sandi-lenovo";
  networking.hostId = "938fc0bf"; # for zfs. generated by `head -c 8 /etc/machine-id`

  environment.systemPackages = with pkgs; [
    deploy-rs colmena
    ragenix.packages.${system}.default
    gptfdisk
    zfs
    libarchive # for bsdtar
  ];

  services.openssh = {
    extraConfig = ''
      AllowAgentForwarding yes
      StreamLocalBindUnlink yes
    '';
  };

  services.vscode-server = {
    enable = true;
  };

  /* nixpkgs.config.allowUnfree = true;
  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "/nfs/plex";
  }; */
}
