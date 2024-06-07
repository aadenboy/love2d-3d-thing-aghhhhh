require "boiler"
require "vector"
require "camera"
local models = require("models")

Shape = {meta = {}, inherit = {}, queue = {__total = 0}, triacalc = {}}

function Shape.project(position, height)
    -- synopsis: projects a point to the screen
    -- Shape.project(position, height)
    -- position: vector2 - XZ position of the point in 3d space
    -- height:   number  - Y position of the point in 3d space
    -- returns: vector2

    return (((position - camera.position) * camera.z):rotaround(Vector2.new(0, 0), 0 - camera.r) / Vector2.new(1, math.pi)) - Vector2.new(0, (height - camera.height) * camera.z) + Vector2.new(window.width / 2, window.height / 2)
end

function Shape.new(position, height, model)
    -- synopsis: creates a new shape object (this is expensive!)
    -- Shape.new(position, height, model)
    -- position: vector2 - XZ position of new shape
    -- height:   number  - Y position of new shape
    -- model:    table   - list of vertex points for the model, use models.lua for premades
    -- returns: shape

    assert(position and height and model, "Shape.new requires three arguments")
    assert(typeof(position) == "vector2", "arguemnt 1 must be a vector2")
    assert(typeof(height)   == "number",  "argument 2 must be a number")
    assert(typeof(model)    == "table",   "argument 3 must be a table of model vertex points")
    assert(#model % 9 == 0,               "malformed model data")

    local shape = {
        position  = position,
        height    = height,
        model     = model,
        triangles = {}
    }
    for i=1, #model, 9 do
        local p1 = {position = Vector2.new(model[i],   model[i+2]), height = model[i+1]}
        local p2 = {position = Vector2.new(model[i+3], model[i+5]), height = model[i+4]}
        local p3 = {position = Vector2.new(model[i+6], model[i+8]), height = model[i+7]}

        local a = {position = p2.position - p1.position, height = p2.height - p1.height}
        local b = {position = p3.position - p1.position, height = p3.height - p1.height}

        local nx = a.height     * b.position.y - a.position.y * b.height
        local nh = a.position.y * b.position.x - a.position.x * b.position.y
        local ny = a.position.x * b.height     - a.height     * b.position.x

        shape.triangles[#shape.triangles+1] = {
            centroid = {
                position = Vector2.middle(p1.position, p2.position, p3.position),
                height   = (p1.height + p2.height + p3.height) / 3
            },
            normal = {
                position = Vector2.new(nx, ny),
                height   = nh
            },
            color = model.colors and model.colors[i] or {math.max(nx, 0) - math.min(ny, 0), nh - math.min(nx, 0) - math.min(ny, 0), math.max(ny, 0) - math.min(nx, 0)},
            p1 = p1,
            p2 = p2,
            p3 = p3,
        }
    end

    setmetatable(shape, Shape.meta)
    return shape
end

function Shape.recalculate()
    -- synopsis: recalculates the ordering of the queued shapes for renderring (expensive!)
    -- Shape.recalculate()

    local qord = {}
    for _,v in pairs(Shape.queue) do
        if typeof(v) == "shape" then
            qord[#qord+1] = v
        end 
    end

    for _,v in ipairs(qord) do
        for _,b in ipairs(v.triangles) do
            b.position = v.position
            b.height = v.height
            Shape.triacalc[#Shape.triacalc+1] = b
        end
    end
end

function Shape.render()
    -- synopsis: renders all recalculated shapes
    -- Shape.render()
    table.sort(Shape.triacalc, function(a, b)
        local ap = (a.centroid.position - camera.position):rotaround(Vector2.new(0, 0), 0 - camera.r).y
        local bp = (b.centroid.position - camera.position):rotaround(Vector2.new(0, 0), 0 - camera.r).y

        return ap > bp
    end)

    for i,v in ipairs(Shape.triacalc) do
        if v.normal.position:rotaround(Vector2.new(0, 0), 0 - camera.r).y < 0 then goto cont end

        love.graphics.setColor(v.color)

        love.graphics.polygon("fill", {
            Shape.project(v.p1.position + v.position, v.p1.height + v.height).x,
            Shape.project(v.p1.position + v.position, v.p1.height + v.height).y,
            Shape.project(v.p2.position + v.position, v.p2.height + v.height).x,
            Shape.project(v.p2.position + v.position, v.p2.height + v.height).y,
            Shape.project(v.p3.position + v.position, v.p3.height + v.height).x,
            Shape.project(v.p3.position + v.position, v.p3.height + v.height).y,
        })

        ::cont::
    end
end

Shape.inherit = {
    position  = position,
    height    = height,
    model     = model,
    triangles = {},
    queue = function(self)
        -- synopsis: queues a shape for renderring
        -- <shape>:queue()
        
        Shape.queue[self] = self
        Shape.queue.__total = Shape.queue.__total + 1
    end,
    dequeue = function(self)
        -- synopsis: takes a shape out of the queue if it is in it
        -- <shape>:dequeue()

        Shape.queue[self] = nil
        Shape.queue.__total = Shape.queue.__total - 1
    end,
    paint = function(self, colors)
        -- synopsis: changes the colors of the triangles of a shape
        -- <shape>:paint(colors)
        -- colors: table - list of colors for each triangle, if the color is falsey then it is unchanged

        for i,v in pairs(self.triangles) do
            self.triangles[i].color = colors[i] or v.color
        end
    end,
    rotate = function(self, deg, originpos, originheight)
        -- synopsis: rotates the shape's triangles on the Y axis around an origin point
        -- <shape>:rotate(deg [, originpos=Vector2.new(0, 0), originheight=0])
        -- deg:          number  - amount to rotate in degrees
        -- originpos:    vector2 - XZ position of origin
        -- originheight: number  - Y position of origin
        -- NOTE: origin is relative to the MODEL, not the WORLD
        -- NOTE: model is unchanged

        originpos    = originpos    or Vector2.new(0, 0)
        originheight = originheight or 0

        for i,v in pairs(self.triangles) do
            local p1n = v.p1.position:rotaround(originpos, deg)
            local p2n = v.p2.position:rotaround(originpos, deg)
            local p3n = v.p3.position:rotaround(originpos, deg)

            self.triangles[i].p1.position = p1n
            self.triangles[i].p2.position = p2n
            self.triangles[i].p3.position = p3n

            local a = {position = p2n - p1n, height = v.p2.height - v.p1.height}
            local b = {position = p3n - p1n, height = v.p3.height - v.p1.height}

            local nx = a.height     * b.position.y - a.position.y * b.height
            local nh = a.position.y * b.position.x - a.position.x * b.position.y
            local ny = a.position.x * b.height     - a.height     * b.position.x

            self.triangles[i].normal.position = Vector2.new(nx, ny)
            self.triangles[i].centroid.position = Vector2.middle(p1n, p2n, p3n)
        end
    end,
    scale = function(self, sp, sh, originpos, originheight)
        -- synopsis: scales the shape's triangles from an origin point
        -- <shape>:scale(sp, sh [, originpos=Vector2.new(0, 0), originheight=0])
        -- sp:           vector2 - XZ scale
        -- sh:           number  - Y scale
        -- originpos:    vector2 - XZ position of origin
        -- originheight: number  - Y position of origin
        -- NOTE: origin is relative to the MODEL, not the WORLD
        -- NOTE: model is unchanged

        originpos    = originpos    or Vector2.new(0, 0)
        originheight = originheight or 0

        for i,v in pairs(self.triangles) do
            v.p1 = {position = (v.p1.position - originpos) * sp + originpos, height = (v.p1.height - originheight) * sh + originheight}
            v.p2 = {position = (v.p2.position - originpos) * sp + originpos, height = (v.p2.height - originheight) * sh + originheight}
            v.p3 = {position = (v.p3.position - originpos) * sp + originpos, height = (v.p3.height - originheight) * sh + originheight}
            self.triangles[i].p1, self.triangles[i].p2, self.triangles[i].p3 = v.p1, v.p2, v.p3 

            local a = {position = v.p2.position - v.p1.position, height = v.p2.height - v.p1.height}
            local b = {position = v.p3.position - v.p1.position, height = v.p3.height - v.p1.height}

            local nx = a.height     * b.position.y - a.position.y * b.height
            local nh = a.position.y * b.position.x - a.position.x * b.position.y
            local ny = a.position.x * b.height     - a.height     * b.position.x

            self.triangles[i].normal = {position = Vector2.new(nx, ny), height = nh}
            self.triangles[i].centroid = {position = Vector2.middle(v.p1.position, v.p2.position, v.p3.position), height = (v.p1.height + v.p2.height + v.p3.height) / 3}
        end
    end,
    rebuild = function(self)
        -- synopsis: completely rebuilds the shape whilst preserving location and colors
        -- <shape>:rebuild()

        local oloc = {position = self.position, height = self.height}
        local colors = {}

        for _,v in ipairs(self.triangles) do
            colors[#colors+1] = v.color
        end
        self.model.colors = colors

        self.triangles = Shape.new(self.position, self.height, self.model).triangles
    end,
    clone = function(self)
        -- synopsis: creates a new shape reference that is a duplicate of a shape
        -- <shape>:clone()
        -- returns: shape

        local shape = Shape.new(self.position, self.height, self.model)
        shape.triangles = self.triangles
        return shape
    end,
}

Shape.meta = {
    __metatable = "shape",
    __tostring = function()
        error("attempted to convert shape to string, use dump() instead")
    end,
    __index = function(blah, key)
        return Shape.inherit[key]
    end
}

-- testing --
local shape = Shape.new(Vector2.new(0, 0), 0, models.planeY)
shape:scale(Vector2.new(0, 0), 10000)
local re1 = shape:clone()
shape:rebuild()

print(dump(re1.triangles[1].centroid,   0, " ", " "))
print(dump(shape.triangles[1].centroid, 0, " ", " "))