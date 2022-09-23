util.require_natives("1663599433")
-- disable idiot proof if you are an idiot or actually know what you are doing and start MB on its own
local idiot_proof = true
local current_warehouse_index = 0

-- change this if you know what you are doing and maybe speak a different language 
local your_fucking_language = "en"
local main_mb_path = "Stand>Lua Scripts>MusinessBanager"
local relative_lang_path = ">Language"
local relative_special_cargo_path = ">Special Cargo"
local max_crate_sourcing_amount_path = ">Special Cargo>Max Crate Sourcing Amount"
local minimize_delivery_time_path = ">Special Cargo>Minimize Delivery Time"
local find_safer_ways = ">Find safer ways to make money"

local settings_bullshit = {
    noidlekick = "on",
    noidlecam = "on",
    monitorcargo = "on",
    maxsellcargo = "on",
    nobuycdcargo = "on",
    nosellcdcargo = "on",
    autocompletespecialbuy = "on",
    autocompletespecialsell = "on"
}

function does_path_exist(path)
    success, error_msg = pcall(menu.ref_by_path, path)
    return success
end

local mb_dir = filesystem.scripts_dir() .. '\\MusinessBanager.lua'
if not filesystem.exists(mb_dir) and not SCRIPT_SILENT_START then
    util.toast("Install Musiness Banager before using this.")
    util.stop_script()
end

function wait_until_path_is_available(path, message)
    while true do
        if not does_path_exist(path) and not SCRIPT_SILENT_START then util.toast(message) else break end
        util.yield()
    end
end

-- credits to https://stackoverflow.com/questions/10989788/format-integer-in-lua
function format_int(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

if idiot_proof and not does_path_exist(main_mb_path .. find_safer_ways) then
    menu.trigger_commands("luamusinessbanager")
    wait_until_path_is_available(main_mb_path .. relative_lang_path, "Waiting for MB to initialize...")
    menu.trigger_commands("mblang " .. your_fucking_language)
    wait_until_path_is_available(main_mb_path .. relative_special_cargo_path, "Waiting for MB to load your language. If you see a warning, accept it.")
    util.toast("Initialization done.")
else
    if not SCRIPT_SILENT_START then 
        util.toast("MB is already loaded. Nice!")
    end
end

-- force required settings
for k,v in pairs(settings_bullshit) do 
    menu.trigger_commands(k .. " " .. v)
end
menu.set_value(menu.ref_by_path(main_mb_path .. max_crate_sourcing_amount_path), true)
menu.set_value(menu.ref_by_path(main_mb_path .. minimize_delivery_time_path), true)

local sell_delay = 2000
local delay_slider = menu.slider(menu.my_root(), "Sell delay", {"crateselldelay"}, "The delay in MS to sell crates at. The lower, the more chance of the warehouse scaleform freezing up on you. Up to you.", 1000, 10000, 2000, 10, function(delay)
    sell_delay = delay
end)
menu.focus(delay_slider)

local function warehouse_index_to_id(index)
    return (32359 + index)
end

function refill_crates()
    local warehouse_id = warehouse_index_to_id(current_warehouse_index)
    STATS.SET_PACKED_STAT_BOOL_CODE(warehouse_id, true, util.get_char_slot())
end


local money_loop = false
menu.toggle(menu.my_root(), "Sell crates loop", {"sellcratesloop"}, "Auto-sells the crates of the CURRENTLY SELECTED WAREHOUSE IN MB. If it says the warehouse is empty, turn it off and wait a bit, then try again.", function(on)
    money_loop = on
    if on then 
        ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), true)
        while true do 
            if not money_loop then
                break
            end
            ENTITY.SET_ENTITY_COORDS(players.user_ped(), 0, 0, 2000)
            if util.is_session_started() then
                refill_crates()
                menu.trigger_commands("sellacrate")
            else 
                menu.trigger_commands("sellcratesloop off")
            end
            util.yield(sell_delay)
        end
    else
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), 0, 0, 2000)
        ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), false)
    end
end)

local warehouse_picker = menu.ref_by_command_name("selectcargowarehouse")
util.create_tick_handler(function()
    if money_loop then 
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), 0, 0, 2000)
    end
    current_warehouse_index = menu.get_value(warehouse_picker)
end)


menu.action(menu.my_root(), "Press to unstuck", {}, "Press if the warehouse screen/scaleform gets stuck. No longer quits to SP, thank you Sapphire, very cool!", function()
    util.spoof_script("appsecuroserv", SCRIPT.TERMINATE_THIS_THREAD)
    PLAYER.SET_PLAYER_CONTROL(players.user(), true, 0)
    PAD.ENABLE_ALL_CONTROL_ACTIONS(0)
    PAD.ENABLE_ALL_CONTROL_ACTIONS(1)
    PAD.ENABLE_ALL_CONTROL_ACTIONS(2)
    ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), false)
end)

util.keep_running()