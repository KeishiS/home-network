{config, lib, pkgs, home-scripts, ...}:
let
    pulled_image = pkgs.dockerTools.pullImage {
        imageName = "docker.io/nobuta05/home-scripts";
        imageDigest = "sha256:8bc287fd37013d1d3eef57c1f5629bf83d4af9fc028ce3942d7c42e85ddd99e7";
        sha256 = "83b98765cbe29406708bfb0043b911f8c65381a34fa4a9d2c35ae00f2c276628";
        # `nix-prefetch-docker docker.io/nobuta05/home-scripts latest` でわかったtarファイルのパスを使って
        # `sha256sum <tar file path>`
        finalImageName = "docker.io/nobuta05/home-scripts";
        finalImageTag = "latest";
    };

    archImage = pkgs.dockerTools.buildImage {
        name = "arch_env";
        tag = "latest";
        created = "now";
        fromImage = pulled_image;
        config.Cmd = [ "/usr/bin/bash" ];
    };
in
{
    fileSystems."/nfs/archlinux" = {
        device = "192.168.10.17:/export/archlinux";
        fsType = "nfs";
    };

    virtualisation = {
        oci-containers = {
            backend = "podman";

            containers.pkgEnv = {
                image = "arch_env";
                imageFile = archImage;
                autoStart = false;
                volumes = [
                    "/nfs/archlinux:/nfs/archlinux"
                ];
                entrypoint = "/usr/bin/pkg-cache.sh";
            };

            containers.aurEnv = {
                image = "arch_env";
                imageFile = archImage;
                autoStart = false;
                volumes = [
                    "/nfs/archlinux:/nfs/archlinux"
                ];
                entrypoint = "/usr/bin/aur-cache.sh";
                user = "builder";
            };
        };
    };
    systemd.services."podman-pkgEnv".serviceConfig.Restart = lib.mkForce "no";
    systemd.services."podman-aurEnv".serviceConfig.Restart = lib.mkForce "no";

    systemd.timers."podman-pkgEnv" = {
        description = "Run pkg-cache at 1PM daily";
        enable = true;
        timerConfig = {
            OnCalendar = "*-*-* 13:00:00";
        };
        wantedBy = [
            "timers.target"
        ];
    };

    systemd.timers."podman-aurEnv" = {
        description = "Run aur-cache at 1AM daily";
        enable = true;
        timerConfig = {
            OnCalendar = "*-*-* 01:00:00";
        };
        wantedBy = [
            "timers.target"
        ];
    };
}
