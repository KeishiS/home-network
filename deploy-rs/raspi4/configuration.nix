{ lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];
  system.stateVersion = "24.05";
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

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];

    gc = {
      automatic = true;
      options = "--delete-older-than 1d";
    };
  };

  time.timeZone = "Asia/Tokyo";
  security.sudo.wheelNeedsPassword = false;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "jp106";
  };

  users.users.sandi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    initialHashedPassword = "$6$ME3l.qkmbsXywn7B$3BBbnexK56TKdX2nJ0iIljfpDq8SC7WWobd8TSL67zQufWUFyZNRsAXI/XTbBBbZxCvAnHoiMoDLFEpST7t5d1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLPYWxCTckCVdDiBpiKWE8omDndrvQhWkscX8uIyd1j openpgp:0xD1E438FC"
    ];
  };

  networking = {
    hostName = "nixos-sandi-raspi4";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # console.enable = false;
  environment.systemPackages = with pkgs; [
    git nano rxvt_unicode.terminfo spleen
    libraspberrypi
    raspberrypi-eeprom
    wget curl
    helix
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
    extraConfig = ''
      AllowAgentForwarding yes
      StreamLocalBindUnlink yes
    '';
  };
}