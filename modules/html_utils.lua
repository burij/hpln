dofile("env.lua")
local M = {}

--------------------------------------------------------------------------------

function M.format(content, tag)
    is_string(content)
    is_string(tag)
    result = string.format(
        "<%s>%s</%s>", tag, content, tag
    )
    return is_string(result)
end

--------------------------------------------------------------------------------

return M