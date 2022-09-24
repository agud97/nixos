{ config, lib, pkgs, inputs, ... }:

with lib;
{
options.services.sl-graph.enable =
            lib.mkEnableOption "enable sl-graph";

          config = lib.mkIf config.services.sl-graph.enable {
            systemd.services.sl-graph = {
              wantedBy = [ "multi-user.target" ];
              serviceConfig = {
                Restart = "always";
                ExecStart = "${inputs.slgraph.defaultPackage.x86_64-linux}/bin/sl_graph_service/sl_graph_service";
              };
            };
          };
}
