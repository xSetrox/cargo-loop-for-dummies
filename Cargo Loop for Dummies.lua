if not SCRIPT_MANUAL_START then
    util.stop_script()
end

-- disable idiot proof if you are an idiot or actually know what you are doing and start MB on its own
local idiot_proof = true

-- change this if you know what you are doing and maybe speak a different language 
local your_fucking_language = "en"

util.require_natives("1663599433")
util.ensure_package_is_installed("lua/MusinessBanager")

local function does_path_exist(path)
    return menu.ref_by_path(path):isValid()
end

local function wait_until_path_is_available(path, message)
    while true do
        if not does_path_exist(path) then
            if not SCRIPT_SILENT_START then
                util.toast(message)
            end
        else
            break
        end
        util.yield()
    end
end

local function kill_appsecuroserv()
    util.spoof_script("appsecuroserv", SCRIPT.TERMINATE_THIS_THREAD)
    PLAYER.SET_PLAYER_CONTROL(players.user(), true, 0)
    PAD.ENABLE_ALL_CONTROL_ACTIONS(0)
    PAD.ENABLE_CONTROL_ACTION(2, 1, true)
    PAD.ENABLE_CONTROL_ACTION(2, 2, true)
    PAD.ENABLE_CONTROL_ACTION(2, 187, true)
    PAD.ENABLE_CONTROL_ACTION(2, 188, true)
    PAD.ENABLE_CONTROL_ACTION(2, 189, true)
    PAD.ENABLE_CONTROL_ACTION(2, 190, true)
    PAD.ENABLE_CONTROL_ACTION(2, 199, true)
    PAD.ENABLE_CONTROL_ACTION(2, 200, true)
    ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), false)
end

local main_mb_path = "Stand>Lua Scripts>MusinessBanager"

local relative_paths = {
    lang =                      ">Language",
    special_cargo =             ">Special Cargo",
    selected_whouse =           ">Special Cargo>Warehouse",
    teleport_to_whouse =        ">Special Cargo>Teleport to Warehouse",
    monitor_cargo =             ">Special Cargo>Monitor",
    max_sell_price =            ">Special Cargo>Max Sell Price",
    nobuycd =                   ">Special Cargo>Bypass Buy Mission Cooldown",
    nosellcd =                  ">Special Cargo>Bypass Sell Mission Cooldown",
    acbuy =                     ">Special Cargo>Autocomplete Buy Mission",
    acsell =                    ">Special Cargo>Autocomplete Sell Mission",
    sellcrate =                  ">Special Cargo>Press To Sell A Crate",
    max_crate_sourcing_amount = ">Special Cargo>Max Crate Sourcing Amount",
    minimize_delivery_time =    ">Special Cargo>Minimize Delivery Time",
    find_safer_ways =           ">Find safer ways to make money"
}

local mb_dir = filesystem.scripts_dir() .. 'MusinessBanager.lua'
if not filesystem.exists(mb_dir) and not SCRIPT_SILENT_START then
    util.toast("Install MusinessBanager before using this.")
    util.stop_script()
end

if idiot_proof and not does_path_exist(main_mb_path .. relative_paths.find_safer_ways) then
    menu.trigger_commands("luamusinessbanager")
    wait_until_path_is_available(main_mb_path .. relative_paths.lang, "Waiting for MB to initialize...")
    menu.trigger_commands("mblang " .. your_fucking_language)
    wait_until_path_is_available(main_mb_path .. relative_paths.special_cargo, "Waiting for MB to load your language. If you see a warning, accept it.")
    util.toast("Initialization done.")
elseif idiot_proof and not SCRIPT_SILENT_START then 
    util.toast("MB is already loaded. Nice!")
end

local selected_whouse_ref = menu.ref_by_path(main_mb_path .. relative_paths.selected_whouse)
local tp_to_whouse_ref = menu.ref_by_path(main_mb_path .. relative_paths.teleport_to_whouse)
local sell_a_crate_ref = menu.ref_by_path(main_mb_path .. relative_paths.sellcrate)

local settings_to_apply = {
    ["noidlekick"] = {ref=menu.ref_by_path("Online>Enhancements>Disable Idle/AFK Kick", 38),         state=true},
    ["noidlecam"] = {ref=menu.ref_by_path("Game>Disables>Disable Idle Camera", 38),                 state=true},
    ["monitorcargo"] = {ref=menu.ref_by_path(main_mb_path .. relative_paths.monitor_cargo),            state=true},
    ["maxsellprice"] = {ref=menu.ref_by_path(main_mb_path .. relative_paths.max_sell_price),           state=true},
    ["nobuycd"] = {ref=menu.ref_by_path(main_mb_path .. relative_paths.nobuycd),                  state=true},
    ["nosellcd"] = {ref=menu.ref_by_path(main_mb_path .. relative_paths.nosellcd),                 state=true},
    ["acbuy"] = {ref=menu.ref_by_path(main_mb_path .. relative_paths.acbuy),                    state=true},
    ["acsell"] = {ref=menu.ref_by_path(main_mb_path .. relative_paths.acsell),                   state=true},
    ["max_crate_sourcing_amount"] = {ref=menu.ref_by_path(main_mb_path .. relative_paths.max_crate_sourcing_amount),state=true},
    ["minimize_delivery_time"] = {ref=menu.ref_by_path(main_mb_path .. relative_paths.minimize_delivery_time),   state=true},
}

local my_root = menu.my_root()

local sell_delay = 2000
my_root:slider("Sell delay", {"crateselldelay"}, "The delay in MS to sell crates at.\nThe lower, the more chance of the warehouse scaleform freezing up on you. Up to you.\n1500-2000ms delay recommended based on your network connection", 10, 10000, 2000, 10, function(delay)
    sell_delay = delay
end)
my_root:action("Get crates", {"fillcurrentwhouse"}, "", function()
    if util.is_session_started() then
        menu.set_value(settings_to_apply.max_crate_sourcing_amount.ref, true)
        menu.set_value(settings_to_apply.minimize_delivery_time.ref, true)
        STATS.SET_PACKED_STAT_BOOL_CODE(32359 + menu.get_value(selected_whouse_ref), true, -1)
    end
end)
local appsecuroserv = util.joaat("appsecuroserv")
local money_loop = false
my_root:toggle("Sell crates loop", {"sellcratesloop"}, "Auto-sells the crates of the CURRENTLY SELECTED WAREHOUSE IN MB.", function(on)
    money_loop = on
    while true do 
        if not money_loop then 
            break 
        end
        if util.is_session_started() then
            -- force required settings
            for _, data in pairs(settings_to_apply) do
                assert(data.ref:isValid(), "MusinessBanager is not started")
                if menu.get_value(data.ref) ~= data.state then
                    menu.set_value(data.ref, data.state)
                end
            end
            STATS.SET_PACKED_STAT_BOOL_CODE(32359 + menu.get_value(selected_whouse_ref), true, -1)
            menu.trigger_command(sell_a_crate_ref)
            util.yield(800)
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 238, 1.0)
            local end_time = os.time() + 2
            while SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(appsecuroserv) > 0 and os.time() < end_time do
                util.yield()
            end
            if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(appsecuroserv) > 0 and sell_delay < 1000 then
                kill_appsecuroserv()
            end
            end_time = os.time() + 5
            while NETSHOPPING.NET_GAMESERVER_TRANSACTION_IN_PROGRESS() and os.time() < end_time do
                util.yield()
            end
        end
        util.yield(sell_delay)
    end
end)

my_root:action("Press if stuck", {}, "Press if the warehouse screen/scaleform gets stuck.", function()
    kill_appsecuroserv()
end)

util.keep_running()