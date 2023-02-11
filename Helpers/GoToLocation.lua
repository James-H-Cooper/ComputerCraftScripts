------------------------------
-- GoToLocation.Lua
-- By James Cooper
-- A Script that move the turtle to the specified location
-- This script assumes that the path will not be blocked. It may work its way around simple obstructions but may also get stuck if there is no clear path. 
------------------------------

-- Constants
local TIMEOUT = 5
local INVENTORY_SIZE = 16
local COAL_TYPE = "minecraft:coal"
local args = {...}

-- Get destination co-ordinates from arg list, return 0 if no param provided
function get_args()
    if #args==3 then
        x = tonumber(args[1])
        y = tonumber(args[2])
        z = tonumber(args[3])
        return x,y,z
    else
        return 0 
    end
end

-- Calculate x/z distance from the destination.  
function calculate_distance(is_x, current_location,destination)
    if is_x then
       return math.abs(current_location[1] - destination[1])
    else
        return math.abs(current_location[3] - destination[3])
    end
end

-- If we don't have enough fuel for the distance we're about to move (times two just so that we don't run out. We need to check for more)
function refuel(distance) 
    if turtle.getFuelLevel() ~=  "unlimited" and turtle.getFuelLevel() < (distance*2) then
        print("Low fuel, checking inventory for coal")
        for i = 1, INVENTORY_SIZE do
            local item = turtle.getItemDetail(i)
            if item ~= nil then
                if item.name == COAL_TYPE then
                    turtle.select(i)
                    turtle.refuel()
                end
            end
        end
    end
end

-- Move to either the X or Z co-ordinate
function move_2d(is_x, destination)
    local current_location = {gps.locate(TIMEOUT)}
    local current_distance = calculate_distance(is_x, current_location, destination)
    print("2D Move Distance = " .. current_distance)
    local previous_distance = current_distance
    -- Move to the correct co-ordinate
    while current_distance >= 1 do
        refuel(current_distance)
        turtle.forward()
        current_location = {gps.locate(TIMEOUT)}
        current_distance = calculate_distance(is_x,current_location,destination)
        if current_distance > previous_distance then
            -- Moving the wrong way, turn around
            print("Moved the wrong way")
            turtle.turnRight()
            turtle.turnRight()
        elseif current_distance == previous_distance then
            -- Moving perpendicular, turn right
            print("Moved perpindicular")
            turtle.turnRight()
        end
        previous_distance = current_distance
    end

    turtle.turnRight()
end

-- Move to the Y co-ordinate (directly, will get stuck if there are obstructions)
function move_y(destination)
    local current_location = {gps.locate(TIMEOUT)}
    local current_distance =  math.abs(current_location[2] - destination[2])
    print("Y Move Distance = " .. current_distance)
    local is_moving_up = current_location[2] < destination[2]
    while current_distance >= 1 do
        refuel(current_distance)
        if is_moving_up then
            turtle.up()
        else
            turtle.down()
        end
        current_location = {gps.locate(TIMEOUT)}
        current_distance =  math.abs(current_location[2] - destination[2])
    end
end

-- Go to the specified destination
function go_to(destination)
    print("Moving X")
    move_2d(true,destination)
    print("Moving Z")
    move_2d(false,destination)
    print("Moving Y")
    move_y(destination)
end

-- main logic -- 
local destination = {get_args()}
if destination[2] == nil then
    print("Invalid parameter, returning early")
    print(destination)
    return false
end

go_to(destination)