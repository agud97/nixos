{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
   # slgraph.url = "path:/etc/nixos/sl-graph";
    slgraph.url  = "github:agud97/sl-graph";
    slweb.url   = "github:agud97/flake-nodejs";
    #slweb.url   =  "path:/root/sl_web-config";
    #slgraph-module.url = "path:/etc/nixos/sl-graph-module";
    flake-utils.url = "github:numtide/flake-utils";
    sourcecode = {
  	url = "github:agud97/sl-php";
  	flake = false;
    };
  };
  outputs = { self, nixpkgs, slweb, slgraph, sourcecode, flake-utils  }@inputs:  
    let 
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {

        nixosConfigurations.myaws = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux"; 
          specialArgs = {
            inherit inputs;
          };
          modules = [ #self.nixosModule
                      ./configuration.nix
                     ${modulesPath}/virtualisation/amazon-image.nix 
                      #({ pkgs, ... }: {
       		#within.services.sl-graph.enable = true;	
	          #    })	
	   ];
	};
      };
     
}
