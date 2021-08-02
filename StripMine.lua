------------------------------
-- StripMine.Lua 
-- By James Cooper
-- A script to stripmine an area. 
-- Runs SimpleMine.lua at every depth up to the given argument
-- For use with a Mining Turtle
------------------------------


-- Get Mining Depth from Arg list
function init()
    if #arg==1 then 
        return tonumber(arg[1])
    else
        return 0 
    end
end

-- Starting logic/loop -- 
local depth = init()
if depth < 1 then
    print("Invalid parameter, returning early")
    return false
end
for i = 1, depth do
    print("Running mine at level " .. i)
    shell.run("SimpleMine ".. i)
end