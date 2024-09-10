{lib, pkgs, ...}:
let
    gen_key_and_cert = { alt ? [] }: (pkgs.runCommand "selfSignedCert" { buildInputs = [pkgs.openssl]; } ''
        mkdir -p $out
        openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:secp521r1 -out $out/key.pem
        openssl req -new -x509 -days 365 -key $out/key.pem -sha512 -out $out/serv.crt -subj "/C=JP/ST=Tokyo/L=Tachikawa/CN=localhost" -addext "subjectAltName=DNS:localhost,IP:192.168.10.25"
    '');
    cert = gen_key_and_cert {};
in
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
        virtualHosts."localhost" = {
            sslCertificate = "${cert}/serv.crt";
            sslCertificateKey = "${cert}/key.pem";
            forceSSL = true;
            root = "/data/www/sandi05.com";
        };
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
