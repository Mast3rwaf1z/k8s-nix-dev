# K8S nix development
a simple system to make kubernetes deployments using nix, kinda similar to kubernix while running everything inside a VM, keeping it seperated completely from the host system.

I recommend removing the qcow2 images between runs to keep it completely stateless

Getting started you can just use it directly from the nix command line:
```sh
nix run --impure --expr '(with builtins.getFlake "github:Mast3rwaf1z/k8s-nix-dev").packages.x86_64-linux; mkCluster "" [])'
```

Or making a simple flake:
```nix
{
    inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
    inputs.k8s.url = "github:Mast3rwaf1z/k8s-nix-dev";
    inputs.k8s.inputs.nixpkgs.follows = "nixpkgs";
    outputs = inputs @ { k8s , ... }: with k8s.packages.x86_64-linux; { # load k8s functions into local scope
        packages.x86_64-linux.default = mkCluster [];
    };
}
```
where you will start a shell inside the VM where you can add your own kubernetes YAML to the cluster by traditionally using `kubectl`

while a more complete example could be:
```nix
{
    inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
    inputs.k8s.url = "github:Mast3rwaf1z/k8s-nix-dev";
    inputs.k8s.inputs.nixpkgs.follows = "nixpkgs";
    outputs = inputs @ { k8s , ... }: with k8s.packages.x86_64-linux; { # load k8s functions into local scope
        packages.x86_64-linux.default = mkCluster [
            (mkDeployment "postgres" [{
                name = "postgres";
                image = "postgres:latest";
                env = mkEnv {
                    POSTGRES_PASSWORD = "password";
                    POSTGRES_USER = "root";
                    POSTGRES_DB = "default";
                };
                ports = mkSingletonPort 5432;
            }])
            (mkService "postgres" [{
                protocol = "TCP";
                port = 5432;
                targetPort = 5432;
                nodePort = 30432;
            }])
        ];
    };
}
```
being a little basic, this would start up a cluster with postgres running and accessible on port 30432, and even with the ability to add more services directly with kubectl 
