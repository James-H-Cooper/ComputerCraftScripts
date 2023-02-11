------------------------------
-- WoolFlowerAutomation.Lua 
-- By James Cooper
-- Automates the dropping of the correct wool for the Botania flower in the correct order
-- Turtle must be placed below a chest which must have wool placed into it from the computer
-- It must also be placed above a chest whch will collect the duplicate wool and return it to the computer 
------------------------------

local INVENTORY_SIZE = 16
local ERROR_INTERVAL = 20
local LOOP_INTERVAL = 5

local WOOL_WHITE = "minecraft:white_wool"
local WOOL_ORANGE = "minecraft:orange_wool"
local WOOL_MAGNETA = "minecraft:magenta_wool"
local WOOL_LIGHT_BLUE = "minecraft:light_blue_wool"
local WOOL_YELLOW = "minecraft:yellow_wool"
local WOOL_LIME = "minecraft:lime_wool"
local WOOL_PINK = "minecraft:pink_wool"
local WOOL_GREY = "minecraft:gray_wool"
local WOOL_LIGHT_GREY = "minecraft:light_gray_wool"
local WOOL_CYAN = "minecraft:cyan_wool"
local WOOL_PURPLE = "minecraft:purple_wool"
local WOOL_BLUE = "minecraft:blue_wool"
local WOOL_BROWN = "minecraft:brown_wool"
local WOOL_GREEN = "minecraft:green_wool"
local WOOL_RED = "minecraft:red_wool"
local WOOL_BLACK = "minecraft:black_wool"

-- Lookup table containing the correct order of wool for the lower
local WOOL_LOOKUP_TABLE = {WOOL_WHITE, WOOL_ORANGE, WOOL_MAGNETA, WOOL_LIGHT_BLUE, WOOL_YELLOW, WOOL_LIME, WOOL_PINK, WOOL_GREY, WOOL_LIGHT_GREY, WOOL_CYAN, WOOL_PURPLE, WOOL_BLUE, WOOL_BROWN, WOOL_GREEN, WOOL_RED, WOOL_BLACK}

-- Iterate through inventory and drop any duplicate stacks of wool so that we have space for more
local function drop_duplicate_wool()
    for i = 1, INVENTORY_SIZE, 1 do
        local current_slot = turtle.getItemDetail(i)
        if current_slot ~= nil then
            for k=1, INVENTORY_SIZE,1 do
                if k ~= i then
                    local test_slot = turtle.getItemDetail(k) 
                    if test_slot~=nil and test_slot.name == current_slot.name then
                        turtle.select(k)
                        turtle.dropDown()
                        print("Dropped duplicate wool: " .. current_slot.name)
                    end
                end
            end            
        end
    end
end 

-- Pick up all itmes from the chest above the computer
local function pick_up_items_from_chest()
    local success = turtle.suckUp()
    while success do
        success = turtle.suckUp()
    end
end

-- Find the next wool in the table and drop it
local function drop_specified_wool(wool_type)
    for i = 1, INVENTORY_SIZE, 1 do
        local item = turtle.getItemDetail(i)
        if item~= nil and item.name == WOOL_LOOKUP_TABLE[wool_type] then
            turtle.select(i)
            turtle.drop(1)
            return true
        end
    end
    drop_duplicate_wool()
    return false
end

-- main logic
local function main()
    local current_wool_type = 1
    pick_up_items_from_chest()

    while true do
        local was_wool_found = drop_specified_wool(current_wool_type) 
        if not was_wool_found then
            print("Missing item: " .. WOOL_LOOKUP_TABLE[current_wool_type] .. " Checking chest every " .. ERROR_INTERVAL .. " seconds")
            pick_up_items_from_chest()
            sleep(ERROR_INTERVAL)
        else
            current_wool_type = current_wool_type + 1
            if current_wool_type > #WOOL_LOOKUP_TABLE then
                current_wool_type = 1
            end
            print("Wool Dropped, dropping more every " .. LOOP_INTERVAL .. " seconds")
            sleep(LOOP_INTERVAL)
        end
    end

end

main()
