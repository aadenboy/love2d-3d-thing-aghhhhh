Vector2 = {meta = {}, inherit = {
    x = 0,
    y = 0,
    magnitude = function(self)
        -- synopsis: gives the distance from {0, 0}
        -- <vector2>:magnitude()
        -- returns: number

        return math.sqrt(self.x^2 + self.y^2)
    end,
    distfrom = function(self, vector)
        -- synopsis: gives the distance from self vector to another
        -- <vector2>:distfrom(vector)
        -- vector: vector2  - the vector2 to calculate distance from

        return math.round(math.sqrt((self.x - vector.x)^2 + (self.y - vector.y)^2), 3)
    end,
    rotaround = function(self, vector, deg)
        -- synopsis: rotates a vector2 around another
        -- <vector2>:rotaround(vector, deg)
        -- vector: vector2  - the vector2 to rotate around
        -- deg: number      - the amount of degrees to rotate around (counter-clockwise)
        -- returns: vector2

        if deg % 360 == 0 then return self end
        deg = deg * math.pi / 180
        local ovec = self - vector
        local nvec = Vector2.new(math.round(ovec.x * math.cos(deg) - ovec.y * math.sin(deg), 3), math.round(ovec.x * math.sin(deg) + ovec.y * math.cos(deg), 3))
        return nvec + vector
    end,
    unpack = function(self)
        -- synopsis: unpacks a vector2 into a tuple for functions
        -- <vector2>:unpack()
        -- returns: number, number

        return self.x, self.y
    end,
    round = function(self, figs)
        -- synopsis: rounds the vector2
        -- <vector2>:round([figs=0])
        -- figs: number - amount of sigfigs to preserve, e.g Vector2.new(2.8531, 9.3278):round(2) returns Vector2.new(2.85, 9.33)
        -- returns: vector2

        return Vector2.new(math.round(self.x, figs), math.round(self.y, figs))
    end,
    clamp = function(self, xmin, xmax, ymin, ymax)
        -- synopsis: clamps the x and y coordinates
        -- <vector2>:clamp(xmin, xmax, ymin, ymax)
        -- xmin: number - x minimum
        -- xmax: number - x maximum
        -- ymin: number - y minimum
        -- ymax: number - y maximum

        return Vector2.new(math.clamp(self.x, xmin, xmax), math.clamp(self.y, ymin, ymax))
    end,
    dotprod = function(self, other)
        -- synopsis: performs dot product on two vector2s
        -- <vector2>:dotprod(other)
        -- other: vector2   - the other vector2
        -- returns: number

        return self.x * other.x + self.y * other.y
    end,
    anglefrom = function(self, vector)
        -- synopsis: gives the angle from two vector2s
        -- <vector2>:anglefrom(thing)
        -- vector: vector2  - the other vector2
        -- returns: number

        local diff = vector - self
        local deg = math.atan2(diff.y, diff.x) * 180 / math.pi
        
        return deg < 0 and (deg + 360) or deg
    end,
    normal = function(self)
        -- synopsis: normalizes a vector to a unit vector
        -- <vector2>:normal()
        -- returns: vector2

        return self / self:magnitude()
    end,
    iscard = function(self)
        -- synopsis: checks if a vector points in a cardinal direction
        -- <vector2>:iscard()
        -- returns: boolean

        return ((self.x ~= 0 and self.y == 0) or (self.x == 0 and self.y ~= 0)) and (self.x ~= 0 or self.y ~= 0)
    end,
    isunit = function(self)
        -- synopsis: checks if a vector is a unit vector
        -- <vector2>:isunit()
        -- returns: boolean

        return self == self:normal()
    end,
    midfrom = function(self, vector)
        -- synopsis: gives the midpoint of two vectors
        -- <vector2>:midfrom(vector)
        -- vector: vector2  - the other vector2
        -- returns: vector2

        return (self + vector) / 2
    end,
}}

function Vector2.new(x, y)
    -- synopsis: creates a new vector2 object
    -- Vector2.new(x, y)
    -- x: number    - x coordinate
    -- y: number    - y coordinate
    -- returns: vector2

    assert(x ~= nil and y ~= nil, "Vector2.new requires two arguments X and Y")
    assert(type(x) == "number", "argument 1 must be a number")
    assert(type(y) == "number", "argument 2 must be a number")
    local vec = {x = x, y = y, isvector = true} -- zzz there's no __type thingy so I'ma just do this
    setmetatable(vec, Vector2.meta)
    return vec
end

function Vector2.fromAngle(deg)
    -- synopsis: creates a new vector2 object from a given angle, i.e 0º = Vector2.new(1, 0), 90º = Vector2.new(0, 1), etc.
    -- Vector2.fromAngle(deg)
    -- deg: number  - the angle to create the vector2 from
    -- returns: vector2

    assert(deg ~= nil, "Vector2.fromAngle requires an argument")
    assert(type(deg) == "number", "argument 1 must be a number")
    return Vector2.new(math.round(math.cos(deg * math.pi / 180), 3), math.round(math.sin(deg * math.pi / 180), 3))
end

function Vector2.middle(...)
    -- synopsis: returns the middle of multiple points
    -- Vector2.middle(v1, v2 [, v3 [, v4 [, ...]]])
    -- v1, v2, ...: vector2 - the vectors to get the middle of

    local t = Vector2.new(0, 0)

    for i=1, #({...}) do
        t = t + ({...})[i]
    end

    return t / #({...})
end

Vector2.meta = {
    __metatable = "vector2",
    __tostring = function(thing)
        return "{"..thing.x..", "..thing.y.."}"
    end,
    __concat = function(thing, other)
        return (typeof(thing) == "vector2" and tostring(thing) or thing)..(typeof(other) == "vector2" and tostring(other) or other)
    end,
    __eq = function(a, b)
        return a.x == b.x and a.y == b.y
    end,
    __add = function(a, b)
        assert(typeof(a) == "vector2", "attempted to add a '"..typeof(a).."' with a 'vector2'")
        assert(typeof(b) == "vector2", "attempted to add a 'vector2' with a '"..typeof(b).."'")
        return Vector2.new(a.x + b.x, a.y + b.y)
    end,
    __sub = function(a, b)
        assert(typeof(a) == "vector2", "attempted to subtract a '"..typeof(a).."' with a 'vector2'")
        assert(typeof(b) == "vector2", "attempted to subtract a 'vector2' with a '"..typeof(b).."'")
        return Vector2.new(a.x - b.x, a.y - b.y)
    end,
    __mul = function(a, b)
        assert(typeof(a) == "vector2" or typeof(a) == "number", "attempted to multiply a '"..typeof(a).."'")
        assert(typeof(b) == "vector2" or typeof(b) == "number", "attempted to multiply a '"..typeof(b).."'")
        a = typeof(a) == "number" and {x = a, y = a} or a
        b = typeof(b) == "number" and {x = b, y = b} or b
        return Vector2.new(a.x * b.x, a.y * b.y)
    end,
    __div = function(a, b)
        assert(typeof(a) == "vector2" or typeof(a) == "number", "attempted to divide a '"..typeof(a).."'")
        assert(typeof(b) == "vector2" or typeof(b) == "number", "attempted to divide a '"..typeof(b).."'")
        a = typeof(a) == "number" and {x = a, y = a} or a
        b = typeof(b) == "number" and {x = b, y = b} or b
        return Vector2.new(a.x / b.x, a.y / b.y)
    end,
    __mod = function(a, b)
        assert(typeof(a) == "vector2", "attempted to perform modulus on a '"..typeof(a).."' with a 'vector2'")
        assert(typeof(b) == "vector2", "attempted to perform modulus on a 'vector2' with a '"..typeof(b).."'")
        return Vector2.new(a.x % b.x, a.y % b.y)
    end,
    __exp = function(a, b)
        assert(typeof(a) == "vector2" or typeof(a) == "number", "attempted to perform exponent with a '"..typeof(a).."'")
        assert(typeof(b) == "vector2" or typeof(a) == "number", "attempted to perform exponent with a '"..typeof(b).."'")
        a = typeof(a) == "number" and {x = a, y = a} or a
        b = typeof(b) == "number" and {x = b, y = b} or b
        return Vector2.new(a.x^b.x, a.y^b.y)
    end,
    __index = function(blah, key)
        return Vector2.inherit[key]
    end
}