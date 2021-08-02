------------------------------
-- SimpleMine.Lua 
-- By James Cooper
-- A Script that digs down a specified number of blocks then starts mining in the direction it's facing before returning home. 
-- Will head home if it travels more than MAX_DISTANCE blocks, it's running low on fuel or it's out of space
-- Note that if the turtle leaves a loaded chunk it shuts down and the script will stop running, this may lead to lost turtles
-- For use with a Mining Turtle
------------------------------

-- Constants
local MAX_DISTANCE = 128 -- The maximum distance the turtle will travel before going home
local FUEL_BUFFER = 40 -- A buffer of surplus fuel to always keep, for safety.
local INVENTORY_SIZE = 16
local COAL_TYPE = "minecraft:coal"

-- Get Mining Depth from Arg list
function init()
    if #arg==1 then 
        return tonumber(arg[1])
    else
        return 0 
    end
end

-- Main logic
-- Return a bool telling us whether or not we ended because we were out of space
function main(depth)
    print("Starting mining operation")
    local distanceTravelled = 0
    while (has_fuel(distanceTravelled) and has_space() and distanceTravelled < MAX_DISTANCE) do
        -- TODO:: CHECK FOR GRAVEL/SAND AND MINE ALL OF THAT FIRST SO THAT DISTANCE TRAVELLED IS ACCURATE
        if distanceTravelled < depth then
            mine_down()
        else
            mine_forward()
        end
        distanceTravelled = distanceTravelled + 1
    end
    go_home(distanceTravelled, depth)
    local was_out_of_space = not(has_space())
    deposit_items()
    return was_out_of_space
end

-- Consume all fuel in inventory then check if we have enough fuel to keep going 
function has_fuel(distanceTravelled) 
    --Consume all fuel in inventory first
    for i = 1, INVENTORY_SIZE do
        local item = turtle.getItemDetail(i)
        if item ~= nil then
            if item.name == COAL_TYPE then
                turtle.select(i)
                turtle.refuel()
            end
        end
    end

    if turtle.getFuelLevel() < (distanceTravelled+FUEL_BUFFER) then
        print("Low Fuel")
        return false
    else
        return true
    end
end

-- Do we have any empty slots for items?
function has_space()
    for i = 1, INVENTORY_SIZE do
        local item = turtle.getItemDetail(i)
        if item == nil then
            return true
        end
    end
    print("Out of Space")
    return false
end

-- Mine 1 block downwards
function mine_down()
    turtle.digDown()
    turtle.suckDown()
    turtle.down()
end

-- Mine 1 block forwards
function mine_forward()
    turtle.dig()
    turtle.suck()
    turtle.forward()
end

-- Return to our start position
function go_home(distanceTravelled, depth)
    print("Going Home.")
    turtle.turnRight()
    turtle.turnRight()
    while distanceTravelled > depth do
        turtle.forward()
        distanceTravelled = distanceTravelled - 1
    end
    while distanceTravelled > 0 do
        turtle.up()
        distanceTravelled = distanceTravelled - 1
    end
end

-- Find a chest and deposit all items into it 
function deposit_items()
    print("Depositing items.")
    local found,_ = turtle.inspect()
    local loops = 0
    while not(found) do
        -- We need to be facing the chest to inspect it so try all directions
        turtle.turnRight()
        found,_ = turtle.inspect()
        loops = loops + 1
        if loops > 3 then
            error("Unable to find chest to deposit into, ending early")
        end
    end

   for i = 1, INVENTORY_SIZE do
        turtle.select(i)
        turtle.drop()
    end
    -- Turn back the way we were facing
    for i = 1, loops do
        turtle.turnLeft()
    end

    -- Finally turn again so that when we restart we're going the same way as the first run. 
    turtle.turnRight()
    turtle.turnRight()
end

-- Starting logic/loop -- 
local depth = init()
if depth < 1 then
    print("Invalid parameter, returning early")
    return false
end
main(depth)