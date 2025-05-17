inputs:

name: kubeconfigs:

(inputs.nixpkgs.lib.nixosSystem {
    system = inputs.system;
    modules = [(
        { pkgs, ... }:

        let
            master_ip = "127.0.0.1";
            master_host = "api.kube";
            master_port = 6443;
        in

        {
            users.users.root.password = "1234";
            networking.extraHosts = "${master_ip} ${master_host}";

            services.getty.autologinUser = "root";

            services.kubernetes = {
                roles = ["master" "node"];
                masterAddress = master_host;
                apiserverAddress = "https://${master_host}:${toString master_port}";
                easyCerts = true;
                apiserver = {
                    securePort = master_port;
                    advertiseAddress = master_ip;
                };

                addons.dns.enable = true;
            };

            system.stateVersion = "25.05";

            virtualisation.vmVariant.virtualisation.graphics = false;

            environment.systemPackages = with pkgs; [
                kubernetes
                kubectl
            ];

            systemd.services.setup-kubectl = {
                enable = true;
                serviceConfig.ExecStart = "${pkgs.writeScriptBin "init" ''
                    #!${pkgs.bash}/bin/bash
                    set -e
                    if ! test -f ~/.kube/config; then
                        mkdir -p ~/.kube
                        ln -s /etc/kubernetes/cluster-admin.kubeconfig ~/.kube/config
                    fi
                    # sleeping to let the kubelet start
                    sleep 20
                    ${builtins.concatStringsSep "\n" (map (kubeconfig: 
                        "${pkgs.kubectl}/bin/kubectl --kubeconfig /etc/kubernetes/cluster-admin.kubeconfig apply -f ${pkgs.writeText "kubeconfig.json" (builtins.toJSON kubeconfig)}")
                        kubeconfigs)
                    }
                ''}/bin/init";
                after = ["kubelet.service"];
                wantedBy = ["default.target"];
            };

        }
    )];
}).config.system.build.vm
