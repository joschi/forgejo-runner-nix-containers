{
  description = "A Nix container for usage with Forgejo Actions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      formatter = lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      packages = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          defaultContents = [
            pkgs.bash
            pkgs.busybox
            pkgs.cacert
            pkgs.curl
            pkgs.gitMinimal
            pkgs.git-lfs
            pkgs.nodejs_24
            ./files
          ];
        in
        {
          nix = pkgs.dockerTools.buildLayeredImage {
            name = "nix-actions";

            contents = defaultContents ++ [
              pkgs.nix
            ];

            extraCommands = ''
              install -dm 1777 tmp
              install -dm 1777 var/tmp
            '';

            config = {
              Entrypoint = [ "/bin/bash" ];
              Env = [
                "USER=root"
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              ];
              Labels = {
                "org.opencontainers.image.source" = "https://github.com/joschi/forgejo-runner-nix-containers";
                "org.opencontainers.image.description" = "A Nix container for usage with Forgejo Actions";
                "org.opencontainers.image.licenses" = lib.licenses.cc0.spdxId;
              };
            };
          };

          lix = pkgs.dockerTools.buildLayeredImage {
            name = "lix-actions";

            contents = defaultContents ++ [
              pkgs.lix
            ];

            extraCommands = ''
              install -dm 1777 tmp
              install -dm 1777 var/tmp
            '';

            config = {
              Entrypoint = [ "/bin/bash" ];
              Env = [
                "USER=root"
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              ];
              Labels = {
                "org.opencontainers.image.source" = "https://github.com/joschi/forgejo-runner-nix-containers";
                "org.opencontainers.image.description" = "A Lix container for usage with Forgejo Actions";
                "org.opencontainers.image.licenses" = lib.licenses.cc0.spdxId;
              };
            };
          };
        }
      );
    };
}
