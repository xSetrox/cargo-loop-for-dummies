--⠀⣞⢽⢪⢣⢣⢣⢫⡺⡵⣝⡮⣗⢷⢽⢽⢽⣮⡷⡽⣜⣜⢮⢺⣜⢷⢽⢝⡽⣝
--⠸⡸⠜⠕⠕⠁⢁⢇⢏⢽⢺⣪⡳⡝⣎⣏⢯⢞⡿⣟⣷⣳⢯⡷⣽⢽⢯⣳⣫⠇
--⠀⠀⢀⢀⢄⢬⢪⡪⡎⣆⡈⠚⠜⠕⠇⠗⠝⢕⢯⢫⣞⣯⣿⣻⡽⣏⢗⣗⠏⠀
--⠀⠪⡪⡪⣪⢪⢺⢸⢢⢓⢆⢤⢀⠀⠀⠀⠀⠈⢊⢞⡾⣿⡯⣏⢮⠷⠁⠀⠀
--⠀⠀⠀⠈⠊⠆⡃⠕⢕⢇⢇⢇⢇⢇⢏⢎⢎⢆⢄⠀⢑⣽⣿⢝⠲⠉⠀⠀⠀⠀
--⠀⠀⠀⠀⠀⡿⠂⠠⠀⡇⢇⠕⢈⣀⠀⠁⠡⠣⡣⡫⣂⣿⠯⢪⠰⠂⠀⠀⠀⠀
--⠀⠀⠀⠀⡦⡙⡂⢀⢤⢣⠣⡈⣾⡃⠠⠄⠀⡄⢱⣌⣶⢏⢊⠂⠀⠀⠀⠀⠀⠀
--⠀⠀⠀⠀⢝⡲⣜⡮⡏⢎⢌⢂⠙⠢⠐⢀⢘⢵⣽⣿⡿⠁⠁⠀⠀⠀⠀⠀⠀⠀
--⠀⠀⠀⠀⠨⣺⡺⡕⡕⡱⡑⡆⡕⡅⡕⡜⡼⢽⡻⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
--⠀⠀⠀⠀⣼⣳⣫⣾⣵⣗⡵⡱⡡⢣⢑⢕⢜⢕⡝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
--⠀⠀⠀⣴⣿⣾⣿⣿⣿⡿⡽⡑⢌⠪⡢⡣⣣⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
--⠀⠀⠀⡟⡾⣿⢿⢿⢵⣽⣾⣼⣘⢸⢸⣞⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
--⠀⠀⠀⠀⠁⠇⠡⠩⡫⢿⣝⡻⡮⣒⢽⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

util.require_natives("1663599433")
util.ensure_package_is_installed("lua/MusinessBanager")

if not SCRIPT_MANUAL_START then
    util.stop_script()
end

-- change this if you know what you are doing and maybe speak a different language 
local your_fucking_language = "en"


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

if not does_path_exist(main_mb_path .. relative_paths.find_safer_ways) then
    menu.trigger_commands("luamusinessbanager")
    wait_until_path_is_available(main_mb_path .. relative_paths.lang, "Waiting for MB to initialize...")
    menu.trigger_commands("mblang " .. your_fucking_language)
    wait_until_path_is_available(main_mb_path .. relative_paths.special_cargo, "Waiting for MB to load your language. If you see a warning, accept it.")
    util.toast("Initialization done.")
end

local selected_whouse_ref = menu.ref_by_path(main_mb_path .. relative_paths.selected_whouse)
local sell_a_crate_ref = menu.ref_by_path(main_mb_path .. relative_paths.sellcrate)
local freeze_player_ref = menu.ref_by_path('Self>Movement>Freeze')

local function get_current_warehouse()
    return menu.get_value(selected_whouse_ref)
end

-- thank u sapphire
local function get_current_warehouse_type()
    local warehouse = get_current_warehouse()
    if warehouse == -1 then
        return -1
    end
    pluto_switch warehouse do
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 9:
            return 0
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
        case 21:
        case 7:
            return 1
        case 16:
        case 17:
        case 18:
        case 19:
        case 20:
        case 22:
        case 6:
        case 8:
            return 2
    end
    return 3
end

-- also thank u sapphire
local function get_current_warehouse_capacity()
    local warehouse_type = get_current_warehouse_type()
    if warehouse_type == -1 then
        return 0
    end
    pluto_switch warehouse_type do
        case 0:
            return 16
        case 1:
            return 42
        pluto_default:
            return 111
    end
end

local cargo_amt_alloc = memory.alloc_int()
local function get_cargo_amt_for_whouse(whouse)
    STATS.STAT_GET_INT(util.joaat("MP" .. util.get_char_slot() .. "_CONTOTALFORWHOUSE" .. get_current_warehouse()), cargo_amt_alloc, -1)
    return memory.read_int(cargo_amt_alloc)
end

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

local auto_kill_mb = true
my_root:toggle("Auto-Kill MB on session transition", {}, "Auto-kill MB on session transition so you can join your friends without it auto-bailing you.", function(on)
    auto_kill_mb = on
end, true)

util.create_tick_handler(function()
    if util.is_session_transition_active() then
        if auto_kill_mb then 
            menu.trigger_commands("stopluamusinessbanager")
            util.toast("Cargo Loop for Dummies has auto-killed itself and MB due to the session transition to prevent issues.")
            util.stop_script()
        else
            util.toast("Cargo Loop for Dummies has auto-killed itself due to the session transition to prevent issues.")
            util.stop_script()
        end
    end
end)


local sell_delay = 2000
my_root:slider("Sell delay", {"crateselldelay"}, "The ADDITIONAL delay in MS to sell crates at. Modify accordingly based on your connection speed. Note that the script has some hardcoded delays that cannot be changed, so this isn't the only timing factor.", 10, 10000, 2000, 10, function(delay)
    sell_delay = delay
end)


local refill_perc = 50
my_root:slider("Auto-refill cargo percentage", {"autorefillperc"}, "The percentage your warehouse crates should reach before auto-refill is triggered.", 0, 100, 50, 1, function(perc)
    refill_perc = perc
end)

local tryhard_mode = false
my_root:toggle("\"In Stand We Trust\" mode", {"tryhardmode"}, "During the loop, moves you into a place that will maximize TPS, so you can save maybe a few MS on the loop and screenshare shit nobody cares about all day. Fancy!\nThis must be turned on before the sell loop is turned on to take effect.", function(on)
    tryhard_mode = on
end)

local disable_rp_gains = true
my_root:toggle("Disable gaining RP", {}, "For when you are so fucking greedy that the sound of gaining RP makes you whine.", function(on)
    disable_rp_gains = on
end, true)

local appsecuroserv = util.joaat("appsecuroserv")
local money_loop = false
my_root:toggle("Sell loop", {"sellcratesloop"}, "Auto-sells the crates of the CURRENTLY SELECTED WAREHOUSE IN MB.", function(on)
    money_loop = on
    if on then 
        if tryhard_mode then 
            ENTITY.SET_ENTITY_COORDS(players.user_ped(), 0, 0, 2500)
            menu.set_value(freeze_player_ref, true)
        end
    else
        menu.set_value(freeze_player_ref, false)
    end

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

            -- refill handling
            local current_cargo_percentage = (get_cargo_amt_for_whouse(get_current_warehouse()) / get_current_warehouse_capacity()) * 100
            if current_cargo_percentage < refill_perc then
                STATS.SET_PACKED_STAT_BOOL_CODE(32359 + menu.get_value(selected_whouse_ref), true, -1)
            end
            
            -- disable rp gains, thank u sapphire
            if disable_rp_gains then
                memory.write_float(memory.script_global(262145 + 1), 0)
            end
            
            -- selling 
            menu.trigger_command(sell_a_crate_ref)
            util.yield(800)
            -- other stuff / auto-unstuck
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

util.keep_running()