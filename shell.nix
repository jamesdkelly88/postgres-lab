{ pkgs ? import <nixpkgs> {
    config.allowUnfree = true;
} }:

let
  # On-demand tool to launch pgAdmin inside Brave's borderless App Mode
  pgadminAppCmd = pkgs.writeScriptBin "pgadmin-app" ''
   #!/usr/bin/env bash
    
    # Wrap the entire execution block in standard parentheses () and append &
    # This forks it completely into a detached background subshell, instantly freeing your terminal.
    (
      # 1. Start the pgAdmin background process
      pgadmin4 >/dev/null 2>&1 &
      PGADMIN_PID=$!

      # 2. Wait for the TCP port to open using netcat (built-in)
      while ! nc -z 127.0.0.1 5050 >/dev/null 2>&1; do
          sleep 0.2
      done
      sleep 0.5

      # 3. Mount fonts and open Brave in App Mode
      export FONTCONFIG_FILE=/etc/fonts/fonts.conf
      brave --user-data-dir="$PWD/.brave-profile" --app="http://127.0.0.1:5050" >/dev/null 2>&1 &
      BRAVE_PID=$!

      # 4. Wait for the user to close the Brave window, then kill pgAdmin
      wait $BRAVE_PID 2>/dev/null
      kill $PGADMIN_PID 2>/dev/null
    ) &
    
    echo "pgAdmin app launching in background window..."
  '';

in pkgs.mkShell {
  packages = with pkgs; [
    brave
    go-task
    pgadmin4-desktopmode
    pgadminAppCmd
    pgschema
    postgresql_18
    powershell
    python3
    python3Packages.pyodbc
    sqlfluff
    squawk
    terraform
  ];

  shellHook = ''    
    export PS1="🐘 \[\e[1;34m\][\w]\$ \[\e[0m\]"

    echo "================================================"
    echo " Run 'pgadmin-app' to launch pgAdmin standalone."
    echo "================================================"
  '';
}