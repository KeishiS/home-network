{ config, lib, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
  ];
  system.stateVersion = "24.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";


  boot = {
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 1d";
    };
    settings.experimental-features = [ "nix-command" "flakes" ];
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
    initialHashedPassword = "$6$ooF34UYoB/VlBMyE$ifIIU4dmFNwgPTsvP5rNQ4LMR/D/rU5XkxvZJa73vi4TbjZSZBGSBitXFlJFugBgVTgH5zJ9rhdpayy4Sgrei/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLPYWxCTckCVdDiBpiKWE8omDndrvQhWkscX8uIyd1j openpgp:0xD1E438FC"
    ];
  };

  networking = {
    hostName = "nixos-sandi-lenovo";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  environment.systemPackages = with pkgs; [
    git nano rxvt_unicode.terminfo spleen
    wget curl
    helix
    deploy-rs colmena
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
