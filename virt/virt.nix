{ pkgs, lib, config, modulesPath, inputs, ... }:

let
  #my-source = import ./source-code-derivation.nix { inherit pkgs; };
  app = "phpdemo";
  domain = "${app}.example.com";
in {
  
  networking.hostName = "myvirt";  
  
  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 22 80 443 ];
  allowedUDPPortRanges = [
    { from = 4000; to = 4007; }
    { from = 8000; to = 8010; }
  ];
};
  
  imports = [ ./virt/virt.nix
            ./virt/hardware-configuration.nix 
   ];
services.openssh.enable = true;
services.openssh.permitRootLogin = "yes";
system.stateVersion = "22.05";
}
