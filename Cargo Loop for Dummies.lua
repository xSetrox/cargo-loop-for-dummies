util.require_natives("1663599433")
-- disable idiot proof if you are an idiot or actually know what you are doing and start MB on its own
local idiot_proof = true

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
menu.slider(menu.my_root(), "Sell delay", {"crateselldelay"}, "The delay in MS to sell crates at. The lower, the more chance of the warehouse scaleform freezing up on you. Up to you.", 1000, 10000, 2000, 10, function(delay)
    sell_delay = delay
end)


local money_loop = false
local initial_player_money = 0
menu.toggle(menu.my_root(), "Sell crates loop", {"sellcratesloop"}, "Auto-sells the crates of the CURRENTLY SELECTED WAREHOUSE IN MB.", function(on)
    money_loop = on
    initial_player_money = players.get_money(players.user())
    while true do 
        if not money_loop then 
            break 
        end
        if util.is_session_started() then
            STATS.SET_PACKED_STAT_BOOL_CODE(32359, 1)
            menu.trigger_commands("sellacrate")
        end
        util.yield(sell_delay)
    end
end)

menu.action(menu.my_root(), "Press if stuck", {}, "Press if the warehouse screen/scaleform gets stuck. It will forcequit you to SP, but you at least wont have to restart your game.", function()
    menu.trigger_commands("forcequittosp")
end)

while true do 
    if money_loop then
        util.draw_debug_text("MONEY EARNED: $" .. format_int(players.get_money(players.user()) - initial_player_money))
    end
    util.yield()
end