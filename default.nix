{ pkgs ? import <nixpkgs> { } }:

let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.11";
  pkgs = import nixpkgs { config = { }; overlays = [ ]; };

  dependencies = with pkgs; [
    openresty
    nixpkgs-fmt
    (lua5_4.withPackages (ps: with ps; [
      luarocks
    ]))
  ];

  shell = pkgs.mkShell {
    buildInputs = dependencies;
    shellHook = ''
      echo "DON'T PUSH THAT!!!"
      APP="hpln"
      mkdir "/tmp/$APP"
        touch "/tmp/$APP/error.log"
        alias up='echo "Starting server. Check out http://localhost:8111" && \
            nginx -p . -c nginx.conf -e /tmp/$APP/error.log'
        alias kill='kill "$(cat /tmp/$APP/nginx.pid 2>/dev/null)" \
            2>/dev/null && echo "Server stopped." || \
            echo "Server was not running."'
        alias debug='lua debug.lua'
        alias reload='kill && sleep 2 && up'
        alias deploy='cp default.nix \
            /data/$USER/System/hosts/box/webapps/hpln.nix'

      cp ${pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/burij/"
          +"lua-light-wings/refs/heads/main/modules/lua-light-wings.lua";
        sha256 = "sha256-mRD1V0ERFi4gmE/VfAnd1ujoyoxlA0vCj9fJNSCtPkw=";
      }} ./modules/lua-light-wings.lua

      nixpkgs-fmt default.nix
    '';
  };

  package = pkgs.stdenv.mkDerivation {
    pname = "hpln";
    version = "init";
    src = pkgs.fetchFromGitHub {
      owner = "burij";
      repo = "hpln";
      rev = "0.1.1";
      sha256 = "sha256-yIIUXbKmdVXuyYOnQEFz7X7T7w28z8ZYYMJBSuHhCpE=";
    };
    llwCoreLua = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/burij/lua-light-wings/"
        + "refs/tags/v.0.1.0/modules/llw-core.lua";
      sha256 = "sha256-mRD1V0ERFi4gmE/VfAnd1ujoyoxlA0vCj9fJNSCtPkw=";
    };

    buildInputs = dependencies;
    installPhase = ''

      # cp $mdLua $out/md.lua
      # install -m 755 ./wrappers/server.sh $out/bin/hpln

      echo "Listing files in source directory"
      ls -l $src  # Check what files are in the fetched source directory
      mkdir -p $out/bin
      ln -s ${pkgs.openresty}/bin/openresty $out/bin/appserver
      ln -s $out/nginx.conf $out/bin/ngnix.conf
      cp -r $src/* $out/

      # Create the lua binary wrapper with proper environment
      cat > $out/bin/hpln <<EOF
      #!${pkgs.stdenv.shell}

      APP="hpln"
      # Get the absolute path of the script itself
      SCRIPT_PATH="\$(realpath "\$0")"
      # Get the bin directory containing the script
      BIN_DIR="\$(dirname "\$SCRIPT_PATH")"
      # Get the app directory (parent of bin)
      APP_DIR="\$(dirname "\$BIN_DIR")"

      PID_FILE="/tmp/\$APP/nginx.pid"
      ERROR_LOG="/tmp/\$APP/error.log"

      # Ensure required directories exist
      mkdir -p "/tmp/\$APP"
      touch "\$ERROR_LOG"

      # Change to the app directory so Lua can find its modules
      cd "\$APP_DIR" || exit 1

      # Stop any existing server
      if [ -f "\$PID_FILE" ]; then
          PID=\$(cat "\$PID_FILE" 2>/dev/null)
          if [ -n "\$PID" ]; then
              kill "\$PID" 2>/dev/null && echo "Server (PID: \$PID) stopped." \
              || echo "Server was not running."
          else
              echo "PID file is empty."
          fi
      else
          echo "No PID file found."
      fi

      sleep 2

      echo "Server starting. Check http://localhost:8111/"

      # Start the server with absolute paths
      exec "\$APP_DIR/bin/appserver" \\
          -p "\$APP_DIR" \\
          -c "\$APP_DIR/nginx.conf" \\
          -e "\$ERROR_LOG" \\
          "\$@"
      EOF

      chmod +x $out/bin/hpln
    '';
  };
in
{
  package = package;
  shell = shell;
}

