{
    inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
    outputs = _inputs: let
        system = "x86_64-linux";
        inputs = _inputs // { inherit system; };
    in {
        packages.${system} = {
            testCluster = import ./pkgs/testCluster.nix inputs;
            mkCluster = import ./pkgs/mkCluster.nix inputs;
            mkDeployment = import ./pkgs/mkDeployment.nix inputs;
            mkService = import ./pkgs/mkService.nix inputs;
            mkEnv = import ./pkgs/mkEnv.nix;
            mkSingletonPort = import ./pkgs/mkSingletonPort.nix;
        };
    };
}
