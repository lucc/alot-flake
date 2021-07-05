{
  inputs.nixpkgs.url = "flake:sys";
  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {
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
      PYTHONPATH = "/home/luc/src/alot";
    };
  };
}
