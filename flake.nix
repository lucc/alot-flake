{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";
    alot.url = "github:pazz/alot";
    alot.flake = false;
  };

  outputs = { self, nixpkgs, utils, ... }@inputs:
  {
    overlay = final: prev: {
      alot = prev.alot.overrideAttrs (old: rec {
        pname = "alot";
        name = "alot-${version}";
        version = "dev-${inputs.alot.shortRev}";
        src = inputs.alot;
        preBuild = ''
          sed -i /__version__/s/\'\$/-dev-${inputs.alot.shortRev}\'/ alot/__init__.py
        '';
      });
    };
  }
  //
  utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ self.overlay ];
    };
  in
  {
    defaultApp = utils.lib.mkApp { drv = pkgs.alot; };
    defaultPackage = pkgs.alot;
    packages.alot = pkgs.alot;

    devShell = pkgs.mkShell {
      buildInputs = with pkgs; [
        (python3.withPackages(ps: with ps; [
          notmuch2
          cffi
          urwid
          urwidtrees
          twisted
          #python-magic
          python_magic
          configobj
          gpgme
        ]))
        git
      ];
    };
  });

}
