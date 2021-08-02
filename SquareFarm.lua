------------------------------
-- SquareFarm.Lua 
-- By James Cooper
-- A Script that Farms wheat seeds in a square
-- Starting position should be on a chest 1 block back from the lower left corner of the farm
-- For use with a Farming Turtle
------------------------------

-- Constants
local SEED_TYPE = "minecraft:wheat_seeds"
local COAL_TYPE = "minecraft:coal"
local CROP_NAME = "minecraft:wheat"
local INVENTORY_SIZE = 16
local LOOP_INTERVAL = 500
local TIMEOUT_INTERVAL = 30

-- Get Square size from arg list, return 0 if no param provided
function init()
    if #arg==1 then 
        return tonumber(arg[1])
    else
        return 0 
    end
end

-- Main logic
function main(square)
    -- Keep looping until we're fully prepared with mats
    while is_prepared(square) == false do
        sleep(TIMEOUT_INTERVAL)    
    end

    farming_loop(square)
    --The logic to come home depends on which side of the farm we end on which is based on if it's an odd or even sided square
    if math.mod(square,2) == 0 then
        come_home_even(square)
    else
        come_home_odd(square)
    end

    dump_inventory(square)
    return true
end

-- Check if we're prepared to start or if we're missing mats
function is_prepared(square)
    local seeds = current_inventory_check()
    if (seeds < square^2) then
        print("Not enough seeds, please fill, checking again in " .. TIMEOUT_INTERVAL .. " Seconds")
        return false
    end
    if (turtle.getFuelLevel() < 2*(square^2)) then
        print("Not enough coal, please fill, checking again in " .. TIMEOUT_INTERVAL .. " Seconds")
        return false
    end

    return true
end

-- Iterate through our inventory, consume any fuel we find and count the number of seeds
-- Returns the number of seeds found 
function current_inventory_check()   
    local seeds = 0
 
    for i = 1, INVENTORY_SIZE do
        local item = turtle.getItemDetail(i)
        if item ~= nil then
            if item.name == SEED_TYPE then
                seeds = seeds + turtle.getItemCount(i)
            else
                if item.name == COAL_TYPE then
                    turtle.select(i)
                    turtle.refuel()
                end
            end
        end
    end

    return seedsCount
end

--Farm the square given
function farming_loop(square)
    turtle.forward()
    process_block()
    local y = 0

    while(y < square) do
        y = y + 1
        local x = 1
        while(x < square) do
            turtle.forward()
            process_block()
            x = x + 1
        end
        if y < square then
            --If we've not finished then we need to turn, direction is dependent on whether this is an odd or even row
            if math.mod(y,2) == 0 then
                turtle.turnLeft()
                turtle.forward()
                process_block()
                turtle.turnLeft()
            else
                turtle.turnRight()
                turtle.forward()
                process_block()
                turtle.turnRight()
            end
        end
    end
end

-- Decide what action needs to be performed on the block we're currently above and perform the appropriate action
function process_block()
    local CROP_MATURE_AGE = 7 -- The age at which a crop is harvestable
    local _, block = turtle.inspectDown()
    --If the crop is found but not mature, don't harvest it yet
    if block.name == CROP_NAME and block.state.age ~= CROP_MATURE_AGE then
        return
    else
        turtle.digDown()
        turtle.suckDown()
        plant_crop()
    end
end

-- Iterate through our inventory until we find a crop, then place it
function plant_crop()
    for i = 1, INVENTORY_SIZE do
        local item = turtle.getItemDetail(i)
        if item.name == SEED_TYPE then
            turtle.select(i)
            turtle.placeDown()
            return
        end
    end
end

-- If we're ending on an odd row we're at the far end of the field and have to travel along both sides of the field
function come_home_odd(square)
    turtle.turnLeft()
    for i = 1, square-1 do
        turtle.forward()
    end
    turtle.turnLeft()
    for i = 1, square do
        turtle.forward()
    end
    turtle.turnLeft()
    turtle.turnLeft()
end

-- If we're ending on an even row we're at the close side of the field and only have to travel along one side
function come_home_even(square)
    turtle.forward()
    turtle.turnRight()
    for i = 1, square-1 do
        turtle.forward()
    end
    turtle.turnRight()
end

--Drop everything in the chest, keeping all our fuel and enough seeds to do another run
function dump_inventory(square)
    local seeds = 0
    for i = 1, INVENTORY_SIZE do
        local item = turtle.getItemDetail(i)
        if item ~= nil then
            if item.name == SEED_TYPE then
                if seeds < (square^2) then
                    seeds = seeds + item.count 
                end
            end
 
            if (item.name ~= SEED_TYPE or seeds < (square^2)) and item.name ~= COAL_TYPE then
                turtle.select(i)
                while turtle.dropDown() == false do
                    print("No room in chest, waiting for room to continue.")
                    sleep(TIMEOUT_INTERVAL)
                end
            end
        end
    end
end

-- Starting logic/loop -- 
local square = init()
if square < 1 then
    print("Invalid parameter, returning early")
    return false
end
print("Starting loop")
while true do
    main(square)
    print("Completed loop. Repeating in " .. LOOP_INTERVAL .. " Seconds. Hold Ctrl+T to terminate program.")
    sleep(LOOP_INTERVAL)
end