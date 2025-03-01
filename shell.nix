let
	nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.11";
	pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShell {
	packages = with pkgs; [
        openresty
        	(lua5_4.withPackages(ps: with ps; [
			luarocks
		]))
	];

	shellHook = ''
	    APP="hpln"
	    mkdir "/tmp/$APP"
        touch "/tmp/$APP/error.log"
        luarocks install lua-light-wings --tree ./pkgs
        luarocks install md --tree ./pkgs
        alias up='echo "Starting server. Check out http://localhost:8111" && \
            nginx -p . -c nginx.conf -e /tmp/$APP/error.log'
        alias kill='kill "$(cat /tmp/$APP/nginx.pid 2>/dev/null)" \
            2>/dev/null && echo "Server stopped." || \
            echo "Server was not running."'
        alias debug='lua debug.lua'
        alias reload='kill && sleep 2 && up'
        alias deploy='sudo nixos-rebuild switch && \
            kill && sleep 2 && systemctl restart $APP'
	'';
}