{config, lib, pkgs, ragenix, my-secrets, ...}:
{
    imports = [
        ragenix.nixosModules.default
    ];
    system.stateVersion = "24.05";

    age.secrets."mackerel_apikey" = {
        file = "${my-secrets}/mackerel_apikey.age";
        mode = "0400";
        owner = "root";
        group = "root";
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
        # `mkpasswd -m sha-512`
        initialHashedPassword = "$6$ooF34UYoB/VlBMyE$ifIIU4dmFNwgPTsvP5rNQ4LMR/D/rU5XkxvZJa73vi4TbjZSZBGSBitXFlJFugBgVTgH5zJ9rhdpayy4Sgrei/";
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLPYWxCTckCVdDiBpiKWE8omDndrvQhWkscX8uIyd1j openpgp:0xD1E438FC"
        ];
    };

    networking = {
        networkmanager.enable = true;
        useDHCP = lib.mkDefault true;
        firewall = {
            enable = true;
            allowedTCPPorts = [ 22 ];
        };
    };

    environment.systemPackages = with pkgs; [
        git nano rxvt_unicode.terminfo rio
        wget curl
        lsof
        julia-bin gcc lapack
        helix
        mackerel-agent
        python3
        nfs-utils
    ];
    environment.variables.EDITOR = "hx";

    programs.nano = {
        nanorc = ''
            set softwrap
            set tabsize 4
            set tabstospaces
            set linenumbers
        '';
    };

    programs.starship.enable = true;
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
        settings.PasswordAuthentication = lib.mkDefault false;
    };

    services.mackerel-agent = {
        apiKeyFile = config.age.secrets."mackerel_apikey".path;
        enable = true;
        runAsRoot = true;
    };
}
