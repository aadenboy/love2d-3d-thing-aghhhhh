require "boiler"
require "keys"
require "vector"
require "camera"
require "shapes"

local noto = love.graphics.newFont("notosansmono.ttf")
local debuto = love.graphics.newImageFont("perhaps.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"_~@$^{}\\<>|�")
local textn = love.graphics.newText(noto)
local textd = love.graphics.newText(debuto)

local models = require("models")

local function rayPlaneIntersect(rayOrigin, rayDir, planePoint, planeNormal)
    local denom = planeNormal:dotprod(rayDir)
    if math.abs(denom) > 1e-6 then
        local diff = planePoint - rayOrigin
        local t = diff:dotprod(planeNormal) / denom
        if t >= 0 then
            return rayOrigin + rayDir * t
        end
    end
    return nil
end

local function project(p1)
    local proj = (((p1.pos - camera.position) * camera.z):rotaround(Vector2.new(0, 0), 0 - camera.r) / Vector2.new(1, math.pi)) - Vector2.new(0, (p1.height - camera.height) * camera.z)
    return proj + Vector2.new(window.width / 2, window.height / 2), proj
end

camera.height = 0

-- not used yet
local map = {
    {pos = Vector2.new(0, 0), height = 0, size = Vector2.new(1, 1), r = 0, tall = 1, color = fromHEX("aaa"), type = 0}
}


-- ... --
-- ... --
-- ... --
debugcam.selcentroids = {}

local qid = 0
local qtable = {}

for i=-100, 100 do
    qtable[i] = {}
end

function queue(z, func, ...)
    -- z index, draw function, parameters
    z = math.clamp(z, -100, 100)
    qtable[z][#qtable[z]+1] = {func, {...}}
    qid = qid + 1

    return queue
end

local shapequeue = {}

function queue3D(vertexes, sx, sy, sz, position, height, rotation, color)
    shapequeue[#shapequeue+1] = {
        vertexes = vertexes,
        sx = sx,
        sy = sy,
        sz = sz,
        position = position,
        height = height,
        rotation = rotation,
        color = color,
        sorted = {},
        samt = 0,
        oindex = #shapequeue+1
    }
end

local polyqueue = {}
function from3D(vertexes, sx, sy, sz, position, height, rotation, color)
    color = color or {"fff"}

    local vn = {}
    -- synopsis: used to draw a shape in 3D
    -- from3D(vertexes, sx, sy, sz, position, height, size, tall, rotation, [color="fff"])
    -- vertexes: table   - list of all the vertexes of a shape, pairs of three form a triangle
    -- sx:       number  - X scaling of the shape
    -- sy:       number  - Y scaling of the shape
    -- sz:       number  - Z scaling of the shape
    -- position: vector2 - position horizontally
    -- height:   number  - position vertically
    -- rotation: number  - rotation on the Y axis
    -- color:    table   - table of colors for each triangle, if no color is assigned it uses last index

    for i=1, #vertexes, 3 do
        if vertexes[i+2] ~= nil then
            vn[i], vn[i+2] = Vector2.new(vertexes[i], vertexes[i+2]):rotaround(Vector2.new(0, 0), rotation):unpack()
        end
    end

    local function pqueue(p1, p2, p3, col, depth, func)
        polyqueue[#polyqueue+1] = {depth = depth, func = func, p1 = p1, p2 = p2, p3 = p3, col = col, qdata = {
            position = position, height = height, oindex = #polyqueue+1
        }}
    end

    for i=1, #vn, 9 do
        local oindex = (#polyqueue+1)

        local p1 = {pos = Vector2.new(vn[i],   vn[i+2]) * Vector2.new(sx, sz) + position, height = vertexes[i+1] * sy + height}
        local p2 = {pos = Vector2.new(vn[i+3], vn[i+5]) * Vector2.new(sx, sz) + position, height = vertexes[i+4] * sy + height}
        local p3 = {pos = Vector2.new(vn[i+6], vn[i+8]) * Vector2.new(sx, sz) + position, height = vertexes[i+7] * sy + height}
        
        p1.np, p1.proj = project(p1)
        p2.np, p2.proj = project(p2)
        p3.np, p3.proj = project(p3)

        local centroid = {pos = (p1.pos + p2.pos + p3.pos) / 3, height = (p1.height + p2.height + p3.height) / 3}
        local depth    = (centroid.pos - camera.position):magnitude() + math.abs(centroid.height - camera.height)

        local a = {pos = p2.pos - p1.pos, height = p2.height - p1.height}
        local b = {pos = p3.pos - p1.pos, height = p3.height - p1.height}

        local nx = a.height * b.pos.y  - a.pos.y  * b.height
        local nh = a.pos.y  * b.pos.x  - a.pos.x  * b.pos.y
        local ny = a.pos.x  * b.height - a.height * b.pos.x

        local ms, msp = project({pos = Vector2.middle(p1.pos, p2.pos, p3.pos), height = (p1.height + p2.height + p3.height)/3})
        local me, mep = project({pos = Vector2.middle(p1.pos, p2.pos, p3.pos) + Vector2.new(nx, ny), height = (p1.height + p2.height + p3.height)/3 + nh})
        local mnh, mnhp = project({pos = Vector2.middle(p1.pos, p2.pos, p3.pos) + Vector2.new(nx, ny), height = (p1.height + p2.height + p3.height)/3})

        local ang = msp:anglefrom(mnhp)
        if ang >= 0 and ang <= 180 then
            pqueue(p1, p2, p3, color[(i - 1) / 9 + 1] or color[#color], depth, function(index)
                love.graphics.setColor(fromHEX(color[(i - 1) / 9 + 1] or color[#color]))
                love.graphics.polygon("fill", {p1.np.x, p1.np.y, p2.np.x, p2.np.y, p3.np.x, p3.np.y})

                if debugcam.using then
                    if debugcam.normals then
                        love.graphics.setColor(fromHEX("00f"))
                        love.graphics.line(ms.x, ms.y, me.x, me.y)
                    end

                    love.graphics.setFont(debuto, 2)
                    local at = project(centroid)
                    love.graphics.setColor(fromHEX("000"))
                    love.graphics.circle("fill", at.x, at.y, 7)
                    love.graphics.setColor(fromHEX(color[(i - 1) / 9 + 1] or color[#color]))
                    love.graphics.circle("fill", at.x, at.y, 6)
                    love.graphics.print("", at.x - 4, at.y - 8)

                    if Vector2.new(mouse.x, mouse.y):distfrom(at) < 10 or debugcam.revealdots or debugcam.selcentroids[oindex] then
                        queue(30, function()
                            love.graphics.setColor(fromHEX("000"))
                            love.graphics.circle("fill", at.x, at.y, 7)
                            if debugcam.selcentroids[oindex] then love.graphics.setColor(1, 1, 1, 1) else love.graphics.setColor(fromHEX(color[(i - 1) / 9 + 1] or color[#color])) end
                            love.graphics.circle("fill", at.x, at.y, 6)
                            love.graphics.print("", at.x - 4, at.y - 8)

                            if Vector2.new(mouse.x, mouse.y):distfrom(at) < 10 or debugcam.selcentroids[oindex] then
                                if Vector2.new(mouse.x, mouse.y):distfrom(at) < 10 and mouse.lmb.clicked then 
                                    if debugcam.selcentroids[oindex] then debugcam.selcentroids[oindex] = nil else debugcam.selcentroids[oindex] = true end
                                end
                                local ah =  "ObjPos: "..position..
                                            "\nObjHei: "..height..
                                            "\nCtrPos: "..centroid.pos..
                                            "\nCtrHei: "..centroid.height..
                                            "\nOIndex: "..oindex
                                            --"\nScX: "..sx..
                                            --"\nScY: "..sy..
                                            --"\nScZ: "..sz..
                                            --"\nRot: "..rotation..
                                            --"\nPjY:"..((centroid.pos - camera.position):rotaround(Vector2.new(0, 0), 0 - camera.r)).y
                                love.graphics.print(ah, at.x, at.y - 17*5)
                            end
                        end)
                    end
                end
            end)
        end
    end
end

camera.z = 1
camera.height = 2
debugcam.type = 1

--[[
queue3D(models.cube, 200, 300, 30, Vector2.new(0, 0), 0, 0, models.cube.colors)
queue3D(models.cube, 30, 300, 30, Vector2.new(200, 0), 0, 0, models.cube.colors)
queue3D(models.cube, 60, 300, 30, Vector2.new(230, 0), 0, 0, models.cube.colors)
queue3D(models.cube, 300, 300, 30, Vector2.new(0, 330), 0, 0, models.cube.colors)
queue3D(models.cube, 30, 300, 300, Vector2.new(330, 30), 0, 90, models.cube.colors)
queue3D(models.cube, 30, 300, 300, Vector2.new(200, 30), 30, 0, models.cube.colors)
queue3D(models.cube, 30, 30, 300, Vector2.new(60, 30), 60, 0, models.cube.colors)
queue3D(models.cube, 30, 30, 300, Vector2.new(90, 30), 30, 0, models.cube.colors)
queue3D(models.cube, 10, 10, 10, camera.position, camera.height, 0, models.cube.colors)
]]

local cube = Shape.new(Vector2.new(0, 0), 0, models.cube)
cube:scale(Vector2.new(100, 100), 100)
cube:queue()
local cube2 = Shape.new(Vector2.new(150, 0), 0, models.cube)
cube2:scale(Vector2.new(100, 100), 100)
cube2:queue()
Shape.recalculate()

local fpsspinner = 0
function love.draw()
    love.graphics.setFont(noto)
    window:refresh()
    mouse:refresh()
    keyboard:refresh()

    if keyboard.up.pressed    then camera.height = camera.height + 5 end
    if keyboard.down.pressed  then camera.height = camera.height - 5 end
    if keyboard.left.pressed  then camera.r = camera.r - 1 end
    if keyboard.right.pressed then camera.r = camera.r + 1 end
    if keyboard.w.pressed     then camera.position = camera.position + Vector2.fromAngle(camera.r - 90)  * 5 end
    if keyboard.a.pressed     then camera.position = camera.position + Vector2.fromAngle(camera.r - 180) * 5 end
    if keyboard.s.pressed     then camera.position = camera.position + Vector2.fromAngle(camera.r - 270) * 5 end
    if keyboard.d.pressed     then camera.position = camera.position + Vector2.fromAngle(camera.r)       * 5 end

    if keyboard.tab.clicked then debugcam.using = not debugcam.using end

    -- ... --
    -- ... --
    -- ... --
    camera.r = camera.r % 360

    --[[table.sort(shapequeue, function(a, b) -- hate this so much!! not WORKING.
        local ap = (a.position - camera.position):rotaround(Vector2.new(0, 0), 0 - camera.r)
        local bp = (b.position - camera.position):rotaround(Vector2.new(0, 0), 0 - camera.r)

        return ap.y < bp.y
    end)]]

    Shape.render()

    if debugcam.using then
        --debugcam.revealdots = keyboard["`"].pressed
        --debugcam.normals = keyboard.n.pressed
        --debugcam.selcentroids = keyboard.c.clicked and {} or debugcam.selcentroids
        love.graphics.setFont(debuto)
        love.graphics.setColor(1, 1, 1, 1)
        if debugcam.type == 1 then
            --[[love.graphics.setColor(0.1, 0.1, 0.1)
            love.graphics.polygon("fill", {10,25, 160,25, 160,175, 10,175})
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("XZ Map", 10, 10)
            love.graphics.polygon("line", {10,25, 160,25, 160,175, 10,175})
            love.graphics.setColor(0, 1, 0)
            love.graphics.polygon("line", {75,100, 95,100, 85,100, 85,90, 85,110, 85,100})

            love.graphics.setColor(0.1, 0.1, 0.1)
            love.graphics.polygon("fill", {170,25, 320,25, 320,175, 170,175})
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("XY Map", 170, 10)
            love.graphics.polygon("line", {170,25, 320,25, 320,175, 170,175})
            love.graphics.setColor(0, 1, 0)
            love.graphics.polygon("line", {235,100, 255,100, 245,100, 245,90, 245,110, 245,100})

            love.graphics.setColor(0.1, 0.1, 0.1)
            love.graphics.polygon("fill", {330,25, 480,25, 480,175, 330,175})
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("ZY Map", 330, 10)
            love.graphics.polygon("line", {330,25, 480,25, 480,175, 330,175})
            love.graphics.setColor(0, 1, 0)
            love.graphics.polygon("line", {395,100, 415,100, 405,100, 405,90, 405,110, 405,100})

            for _,v in ipairs(polyqueue) do
                v.p1.pos = v.p1.pos - camera.position
                v.p2.pos = v.p2.pos - camera.position
                v.p3.pos = v.p3.pos - camera.position

                v.p1.height = v.p1.height - camera.height
                v.p2.height = v.p2.height - camera.height
                v.p3.height = v.p3.height - camera.height

                love.graphics.setColor(fromHEX(v.col.."a"))
                love.graphics.polygon("line", {
                    v.p1.pos.x / 2 + 85,
                    v.p1.pos.y / 2 + 100,
                    v.p2.pos.x / 2 + 85,
                    v.p2.pos.y / 2 + 100,
                    v.p3.pos.x / 2 + 85,
                    v.p3.pos.y / 2 + 100
                })

                love.graphics.polygon("line", {
                    v.p1.pos.x  / 2 + 245,
                    v.p1.height / -2 + 100,
                    v.p2.pos.x  / 2 + 245,
                    v.p2.height / -2 + 100,
                    v.p3.pos.x  / 2 + 245,
                    v.p3.height / -2 + 100
                })

                love.graphics.polygon("line", {
                    v.p1.pos.y  / 2 + 405,
                    v.p1.height / -2 + 100,
                    v.p2.pos.y  / 2 + 405,
                    v.p2.height / -2 + 100,
                    v.p3.pos.y  / 2 + 405,
                    v.p3.height / -2 + 100
                })
            end]]

            love.graphics.setColor(1, 1, 1)
            love.graphics.print("CamPos: {position = "..camera.position..", height = "..camera.height.."}\nCamRot: "..camera.r.."\nCamZoom: "..camera.z, 10, 190)
        end
        if debugcam.type == 2 then
            love.graphics.printf("== user io ==\nWindow: size "..window.width.."x"..window.height.." at {"..window.x..", "..window.y.."}"..
            "\nMouse: at {"..mouse.x..", "..mouse.y.."} doing actions: "..mouse.mbdb..
            "\nKeyboard: "..keyboard.presseddb..
            "\n\n== queues ==\nShape.queue: "..Shape.queue.__total.." | recalc total: "..#Shape.triacalc..
            "\n\n== other ==\nFPS: "..love.timer.getFPS()..("-/|\\"):sub(fpsspinner % 4 + 1, fpsspinner % 4 + 1)
            , 10, 10, window.width - 30 - 9*19)
        end
        if debugcam.type == 3 then
            --[[love.graphics.setColor(0.1, 0.1, 0.1)
            love.graphics.polygon("fill", {10,25, 310,25, 310,325, 10,325})
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Centroid Map", 10, 10)
            love.graphics.polygon("line", {10,25, 310,25, 310,325, 10,325})
            love.graphics.setColor(0, 1, 0)
            love.graphics.polygon("line", {150,175, 170,175, 160,175, 160,165, 160,185, 160,175})

            for i,a in pairs(polyqueue) do
                if debugcam.selcentroids ~= {} and not debugcam.selcentroids[a.qdata.oindex] then goto cont end
                local mda = Vector2.middle(a.p1.pos, a.p2.pos, a.p3.pos)
                local ap = (mda - camera.position):rotaround(Vector2.new(0, 0), 0 - camera.r)
                local app = (a.qdata.position - camera.position):rotaround(Vector2.new(0, 0), 0 - camera.r)

                local p1 = (a.p1.pos - camera.position):rotaround(Vector2.new(0, 0), 0 - camera.r)
                local p2 = (a.p2.pos - camera.position):rotaround(Vector2.new(0, 0), 0 - camera.r)
                local p3 = (a.p3.pos - camera.position):rotaround(Vector2.new(0, 0), 0 - camera.r)

                love.graphics.setColor(fromHEX(a.col.."a"))
                love.graphics.polygon("line", {
                    p1.x / 1.5 + 160,
                    p1.y / 1.5 + 175,
                    p2.x / 1.5 + 160,
                    p2.y / 1.5 + 175,
                    p3.x / 1.5 + 160,
                    p3.y / 1.5 + 175
                })

                love.graphics.setColor(fromHEX("000"))
                love.graphics.circle("fill", ap.x / 1.5 + 160, ap.y / 1.5 + 175, 7)
                love.graphics.setColor(fromHEX(a.col))
                love.graphics.circle("fill", ap.x / 1.5 + 160, ap.y / 1.5 + 175, 6)
                love.graphics.print(i, ap.x / 1.5 + 160 - 4, ap.y / 1.5 + 175 - 8)
                love.graphics.print(tostring(ap), ap.x / 1.5 + 160 - string.len(tostring(ap)) / 2 * 8, ap.y / 1.5 + 175 - 17*1.5)

                ::cont::
            end

            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Selected Centroids: "..string.gsub(dump(debugcam.selcentroids, 0, "", " "), "[^%d, ]", ""), 10, 335)
            ]]
            
        end

        fpsspinner = fpsspinner + 1

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Debugger #"..debugcam.type.."\nCMD+number to switch\nFPS: "..love.timer.getFPS()..("-/|\\"):sub(fpsspinner % 4 + 1, fpsspinner % 4 + 1), window.width - 9*19 - 10, 10, 9*19, "right")

        for i=0, 9 do
            if (keyboard.lctrl.pressed or keyboard.lgui.pressed) and keyboard[tostring(i)].pressed then
                debugcam.type = i
            end
        end
    end

    qid = 0
end