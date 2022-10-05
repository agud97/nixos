{ pkgs, lib, config, modulesPath, inputs, ... }:

let
  #my-source = import ./source-code-derivation.nix { inherit pkgs; };
  app = "phpdemo";
  domain = "${app}.example.com";
in {
  
  networking.hostName = "myaws";  
  
  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 22 80 443 ];
  allowedUDPPortRanges = [
    { from = 4000; to = 4007; }
    { from = 8000; to = 8010; }
  ];
};
  
  imports = [ #./amazon-image.nix
  "${modulesPath}/virtualisation/amazon-image.nix"
   ];
  ec2.hvm = true;


}
