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
      APP="hpln"
      mkdir "/tmp/$APP"
        touch "/tmp/$APP/error.log"
        luarocks install md --local
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
          +"lua-light-wings/refs/heads/main/modules/need.lua";
        sha256 = "sha256-w6ie/GiCiMywXgVmDg6WtUsTFa810DTGo1jAHV5pi/A=";
      }} ./need.lua

      cp ${pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/burij/"
          +"lua-light-wings/refs/heads/main/modules/lua-light-wings.lua";
        sha256 = "sha256-mRD1V0ERFi4gmE/VfAnd1ujoyoxlA0vCj9fJNSCtPkw=";
      }} ./modules/lua-light-wings.lua

      nixpkgs-fmt default.nix
    '';
  };

  package = pkgs.stdenv.mkDerivation {
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

      # echo "Listing files in source directory"
      # ls -l $src  # Check what files are in the fetched source directory
      # mkdir -p $out/bin
      # cp -r $src/* $out/
      # cp $llwCoreLua $out/llw-core.lua
      # cp $mdLua $out/md.lua
      # ln -s ${pkgs.openresty}/bin/openresty $out/bin/appserver
      # ln -s $out/nginx.conf $out/bin/ngnix.conf
      # install -m 755 ./wrappers/server.sh $out/bin/hpln

      echo "Listing files in source directory"
      ls -l $src  # Check what files are in the fetched source directory
      mkdir -p $out/bin
      cp -r $src/* $out/
      cp $llwCoreLua $out/llw-core.lua # TODO: Check if can be upgraded to newer version

      # Create the lua binary wrapper with proper environment
      cat > $out/bin/nx-rebuild <<EOF
      #!${pkgs.stdenv.shell}
      export LUA_PATH="\
      # ${pkgs.lua54Packages.inspect}/share/lua/5.4/?.lua;\
      # ${pkgs.lua54Packages.inspect}/share/lua/5.4/?/init.lua;\
      # ${pkgs.lua54Packages.luafilesystem}/share/lua/5.4/?.lua;\
      # ${pkgs.lua54Packages.luafilesystem}/share/lua/5.4/?/init.lua;\
      $out/?.lua;$out/?/init.lua"

      export LUA_CPATH="\
      # ${pkgs.lua54Packages.inspect}/lib/lua/5.4/?.so;\
      # ${pkgs.lua54Packages.luafilesystem}/lib/lua/5.4/?.so;\
      $out/?.so"

      exec ${pkgs.lua5_4}/bin/lua "$out/app.lua"
      EOF

      chmod +x $out/bin/hpln
    '';
  };
in
shell
