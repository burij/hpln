{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "hpln";
  version = "0.1";

  src = ./.;  # The source directory with your app files

  buildInputs = with pkgs; [
    openresty
    (lua5_4.withPackages (ps: with ps; [ luarocks ]))
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r $src/* $out/
    ln -s ${pkgs.openresty}/bin/openresty $out/bin/appserver
    ln -s $out/nginx.conf $out/bin/ngnix.conf

    install -m 755 ./wrappers/server.sh $out/bin/hpln
  '';

  meta = {
    description = "Web application, build with htmx, pico css, lua in nginx and nix.";
    license = pkgs.lib.licenses.mit;
  };
}