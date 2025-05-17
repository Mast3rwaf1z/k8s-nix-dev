inputs:

name: containerConfig:

{
    apiVersion = "apps/v1";
    kind = "Deployment";
    metadata.name = "${name}-deployment";
    spec = {
        selector.matchLabels.app = name;
        template = {
            metadata.labels.app = name;
            spec.containers = containerConfig;
        };
    };
}
