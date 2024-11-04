{pkgs, ...}:
{
  networking.firewall = {
    allowedTCPPorts = [ 2022 ];
    allowedUDPPorts = [ 2022 ];
  };
}
