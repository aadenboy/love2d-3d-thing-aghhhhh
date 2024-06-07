require "boiler"
require "vector"
require "keys"

local noto = love.graphics.newFont("notosansmono.ttf")
local thing = love.graphics.newImageFont("perhaps.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"_~@$^{}\\<>|�")
local counts = 0

camera = {
    position = Vector2.new(0, 0), -- position of the camera
    r = 0,                        -- rotation of the camera
    z = 0.4,                      -- zoom of the camera, smaller = zoomed out, bigger = zoomed in
    mouse = Vector2.new(0, 0),    -- position of the mouse relative to the camera
    offset = function(self, dirvec, r, z)
        -- synopsis: offsets the camera
        -- camera:offset(dirvec [, r=0, z=0])
        -- dirvec: vector2  - position offset
        -- r: number        - rotation offset
        -- z: number        - zoom offset

        self.position = self.position + (dirvec or Vector2.new(0, 0))
        self.r = self.r + (r or 0)
        self.z = self.z + (z or 0)
    end,
    offrel = function(self, dirvec, r, z)
        -- synopsis: offsets the camera with respect to it's initial rotation
        -- camera:offrel(dirvec [, r=0, z=0])
        -- dirvec: vector2  - direction
        -- r: number        - rotation offset
        -- z: number        - zoom offset

        self:offset((dirvec or Vector2.new(0, 0)):rotaround(self.position, self.r), r, z)
    end,
    set = function(self, vec, r, z)
        -- synopsis: sets the camera
        -- camera:set(vec [, r=camera.r, z=camera.z])
        -- vec: vector2 - new position
        -- r: number    - new rotation
        -- z: number    - new zoom

        self.position = vec or self.position
        self.r = r or self.r
        self.z = z or self.z
    end,
    updatemouse = function(self)
        camera.mouse = (camera.position - Vector2.new(window.width / 2 / camera.z, window.height / -2 / camera.z):rotaround(camera.position, camera.r)) + Vector2.new(mouse.x / camera.z, mouse.y / -1 / camera.z):rotaround(camera.position, camera.r)
    end
}

debugcam = {
    using = false,                       -- determines whether or not toview from the debug camera
    position = Vector2.new(0, 0),       -- position of the debug camera
    r = 0,                              -- rotation of the debug camera
    z = 0.1,                           -- zoom of the debug camera
    roundfigs = 3,                      -- amount of sigfigs to display 
    hotkeys = {                         -- hotkeys menu
        open = false,                   -- is the menu open?
        scroll = 0,                     -- current scrolling
        help = "",                      -- what's shown
        change = function(self, new)
            -- synopsis: updates the help text
            -- debugcam.hotkeys:change(new)
            -- new: string  - the new text to show

            self.help = new
            self.helpdt = love.graphics.newText(noto, self.help)
        end,
        show = function(self)
            local debugcam = {hotkeys = self}
            if debugcam.hotkeys.open then
                local h = debugcam.hotkeys.helpdt
                local hw, hh = h:getWidth(), h:getHeight()
        
                love.graphics.setColor(fromHEX("000a"))
                love.graphics.rectangle("fill", window.width / 2 - math.min(hw / 2 + 50, window.width / 2 - 100), debugcam.hotkeys.scroll + window.height / 4, math.min(hw + 100, window.width - 200), hh + 100)
        
                love.graphics.setColor(fromHEX("fff"))
                love.graphics.printf(debugcam.hotkeys.help, window.width / 2 - math.min(hw / 2, window.width / 2 - 150), debugcam.hotkeys.scroll + window.height / 4 + 50, math.min(hw + 100, window.width - 200) - (window.width / 2 - math.min(hw / 2 + 50, window.width / 2 - 100)))
            end
        end
    },
    debug = function(self, nonefunc, debugfunc, dwindow, dmouse, cmain, cdebug, bottom)
        local debugcam = self
        -- synopsis: debug screen
        -- debugcam:debug([nonefunc, debugfunc, window, mouse, cmain, cdebug, bottom])
        -- nonefunc: function   - function to run when not debugging
        -- debugfunc: function  - function to run when debugging
        -- window: table        - unordered table of things to show under window debug
        -- mouse: table         - unordered table of things to show under mouse debug
        -- cmain: table         - unordered table of things to show under camera main debug
        -- cdebug: table        - unordered table of things to show under camera debug debug
        -- bottom: string       - extra text to show at the bottom

        if debugcam.using then
            local w  = window.width / 2
            local h  = window.height / 2
            local z  = debugcam.z
            local rf = debugcam.roundfigs

            local function dothething(string, table)
                for i,v in pairs(table) do
                        if typeof(v) == "number"  then v = math.round(v, rf)
                    elseif typeof(v) == "vector2" then v = v:round(rf)       end
                    string = string.."\n"..i..": "..v
                end
                return string
            end

            -- no way I'm actually making my code look nice?????????????????????????
            love.graphics.setLineWidth(1)
            love.graphics.setColor(fromHEX("f80"))
            love.graphics.polygon("line", CamPoly({w*-1,h*-1, w*-1,h, w,h, w,h*-1}, camera.position, camera.r, 1/camera.z, 1/camera.z))
            love.graphics.polygon("line", CamPoly({-5,0, 5,0, 0,0, 0,-5, 0,5, -2.5,2.5, 0,5, 2.5,2.5, 0,5, 0,0}, camera.position, camera.r, 1/z, 1/z))
    
            love.graphics.setColor(fromHEX("08f"))
            love.graphics.polygon("line", CamPoly({-5,0, 5,0, 0,0, 0,-5, 0,5, -2.5,2.5, 0,5, 2.5,2.5, 0,5, 0,0}, camera.mouse, camera.r, 1/z, 1/z))
            counts = counts + 1
            local windowdeb  = dothething("== WINDOW ==\nX: "..window.x.."\nY: "..window.y.."\nWidth: "..window.width.."\nHeight: "..window.height.."\nFPS: "..love.timer.getFPS().." "..({"|", "\\", "-", "/"})[counts % 4 + 1], dwindow or {})
            local mousedeb   = dothething("== MOUSE ==\nX: "..mouse.x.."\nY: "..mouse.y.."\nLMB: "..(mouse.lmb.pressed and ("active "..mouse.lmb.frames.."f") or "inactive")..(mouse.lmb.clicked and ", clicked" or "").."\nMMB: "..(mouse.mmb.pressed and ("active "..mouse.mmb.frames.."f") or "inactive")..(mouse.mmb.clicked and ", clicked" or "").."\nRMB: "..(mouse.rmb.pressed and ("active "..mouse.rmb.frames.."f") or "inactive")..(mouse.rmb.clicked and ", clicked" or "").."\nPressedKB: "..keyboard.presseddb.."\nClickedKB: "..keyboard.clickeddb, dmouse or {})
            local cammaindeb = dothething("== CAMERA MAIN ==\nPosition: "..camera.position:round(rf).."\nMouse: "..camera.mouse:round(rf).."\nRotation: "..math.round(camera.r, rf).."\nZoom: "..math.round(camera.z, rf), cmain or {})
            local camdebdeb  = dothething("== CAMERA DEBUG ==\nUsing: "..tostring(debugcam.using).."\nPosition: "..debugcam.position:round(rf).."\nRotation: "..debugcam.r.."\nZoom: "..math.round(debugcam.z, rf).."\nRoundfigs: "..rf.."\nHotkeyOpen: "..tostring(debugcam.hotkeys.open).."\nHotkeyScroll: "..debugcam.hotkeys.scroll, cdebug or {})

            love.graphics.setFont(thing)

            love.graphics.setColor(fromHEX("0f0"))
            love.graphics.printf(windowdeb,  0,                    0, window.width / 4)
            love.graphics.printf(mousedeb,   window.width / 4,     0, window.width / 4)
            love.graphics.printf(cammaindeb, window.width / 2,     0, window.width / 4)
            love.graphics.printf(camdebdeb,  window.width / 4 * 3, 0, window.width / 4)

            love.graphics.setColor(fromHEX("000a"))
            love.graphics.print("tab to toggle debug || ctrl / for hotkeys"..(bottom and " || "..bottom or ""), 0, window.height - 15)
            
            debugfunc = debugfunc or (function() end)
            debugfunc()
        else
            nonefunc = nonefunc or (function() end)
            nonefunc()
        end
    end
}
debugcam.hotkeys.helpdt = love.graphics.newText(noto, debugcam.hotkeys.help)

function CamPoint(x, y, r, sx, sy)
    -- synopsis: returns new values as shown by the camera
    -- CamPoint(x, y [, r=0, sx=1, sy=1])
    -- x: number    - x position
    -- y: number    - y position
    -- r: number    - rotation
    -- sx: number   - x scaling
    -- sy: number   - y scaling
    -- returns: number, number, number, number, number

    local cam = debugcam.using and debugcam or camera

    local rad = cam.r * math.pi / 180
    local xo = x - cam.position.x
    local yo = y - cam.position.y

    if sy then
        r = (r or 0) * math.pi / 180
        return math.cos(rad) * xo * cam.z + math.cos(rad - math.pi / 2) * yo * cam.z + window.width / 2, math.sin(rad) * xo * cam.z + math.sin(rad - math.pi / 2) * yo * cam.z + window.height / 2, r + rad, (sx or 0) * cam.z, (sy or 0) * cam.z
    else
        return math.cos(rad) * xo * cam.z + math.cos(rad - math.pi / 2) * yo * cam.z + window.width / 2, math.sin(rad) * xo * cam.z + math.sin(rad - math.pi / 2) * yo * cam.z + window.height / 2, (r or 0) * cam.z, (sx or 0) * cam.z
    end
end

function CamPointInt(x, y, r, sx, sy)
    local x, y, r, sx, sy = CamPoint(x, y, r, sx, sy)
    return math.round(x), math.round(y), r, math.round(sx), math.round(sy)
end

function CamPoly(pols, vec, r, sx, sy)
    -- synopsis: returns new polygon points as shown by the camera
    -- CamPoly(pols, vec [, r=0, sx=1, sy=1, dilx=0, dily=0])
    -- pols: table  - table of points
        -- point x, - point 1 x
        -- point y, - point 1 y
        -- point x, - point 2 x
        -- point y, - point 2 y
        -- ...
    -- vec: vector2 - position
    -- r: number    - rotation
    -- sx: number   - scale x
    -- sy: number   - scale y
    -- returns: table

    assert(pols ~= nil and vec ~= nil, "CamPoly requires at least two arguments")
    assert(typeof(pols) == "table", "expected argument 1 to be a table, got '"..typeof(pols).."' instead")
    assert(typeof(vec) == "vector2", "expected argument 2 to be a Vector2, got '"..typeof(vec).."' instead")

    local pots = {}
    r = r or 0
    sx = sx or 1
    sy = sy or 1

    for i=1, #pols, 2 do
        local pos = (Vector2.new(pols[i], pols[i+1]) * Vector2.new(sx, sy) + vec):rotaround(vec, r)
        pots[i], pots[i+1] = CamPoint(pos.x, pos.y, 0, 0, 0)
    end

    return pots
end

function CamUI(x, y)
    -- synopsis: moves an object to as if it was moving with the camera, like a ui object
    -- CamUI(x, y)
    -- x: number - screen X position, starting from left and going right
    -- y: number - screen Y position, starting from top and going down
    -- returns: vector2

    -- note: you will still need to offset it via CamPoint or CamPoly

    return (camera.position - Vector2.new(window.width / 2 / camera.z, window.height / -2 / camera.z):rotaround(camera.position, camera.r)) + Vector2.new(x / camera.z, y / -1 / camera.z):rotaround(camera.position, camera.r)
end