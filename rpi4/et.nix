{pkgs, ...}:
{
  networking.firewall = {
    allowedUDPPortRanges = [
      { from = 60000; to = 60005; }
    ];
  };
  programs.mosh = {
    enable = true;
  };
}
