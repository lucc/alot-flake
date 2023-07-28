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
      alot = prev.alot.overridePythonAttrs (old:
        let version = "${old.version}post-dev+${inputs.alot.shortRev}"; in
        {
          name = "alot-${version}";
          inherit version;
          src = inputs.alot;
          preBuild = ''
            sed -i '/__version__/s/=.*/= "${version}"/' alot/__init__.py
          '';
          nativeCheckInputs = old.nativeCheckInputs ++ [ final.notmuch ];
          disabledTests = old.disabledTests ++ ["test_parsing_notmuch_config_with_non_bool_synchronize_flag_fails"];
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
