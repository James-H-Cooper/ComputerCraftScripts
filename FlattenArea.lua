------------------------------
-- FlattenSquare.Lua 
-- By James Cooper
-- A Script that Flattens an area infront of the turtle
-- Start the turtle in the back left corner of the area to be flattened. 
------------------------------

local INVENTORY_SIZE = 16
local COAL_TYPE = "minecraft:coal"

-- Get Square size from arg list, return 0 if no param provided
function init()
    if #arg==1 then 
        return tonumber(arg[1])
    else
        return 0 
    end
end

-- Main loop
function main(square)
    has_fuel(square)
    local y = 0

    while(y < square) do
        y = y + 1
        local x = 1
        while(x < square) do
            x = x + 1
            clear_current_area()
            turtle.forward()
        end
        if y < square then
            --If we've not finished then we need to turn, direction is dependent on whether this is an odd or even row
            if math.mod(y,2) == 0 then
                turtle.turnLeft()
                clear_current_area()
                turtle.forward()
                turtle.turnLeft()
            else
                turtle.turnRight()
                clear_current_area()
                turtle.forward()
                turtle.turnRight()
            end
        end
    end
end

-- Consume all fuel in inventory then check if we have enough fuel to do the job
function has_fuel(square) 
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

    -- We don't know how many up/down operations we'll need to make so be pessimistic and assume that we need to go up and down once for each block
    if turtle.getFuelLevel() < (3*square^2) then
        error("Not enough fuel for job, cancelling")
    end
end

-- Clear the area directly above and in front of the turtle
function clear_current_area()
    local block_found, _ = turtle.inspect()
    if block_found then
        turtle.dig()
    end

    local loops = 0
    block_found,_ = turtle.inspectUp()
    while block_found do
        turtle.digUp()
        turtle.up()
        block_found,_ = turtle.inspectUp()
        loops = loops + 1
    end

    for i = 1, loops do
        turtle.down()
    end
end

-- Starting logic -- 
local square = init()
if square < 1 then
    print("Invalid parameter, returning early")
    return false
end
main(square)