{ config, lib, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
  ];
  system.stateVersion = "24.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot = {
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    initrd = {
        availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
        kernelModules = [ ];
    };

    loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
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
    initialHashedPassword = "$6$dIqurZZDRsFgEUr6$xtuBBYmYpe0es/o9Shc2E9FZBqOpMzBLxgoxdpUYNwQHBKKMrQludQf5hLG1PvuaW6FnobremjKl/8r.R6rC2/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLPYWxCTckCVdDiBpiKWE8omDndrvQhWkscX8uIyd1j openpgp:0xD1E438FC"
    ];
  };

  networking = {
    hostName = "nixos-sandi-N100";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  environment.systemPackages = with pkgs; [
    git nano rxvt_unicode.terminfo
    mackerel-agent
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