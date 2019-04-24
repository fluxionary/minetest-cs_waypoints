local mod_name = minetest.get_current_modname()

local function log(level, message)
    minetest.log(level, ('[%s] %s'):format(mod_name, message))
end

log('action', 'CSM loading...')

local mod_storage = minetest.get_mod_storage()

local waypoints
if string.find(mod_storage:get_string('waypoints'), 'return') then
    waypoints = minetest.deserialize(mod_storage:get_string('waypoints'))
else
    waypoints = {}
end


local function safe(func)
    -- wrap a function w/ logic to avoid crashing the game
    local f = function(...)
        local status, out = pcall(func, ...)
        if status then
            return out
        else
            log('warning', 'Error (func):  ' .. out)
            return nil
        end
    end
    return f
end


local function round(x)
    -- approved by kahan
    if x % 2 ~= 0.5 then
        return math.floor(x+0.5)
    else
        return x - 0.5
    end
end


local function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0
    return function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
end


local function lc_cmp(a, b)
    return a:lower() < b:lower()
end


local function tostring_point(point)
    return ('%i %i %i'):format(round(point.x), round(point.y), round(point.z))
end


minetest.register_chatcommand('wp_s', {
    params = '<name>',
    description = 'set a waypoint',
    func = safe(function(param)
        waypoints = minetest.deserialize(mod_storage:get_string('waypoints'))
        local point = minetest.localplayer:get_pos()
        waypoints[param] = point
        mod_storage:set_string('waypoints', minetest.serialize(waypoints))

        minetest.display_chat_message(
            ('set waypoint "%s" to "%s"'):format(param, tostring_point(point))
        )
    end),
})


minetest.register_chatcommand('wp_rm', {
    params = '<name>',
    description = 'remove a waypoint',
    func = safe(function(param)
        waypoints = minetest.deserialize(mod_storage:get_string('waypoints'))
        waypoints[param] = nil
        mod_storage:set_string('waypoints', minetest.serialize(waypoints))

        minetest.display_chat_message(
            ('removed waypoint "%s"'):format(param)
        )
    end),
})


minetest.register_chatcommand('wp_ls', {
    params = '',
    description = 'lists waypoints',
    func = safe(function(_)
        for name, point in pairsByKeys(waypoints, lc_cmp) do
            minetest.display_chat_message(
                ('%s -> %s'):format(name, tostring_point(point))
            )
        end
    end),
})


minetest.register_chatcommand('tw', {
    params = '(<playernamename>) <waypoint>',
    description = 'teleport (a player) to a waypoint',
    func = safe(function(param)
        local playername, wpname = string.match(param, '^(%S+)%s+(%S+)$')
        if playername and wpname then
            local waypoint = waypoints[wpname]
            if waypoint ~= nil then
                local args = ('%s %s'):format(playername, tostring_point(point))
                minetest.run_server_chatcommand('teleport', args)
            else
                minetest.display_chat_message(('waypoint "%s" not found.'):format(wpname))
            end
        else
            local wpname = param
            local waypoint = waypoints[wpname]
            if waypoint ~= nil then
                minetest.run_server_chatcommand('teleport', tostring_point(point))
            else
                minetest.display_chat_message(('waypoint "%s" not found.'):format(wpname))
            end
        end

    end),
})


minetest.register_chatcommand('tr', {
    params = '<ELEV> | <PLAYER> | <PLAYER> <ELEV>',
    description = '/teleport (a player) to a random location',
    func = safe(function(param)
        local x = math.random(-30912, 30927)
        local y = math.random(-30912, 30927)
        local z = math.random(-30912, 30927)
        local name = ''

        if string.match(param, '^([%a%d_-]+) (%d+)$') ~= nil then
            name, y = string.match(param, "^([%a%d_-]+) (%d+)$")

        elseif string.match(param, '^([%d-]+)$') then
            y = string.match(param, '^([%d-]+)$')

        elseif string.match(param, '^([%a%d_-]+)$') ~= nil then
            name = string.match(param, '^([%a%d_-]+)$')
        end

        local args = ('%s %s %s %s'):format(name, x, y, z)
        minetest.run_server_chatcommand('teleport', args)
    end),
})


