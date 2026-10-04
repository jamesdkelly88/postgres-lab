{ pkgs ? import <nixpkgs> {
    config.allowUnfree = true;
} }:

pkgs.mkShell {
  packages = with pkgs; [
    go-task
    pgadmin4-desktopmode
    pgschema
    postgresql_18
    powershell
    sqlfluff
    squawk
    terraform
  ];

  shellHook = ''
    # todo
  '';
}