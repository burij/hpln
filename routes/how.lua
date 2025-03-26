local need  = require "need"
local core = require("lua-light-wings")
core.globalize(core)
local html_utils = need "html_utils"
local md = need "md"

local content_block = md([[

- [Lua](https://www.lua.org/about.html) is soooo much fun to write and superior to JavaScript
- (Web) development without [Nix](https://nixos.org/) is savage
- [HTMX](https://htmx.org/) is enough interactivity for the most web applications

### Get started
- Clone the [repository](https://github.com/burij/hpln/) and enter the project directory
<code>git clone https://github.com/burij/hpln.git && cd hpln</code>
- Power up your development shell:
<code>nix-shell</code>

...if you're using Nix. If not, you're a savage and on your own.

- Run the server:
<code>up</code>

- Enjoy your [web application](http://localhost:8111).

]])

local html = html_utils.format(content_block, "article")
ngx.say(html)