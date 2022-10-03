{ pkgs, lib, config, modulesPath, inputs, ... }:

let
  #my-source = import ./source-code-derivation.nix { inherit pkgs; };
  app = "phpdemo";
  domain = "${app}.example.com";
in {
  services.phpfpm.pools.${app} = {
    user = app;
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
    phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
  };
  
  networking.hostName = "myhost";  
  
  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 22 80 443 ];
  allowedUDPPortRanges = [
    { from = 4000; to = 4007; }
    { from = 8000; to = 8010; }
  ];
};
  
  imports = [ #/etc/nixos/hardware-configuration.nix 
		./sl-graph.nix
   ];
 # ec2.hvm = true;

#environment.systemPackages = with pkgs; [ 
#  vim 
#  curl
#  inetutils 
#  git
#  tcpdump
#  node2nix
#];  

environment.systemPackages = [
    inputs.slgraph.defaultPackage.x86_64-linux
    pkgs.tcpdump
    pkgs.vim
    pkgs.curl
    pkgs.inetutils
    pkgs.git
    pkgs.node2nix
  ]; 
nix = {
  package = pkgs.nixFlakes;
  extraOptions = ''
    experimental-features = nix-command flakes
  '';
};

services.sl-graph.enable = true;
#inputs.slgraph.within.services.sl-graph = {
#    enable = true;
#  };
  services.nginx = {
    enable = true;
    virtualHosts.${domain}.locations."/" = {
#      root = "${inputs.slweb.packages.${pkgs.system}.default}/lib/node_modules/sl-web-config/dist";
      root = inputs.sourcecode; 
   #  root = my-source.source-code;
      extraConfig = ''
        #fastcgi_split_path_info ^(.+\.php)(/.+)$;
        #fastcgi_pass unix:${config.services.phpfpm.pools.${app}.socket};
        #fastcgi_param DOCUMENT_ROOT $realpath_root;
        #fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        #include ${pkgs.nginx}/conf/fastcgi_params;
        #include ${pkgs.nginx}/conf/fastcgi.conf;
        #fastcgi_param     SCRIPT_FILENAME /srv/http/phpdemo.example.com/index.php;
        #fastcgi_param     SCRIPT_NAME          /index.php;
      '';
     };
  };
  users.users.${app} = {
    isSystemUser = true;
    createHome = false;
   # home = my-source.source-code; 
    group  = app;
  };
  users.groups.${app} = {};

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
