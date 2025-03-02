{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "hpln";
  version = "init";

  src = ./.;  # The source directory with your app files

  llwCoreLua = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/burij/lua-light-wings/refs/tags/v.0.1.0/modules/llw-core.lua";
    sha256 = "sha256-mRD1V0ERFi4gmE/VfAnd1ujoyoxlA0vCj9fJNSCtPkw=";
  };

  mdLua = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/bakpakin/luamd/refs/heads/master/md.lua";
    sha256 = "sha256-W450OrgcmkP7PhJoKx/hER8AFWvjBu5Ht6erO4uHbYw=";
  };

  buildInputs = with pkgs; [
    openresty
    (lua5_4.withPackages (ps: with ps; [ luarocks ]))
  ];


  installPhase = ''
    mkdir -p $out/bin
    cp -r $src/* $out/
    cp $llwCoreLua $out/llw-core.lua
    cp $mdLua $out/md.lua
    ln -s ${pkgs.openresty}/bin/openresty $out/bin/appserver
    ln -s $out/nginx.conf $out/bin/ngnix.conf
    install -m 755 ./wrappers/server.sh $out/bin/hpln
  '';

  meta = {
    description = "Web application, build with htmx, pico css, lua in nginx and nix.";
    license = pkgs.lib.licenses.mit;
  };
}