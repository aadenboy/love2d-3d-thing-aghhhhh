-- boiler!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
local utf8 = require "utf8"

function math.round(n, figs)
    -- synopsis: rounds number
    -- math.round(n [, figs=0])
    -- n: number    - the number to round
    -- figs: number - amount of sigfigs to preserve, e.g math.round(2.357, 2) returns 2.36
    -- returns: number
    -- Blah blah blah

    figs = figs or 0
    n = n * 10^figs
    return n - math.floor(n) >= 0.5 and math.ceil(n) / 10^figs or math.floor(n) / 10^figs
end

function math.clamp(n, min, max)
    return math.min(math.max(n, min), max)
end

function math.inside(n, from, to, set)
    set = set or "[]"
    return n == math.clamp(n, from, to) and ((n ~= from and set:sub(1, 1) == "(") or set:sub(1, 1) == "[") and ((n ~= to and set:sub(2, 2) == ")") or set:sub(2, 2) == "]")
end

function string.split(str, pattern, strict)
    local got = {}
    local strict = (strict or false) and "+" or "*"

    for m in string.gmatch(str, "([^"..pattern.."]"..strict..")") do
        got[#got+1] = m
    end

    return got
end

function fromRGB(r, g, b, a)
    return r / 255, g / 255, b / 255, (a or 255) / 255
end

function fromHEX(h)
    h = h:sub(1, 1) == "#" and h:sub(2, -1) or h
    h = h:lower()
    assert(#h == 3 or #h == 4 or #h == 6 or #h == 8, "malformed hex code")
    assert(h:find("[^abcdef1234567890]") == nil, "malformed hex code")
    local vals = {}

    for i=1, #h, #h < 6 and 1 or 2 do
        vals[#vals+1] = tonumber(string.rep(string.sub(h, i, #h < 6 and i or i + 1), #h < 6 and 2 or 1), 16)
    end

    return vals[1] / 255, vals[2] / 255, vals[3] / 255, (vals[4] or 255) / 255
end

function validUTF8(text)
    text = tostring(text)
    local success, pos = utf8.len(text)

    if not success then
        text = text:sub(0, pos-1).."�"..text:sub(pos+1, -1)
        return validUTF8(text)
    end

    return text
end

function typeof(thing)
    return type(getmetatable(thing)) == "string" and getmetatable(thing) or type(thing)
end

function dump(table, nest, delim, newline) -- ugly looking code tbh
    if string.find("table,shape", typeof(table)) then
        local s = ""
        nest = nest or 0
        delim = delim or "\t"
        newline = newline or "\n"

        for i,v in pairs(table) do
            if typeof(i) == "string" and i:match("^[%a_][%d%a_]*$") then s = s..delim:rep(nest)..i.." = "
                                                                    else s = s..delim:rep(nest).."["..(type(i) == "string" and "\"" or "")..tostring(i)..(type(i) == "string" and "\"" or "").."] = " end

            if typeof(v) == "table" then
                local has = false for _ in pairs(v) do has = true break end

                if has then
                    s = s.."{"..newline..dump(v, nest + 1, delim, newline)..newline..delim:rep(nest).."},"
                else
                    s = s.."{},"
                end
            else
                s = s..tostring(v)..","
            end

            s = s..newline
        end

        return s:sub(1, -3)
    else
        return tostring(table)
    end
end