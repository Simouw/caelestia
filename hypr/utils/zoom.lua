-- Caelestia Niri-style directional window zoom navigation
-- Provides seamless 2D navigation across maximized windows with native workspace slide animations.

local M = {}

-- State storage keyed by main workspace ID (e.g. 1, 2, 3...)
-- zoomed_workspaces[main_ws_id] = {
--   main_ws = number,
--   windows = { { address = "...", at = {x, y}, size = {x, y}, cx = ..., cy = ..., sub_ws = number }, ... },
--   current_index = number,
--   active_sub_ws = number,
-- }
local zoomed_workspaces = {}
local subws_to_main = {}

-- Verify and remove windows that have been closed
local function clean_windows(st)
    local valid = {}
    local curr_addr = st.windows[st.current_index] and st.windows[st.current_index].address
    local new_curr_idx = 1

    for _, w in ipairs(st.windows) do
        local win_obj = hl.get_window("address:" .. w.address)
        if win_obj then
            table.insert(valid, w)
            if w.address == curr_addr then
                new_curr_idx = #valid
            end
        else
            subws_to_main[w.sub_ws] = nil
        end
    end

    st.windows = valid
    st.current_index = math.min(new_curr_idx, #valid)
end

-- Find the nearest neighbor in the specified direction based on original unzoomed geometry
local function find_neighbor(windows, curr_idx, dir)
    local cur = windows[curr_idx]
    if not cur then return nil end

    local best_idx = nil
    local best_score = math.huge
    local threshold = 15

    for i, cand in ipairs(windows) do
        if i ~= curr_idx then
            local dx = cand.cx - cur.cx
            local dy = cand.cy - cur.cy
            local valid = false
            local score = math.huge

            if dir == "right" then
                if dx > threshold then
                    local v_overlap = math.min(cur.at.y + cur.size.y, cand.at.y + cand.size.y) - math.max(cur.at.y, cand.at.y)
                    local angle_ok = math.abs(dy) <= dx * 2.0
                    if v_overlap > 0 or angle_ok then
                        valid = true
                        score = dx + math.abs(dy) * 2.5
                    end
                end
            elseif dir == "left" then
                if dx < -threshold then
                    local v_overlap = math.min(cur.at.y + cur.size.y, cand.at.y + cand.size.y) - math.max(cur.at.y, cand.at.y)
                    local angle_ok = math.abs(dy) <= (-dx) * 2.0
                    if v_overlap > 0 or angle_ok then
                        valid = true
                        score = (-dx) + math.abs(dy) * 2.5
                    end
                end
            elseif dir == "down" then
                if dy > threshold then
                    local h_overlap = math.min(cur.at.x + cur.size.x, cand.at.x + cand.size.x) - math.max(cur.at.x, cand.at.x)
                    local angle_ok = math.abs(dx) <= dy * 2.0
                    if h_overlap > 0 or angle_ok then
                        valid = true
                        score = dy + math.abs(dx) * 2.5
                    end
                end
            elseif dir == "up" then
                if dy < -threshold then
                    local h_overlap = math.min(cur.at.x + cur.size.x, cand.at.x + cand.size.x) - math.max(cur.at.x, cand.at.x)
                    local angle_ok = math.abs(dx) <= (-dy) * 2.0
                    if h_overlap > 0 or angle_ok then
                        valid = true
                        score = (-dy) + math.abs(dx) * 2.5
                    end
                end
            end

            if valid and score < best_score then
                best_score = score
                best_idx = i
            end
        end
    end

    return best_idx
end

local function unzoom(main_ws)
    local st = zoomed_workspaces[main_ws]
    if not st then return end

    local active_addr = nil
    if st.windows[st.current_index] then
        active_addr = st.windows[st.current_index].address
    end

    -- Restore default horizontal slide animation
    hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "standard", style = "slide" })

    -- Move all windows back to the original main workspace
    for _, w in ipairs(st.windows) do
        subws_to_main[w.sub_ws] = nil
        hl.dispatch(hl.dsp.window.move({ window = "address:" .. w.address, workspace = main_ws, follow = false }))
        hl.dispatch(hl.dsp.window.fullscreen({ mode = "none", window = "address:" .. w.address }))
    end

    zoomed_workspaces[main_ws] = nil

    hl.dispatch(hl.dsp.focus({ workspace = main_ws }))
    if active_addr then
        hl.dispatch(hl.dsp.focus({ window = "address:" .. active_addr }))
    end
end

function M.toggle()
    local active_ws = hl.get_active_workspace()
    if not active_ws then return end

    local current_ws_id = active_ws.id
    local main_ws = subws_to_main[current_ws_id]

    -- If currently in a zoomed workspace, exit zoom mode
    if main_ws and zoomed_workspaces[main_ws] then
        unzoom(main_ws)
        return
    end

    -- If already marked zoomed on current_ws_id directly
    if zoomed_workspaces[current_ws_id] then
        unzoom(current_ws_id)
        return
    end

    -- Otherwise, collect windows on the current workspace
    local all_wins = hl.get_workspace_windows(current_ws_id) or {}
    local tiled = {}
    for _, w in ipairs(all_wins) do
        if not w.floating then
            table.insert(tiled, w)
        end
    end

    -- If 1 or 0 windows, perform normal maximized toggle
    if #tiled <= 1 then
        hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
        return
    end

    local active_win = hl.get_active_window()
    local active_addr = active_win and active_win.address or tiled[1].address
    local curr_idx = 1

    local win_data = {}
    local base_sub_ws = current_ws_id * 10000

    for i, w in ipairs(tiled) do
        local sub_id = base_sub_ws + (i * 10)
        win_data[i] = {
            address = w.address,
            at = { x = w.at.x, y = w.at.y },
            size = { x = w.size.x, y = w.size.y },
            cx = w.at.x + w.size.x / 2,
            cy = w.at.y + w.size.y / 2,
            sub_ws = sub_id,
        }
        subws_to_main[sub_id] = current_ws_id

        if w.address == active_addr then
            curr_idx = i
        end
    end

    -- Move windows to their sub-workspaces and maximize them
    for _, w in ipairs(win_data) do
        hl.dispatch(hl.dsp.window.move({ window = "address:" .. w.address, workspace = w.sub_ws, follow = false }))
        hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", window = "address:" .. w.address }))
    end

    zoomed_workspaces[current_ws_id] = {
        main_ws = current_ws_id,
        windows = win_data,
        current_index = curr_idx,
        active_sub_ws = win_data[curr_idx].sub_ws,
    }

    hl.dispatch(hl.dsp.focus({ workspace = win_data[curr_idx].sub_ws }))
    hl.dispatch(hl.dsp.focus({ window = "address:" .. win_data[curr_idx].address }))
end

function M.navigate(dir)
    return function()
        local active_ws = hl.get_active_workspace()
        if not active_ws then return end

        local main_ws = subws_to_main[active_ws.id]
        if not main_ws or not zoomed_workspaces[main_ws] then
            -- Not in zoom mode: normal directional focus
            return hl.dispatch(hl.dsp.focus({ direction = dir }))
        end

        local st = zoomed_workspaces[main_ws]
        clean_windows(st)
        if #st.windows <= 1 then
            unzoom(main_ws)
            return
        end

        local target_idx = find_neighbor(st.windows, st.current_index, dir)
        if not target_idx then
            -- Nothing in this direction, strictly keep current view as requested
            return
        end

        local target_win = st.windows[target_idx]

        -- Configure identical workspace animation curve & speed with dynamic direction
        if dir == "right" or dir == "left" then
            hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "standard", style = "slide" })
        else
            hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "standard", style = "slidevert" })
        end

        local cur_ws_id = active_ws.id
        local target_ws_id = target_win.sub_ws

        -- Guarantee that Hyprland slides in the physically correct direction:
        -- Right / Down: target ID must be strictly greater than current ID
        -- Left / Up: target ID must be strictly less than current ID
        if (dir == "right" or dir == "down") and target_ws_id <= cur_ws_id then
            target_ws_id = cur_ws_id + 1
            target_win.sub_ws = target_ws_id
            subws_to_main[target_ws_id] = main_ws
            hl.dispatch(hl.dsp.window.move({ window = "address:" .. target_win.address, workspace = target_ws_id, follow = false }))
            hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", window = "address:" .. target_win.address }))
        elseif (dir == "left" or dir == "up") and target_ws_id >= cur_ws_id then
            target_ws_id = cur_ws_id - 1
            target_win.sub_ws = target_ws_id
            subws_to_main[target_ws_id] = main_ws
            hl.dispatch(hl.dsp.window.move({ window = "address:" .. target_win.address, workspace = target_ws_id, follow = false }))
            hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", window = "address:" .. target_win.address }))
        end

        st.current_index = target_idx
        st.active_sub_ws = target_ws_id

        hl.dispatch(hl.dsp.focus({ workspace = target_ws_id }))
        hl.dispatch(hl.dsp.focus({ window = "address:" .. target_win.address }))
    end
end

-- Hook for workspace switching (SUPER + 1..10, AZERTY keys) to persist zoomed state per-workspace
function M.get_active_ws(ws_id)
    if ws_id and zoomed_workspaces[ws_id] then
        local st = zoomed_workspaces[ws_id]
        clean_windows(st)
        if #st.windows > 0 and st.windows[st.current_index] then
            return st.windows[st.current_index].sub_ws
        end
    end
    return ws_id
end

function M.is_zoomed(ws_id)
    return ws_id and zoomed_workspaces[ws_id] ~= nil
end

return M
