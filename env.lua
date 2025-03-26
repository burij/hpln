package.path = "./modules/?.lua;" .. package.path

local core = require("lua-light-wings")
core.globalize(core)