{ pkgs, lib, config, modulesPath, inputs, ... }:

let
  #my-source = import ./source-code-derivation.nix { inherit pkgs; };
  app = "phpdemo";
  domain = "${app}.example.com";
in {
  
  networking.hostName = "myhost";  
  
  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 22 80 443 ];
  allowedUDPPortRanges = [
    { from = 4000; to = 4007; }
    { from = 8000; to = 8010; }
  ];
};
  
  imports = [ #"${modulesPath}/virtualisation/amazon-image.nix" 
               # /etc/nixos/hardware-configuration.nix 
		./sl-graph.nix
                ./php-fpm.nix
                ./nginx.nix
                ./postgres.nix
   ];
  #ec2.hvm = true;

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

#services.openssh.enable = true;
#services.openssh.permitRootLogin = "yes";
services.sl-graph.enable = true;
#inputs.slgraph.within.services.sl-graph = {
#    enable = true;
#  };
  users.users.${app} = {
    isSystemUser = true;
    createHome = false;
   # home = my-source.source-code; 
    group  = app;
  };
  users.groups.${app} = {};


}
