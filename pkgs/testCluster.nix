{ self, system, ... }:

with self.packages.${system};

let
    resources = {
        requests.memory = "128Mi";
        requests.cpu = "500m";
        limits.memory = "256Mi";
        limits.cpu = "2000m";
    };
in

mkCluster "autoscaling-cluster" [
    (mkDeployment "workload-api" [{
        name = "workload-api";
        image = "ghcr.io/aau-p9s/workload-api:latest";
        env = mkEnv {
            WORKLOAD_ADDR = "0.0.0.0";
            WORKLOAD_PORT = "8082";
        };
        ports = mkSingletonPort 8082;
        resources = resources;
    }])
    (mkService "workload-api" [{
        protocol = "TCP";
        port = 8082;
        targetPort = 8082;
        nodePort = 30082;
    }])
    (mkDeployment "workload-generator" [{
        name = "workload-generator";
        image = "ghcr.io/aau-p9s/workload-generator:latest";
        env = mkEnv {
            GENERATOR_API_ADDR = "workload-api";
            GENERATOR_API_PORT = "8082";
            GENERATOR_ADDR = "0.0.0.0";
            GENERATOR_PORT = "8083";
            GENERATOR_X = "150";
            GENERATOR_Y = "150";
        };
        ports = mkSingletonPort 8083;
        resources = resources;
    }])
    (mkService "workload-generator" [{
        protocol = "TCP";
        port = 8083;
        targetPort = 8083;
        nodePort = 30083;
    }])
]
