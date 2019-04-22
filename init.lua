minetest.log('action', '[cs_waypoints] CSM loading...')

local mod_storage = minetest.get_mod_storage()

local waypoints
if string.find(mod_storage:get_string("waypoints"), "return") then
    waypoints = minetest.deserialize(mod_storage:get_string("waypoints"))
else
    waypoints = {}
end


function safe(func)
    -- run a function without crashing the game.
    local f = function(...)
        local status, out = pcall(func, ...)
        if status then
            return out
        else
            minetest.debug("Error (func):  " .. out)
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
    for n in pairs(t) do table.insert(a, n) end
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


minetest.register_chatcommand('wps', {
    params = '<name>',
    description = 'set a waypoint',
    func = safe(function(param)
        local point = minetest.localplayer:get_pos()
        waypoints[param] = point
        mod_storage:set_string("waypoints", minetest.serialize(waypoints))

        local x = tostring(round(point['x']))
        local y = tostring(round(point['y']))
        local z = tostring(round(point['z']))
        local pos = x .. ' ' .. y .. ' ' .. z
        local msg = 'set waypoint "' .. param .. '" to "' .. pos .. '"'

        minetest.display_chat_message(msg)
    end),
})


minetest.register_chatcommand('wprm', {
    params = '<name>',
    description = 'remove a waypoint',
    func = safe(function(param)
        waypoints[param] = nil
        mod_storage:set_string("waypoints", minetest.serialize(waypoints))

        minetest.display_chat_message('removed waypoint "' .. param .. '"')
    end),
})


minetest.register_chatcommand('wpls', {
    params = '',
    description = 'lists waypoints',
    func = safe(function(_)
        for name, point in pairsByKeys(waypoints, lc_cmp) do
            local x = tostring(round(point['x']))
            local y = tostring(round(point['y']))
            local z = tostring(round(point['z']))
            local pos = x .. ' ' .. y .. ' ' .. z

            minetest.display_chat_message(name .. ' ' .. pos)
        end
    end),
})


minetest.register_chatcommand('tw', {
    params = '(<playernamename>) <waypoint>',
    description = 'teleport (a player) to a waypoint',
    func = safe(function(param)
        if string.match(param, "^(%S+)%s+(%S+)$") ~= nil then
            local playername, wpname = string.match(param, "^(%S+)%s+(%S+)$")
            local waypoint = waypoints[wpname]

            if waypoint ~= nil then
                local x = tostring(round(waypoint['x']))
                local y = tostring(round(waypoint['y']))
                local z = tostring(round(waypoint['z']))
                local pos = x .. ' ' .. y .. ' ' .. z

                minetest.run_server_chatcommand("teleport", playername .. ' ' .. pos)
            else
                minetest.display_chat_message('waypoint "' .. wpname .. '" not found.')
            end

        else
            local wpname = param
            local waypoint = waypoints[wpname]
            if waypoint ~= nil then
                local x = tostring(round(waypoint['x']))
                local y = tostring(round(waypoint['y']))
                local z = tostring(round(waypoint['z']))
                local pos = x .. ' ' .. y .. ' ' .. z

                minetest.run_server_chatcommand("teleport", pos)
                -- minetest.localplayer:set_pos(waypoint)
            else
                minetest.display_chat_message('waypoint "' .. wpname .. '" not found.')
            end
        end

    end),
})


minetest.register_chatcommand('tr', {
    params = '<ELEV> | <PLAYER> | <PLAYER> <ELEV>',
    description = '/teleport (a player) to a random location',
    func = safe(function(param)
        minetest.log('info', '[cs_waypoints] rt "' .. param .. '"')

        local x = math.random(-30912, 30927)
        local y = math.random(-30912, 30927)
        local z = math.random(-30912, 30927)
        local name = ''

        if string.match(param, "^([%a%d_-]+) (%d+)$") ~= nil then
            name, y = string.match(param, "^([%a%d_-]+) (%d+)$")

        elseif string.match(param, "^([%d-]+)$") then
            y = string.match(param, "^([%d-]+)$")

        elseif string.match(param, "^([%a%d_-]+)$") ~= nil then
            name = string.match(param, "^([%a%d_-]+)$")
        end

        local pos = tostring(x) .. ' ' .. tostring(y) .. ' ' .. tostring(z)

        minetest.run_server_chatcommand("teleport", name .. ' ' .. pos)
    end),
})


