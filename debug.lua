dofile("env.lua")
msg("lua documention: https://lua-docs.vercel.app")
ngx = {}
ngx.say = msg

-- debugging script to test/view generated html
msg("output how.lua: ")
dofile("./routes/how.lua")