{ pkgs, lib, config, modulesPath, inputs, ... }:

let
  #my-source = import ./source-code-derivation.nix { inherit pkgs; };
  app = "phpdemo";
  domain = "${app}.example.com";
in {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_10;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE nixcloud WITH LOGIN PASSWORD 'nixcloud' CREATEDB;
      CREATE DATABASE nixcloud;
      GRANT ALL PRIVILEGES ON DATABASE nixcloud TO nixcloud;
    '';
  };

}
