function string_starts(s, start)
    return string.sub(s, 1, string.len(start)) == start
end

function table_check(table, value)
    for i, v in ipairs(table) do
        if v == value then return true end
    end
    return false
end

function table_merge(...)
    local tables_to_merge = { ... }
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them")

    for k, t in ipairs(tables_to_merge) do
        assert(type(t) == "table", string.format("Expected a table as function parameter %d", k))
    end

    local result = tables_to_merge[1]

    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]
        for k, v in pairs(from) do
            if type(k) == "number" then
                table.insert(result, v)
            elseif type(k) == "string" then
                if type(v) == "table" then
                    result[k] = result[k] or {}
                    result[k] = table_merge(result[k], v)
                else
                    result[k] = v
                end
            end
        end
    end

    return result
end

-- Function to inspect a table up to a certain depth
function inspectDepth(tbl, indent, depth)
    if depth and depth > 5 then
        return "Depth limit reached"
    end

    if type(tbl) ~= "table" then
        return "Not a table"
    end

    local str = ""
    indent = indent or 0

    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. tostring(k) .. ": "
        if type(v) == "table" then
            str = str .. formatting .. "\n"
            str = str .. inspectDepth(v, indent + 1, (depth or 0) + 1)
        elseif type(v) == "function" then
            str = str .. formatting .. "function\n"
        elseif type(v) == "boolean" then
            str = str .. formatting .. tostring(v) .. "\n"
        else
            str = str .. formatting .. tostring(v) .. "\n"
        end
    end

    return str
end

--- Inspects a table and returns its string representation.
-- @param tbl The table to inspect.
-- @return A string representation of the table.
function inspect(tbl)
    if type(tbl) ~= "table" then
        return "Not a table"
    end

    local str = ""
    for k, v in pairs(tbl) do
        local valueStr = type(v) == "table" and "table" or tostring(v)
        str = str .. tostring(k) .. ": " .. valueStr .. "\n"
    end

    return str
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
