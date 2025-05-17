{ self, nixpkgs, system, ... }:

with self.packages.${system};


let
    pkgs = import nixpkgs { inherit system; };
    resources = {
        requests.memory = "128Mi";
        requests.cpu = "500m";
        limits.memory = "256Mi";
        limits.cpu = "2000m";
    };
    workloadApi.port = 8082;
    workloadGenerator.port = 8083;
    
    mkNodePort = port: 30000 + (pkgs.lib.mod port 1000);
in

mkCluster [
    (mkDeployment "workload-api" [{
        name = "workload-api";
        image = "ghcr.io/aau-p9s/workload-api:latest";
        env = mkEnv {
            WORKLOAD_ADDR = "0.0.0.0";
            WORKLOAD_PORT = toString workloadApi.port;
        };
        ports = mkSingletonPort workloadApi.port;
        resources = resources;
    }])
    (mkService "workload-api" [{
        protocol = "TCP";
        port = workloadApi.port;
        targetPort = workloadApi.port;
        nodePort = mkNodePort workloadApi.port;
    }])
    (mkDeployment "workload-generator" [{
        name = "workload-generator";
        image = "ghcr.io/aau-p9s/workload-generator:latest";
        env = mkEnv {
            GENERATOR_API_ADDR = "workload-api";
            GENERATOR_API_PORT = toString workloadApi.port;
            GENERATOR_ADDR = "0.0.0.0";
            GENERATOR_PORT = toString workloadGenerator.port;
            GENERATOR_X = "150";
            GENERATOR_Y = "150";
        };
        ports = mkSingletonPort workloadGenerator.port;
        resources = resources;
    }])
    (mkService "workload-generator" [{
        protocol = "TCP";
        port = workloadGenerator.port;
        targetPort = workloadGenerator.port;
        nodePort = mkNodePort workloadGenerator.port;
    }])
]
