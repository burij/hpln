local need = require "need"
local core = need "lua-light-wings"
core.globalize(core)
msg("lua documention: https://lua-docs.vercel.app")
ngx = {}
ngx.say = msg

-- debugging script to test/view generated html
msg("output how.lua: ")
dofile("./routes/how.lua")