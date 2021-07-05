{
  inputs = {
    nixpkgs.url = "flake:sys";
    flake-utils.url = "github:numtide/flake-utils";
    alot-sources = {
      url = "path:/home/luc/src/alot";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    overlay = final: prev:
      let
        pkgs = nixpkgs.legacyPackages.${prev.system};
      in
      rec {
        alot = pkgs.alot.overridePythonAttrs (oa: {
          version = "dev";
          src = inputs.alot-sources;
          propagatedBuildInputs = oa.propagatedBuildInputs ++ (
            with pkgs.python3Packages; [notmuch2 cffi]
            );
        });
      };

    devShell.${system} = pkgs.mkShell {
      buildInputs = with pkgs; [
        (python3.withPackages(ps: with ps; [
          notmuch2
          cffi
          urwid
          urwidtrees
          twisted
          #python-magic
          magic
          configobj
          gpgme
        ]))
        git
        glibcLocales
        awesome
        dbus
      ];
    };

    #defaultPackage.${system} = pkgs.python.pkgs.buildPythonPackage rec {
    #  pname = "alot";
    #  version = "dev";
    #  src = ./.;
    #  postPatch = ''
    #    substituteInPlace alot/settings/manager.py --replace /usr/share "$out/share"
    #  '';

    #  nativeBuildInputs =  pkgs.sphinx;

    #  propagatedBuildInputs = with pkgs; [
    #    notmuch
    #    urwid
    #    urwidtrees
    #    twisted
    #    python_magic
    #    configobj
    #    service-identity
    #    file
    #    gpgme
    #  ];
    #}
    #;
    #defaultApp.${system} = { type = "app"; program = "${self}/bin/alot"; };
  } //
  flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          overlays = [ self.overlay ];
          inherit system;
        };
      in
      rec {
        packages = { inherit (pkgs.alot); };
        defaultPackage = pkgs.alot;
        apps.alot = flake-utils.lib.mkApp { drv = pkgs.alot; name = "alot"; };
        defaultApp = apps.alot;
      }
  );
}
