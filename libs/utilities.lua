function string_starts(s, start)
    return string.sub(s, 1, string.len(start)) == start
end

--- Check is table contain a value
--- @param table table
--- @param value any
--- @return boolean
function table_contains(table, value)
    for i, v in ipairs(table) do
        if v == value then return true end
    end
    return false
end

--- Merge target table with source tables
--- @param target table
--- @param ... table[]
--- @return table
function table_merge(target, ...)
    assert(type(target) == "table", "Target is not a table")
    local tables_to_merge = { ... }
    if #tables_to_merge == 0 then return target end

    for k, t in ipairs(tables_to_merge) do
        assert(type(t) == "table", string.format("Expected a table as parameter %d", k))
    end

    for i = 1, #tables_to_merge do
        local from = tables_to_merge[i]
        for k, v in pairs(from) do
            if type(k) == "number" then
                table.insert(target, v)
            elseif type(k) == "string" then
                if type(v) == "table" then
                    target[k] = target[k] or {}
                    target[k] = table_merge(target[k], v)
                else
                    target[k] = v
                end
            end
        end
    end

    return target
end

--- Create a deep copy of table
--- @param orig table The table to copy
--- @return table
function table_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table_copy(orig_key)] = table_copy(orig_value)
        end
        setmetatable(copy, table_copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--- Get a string representation of table
--- @param tbl table The table to inspect
function table_stringify(tbl)
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
