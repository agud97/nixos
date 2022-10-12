{ pkgs, lib, config, modulesPath, inputs, ... }:

let
  app = "phpdemo";
  domain = "${app}.example.com";
in {
  services.nginx = {
    enable = true;
    virtualHosts."_".locations."/api" = {
     extraConfig = '' 
       try_files $uri /index.php$is_args$args; 
     '';
    };
    virtualHosts."_".locations."/" = {
      root = "${inputs.slweb.packages.${pkgs.system}.default}/lib/node_modules/sl-web-config/dist";
     extraConfig = '' 
      index  index.html;
      try_files $uri $uri/ /index.html;
     '';
    };
    virtualHosts."_".locations."~ ^/index\.php(/|$)" = {
#      root = "${inputs.slweb.packages.${pkgs.system}.default}/lib/node_modules/sl-web-config/dist";
      root = inputs.sourcecode; 
   #  root = my-source.source-code;
      extraConfig = ''
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:${config.services.phpfpm.pools.${app}.socket};
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include ${pkgs.nginx}/conf/fastcgi_params;
        include ${pkgs.nginx}/conf/fastcgi.conf;
        #fastcgi_param     SCRIPT_FILENAME /srv/http/phpdemo.example.com/index.php;
        #fastcgi_param     SCRIPT_NAME          /index.php;
      '';
     };
  };

}
