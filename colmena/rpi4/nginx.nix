{lib, pkgs, ...}:
{
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    fileSystems."/data/www/archlinux" = {
        device = "192.168.10.17:/export/archlinux";
        fsType = "nfs";
    };

    services.nginx = {
        enable = true;
        eventsConfig = ''
            multi_accept on;
            use epoll;
        '';
        /* httpConfig = ''
            keepalive_timeout 65;
            server_tokens off;
            tcp_nopush on;
            tcp_nodelay on;

            server {
                listen 80;
                server_name localhost;
                location /archlinux/ {
                    allow 192.168.10.0/24;
                    deny all;
                    root /data/www/;
                    autoindex on;
                    sendfile on;
                    sendfile_max_chunk 512k;
                    aio threads;
                }
                location / {
                    root /data/www/sandi05.com;
                }
            }
        ''; */
    };
}
