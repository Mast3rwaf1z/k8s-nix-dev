inputs:

name: ports: 

{
    apiVersion = "v1";
    kind = "Service";
    metadata.name = "${name}-service";
    spec = {
        type = "NodePort";
        selector.app = name;
        ports = ports;
    };
}
