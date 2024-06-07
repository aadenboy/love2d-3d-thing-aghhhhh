window = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    refresh = function(self)
        local flags
        self.width, self.height, flags = love.window.getMode()
        self.x, self.y = flags.x, flags.y
    end
}

mouse = { -- note: mb is "mouse button", l m and r is "left" "middle" and "right", t is "temporary", aka "debounce"
    -- pressed is for when it's held, clicked is for the one frame the click starts, frames is the amount of frames it's held down for
    x = 0,
    y = 0,
    lmb = {pressed = false, frames = 0, clicked = false},
    rmb = {pressed = false, frames = 0, clicked = false},
    mmb = {pressed = false, frames = 0, clicked = false},
    mbdb = "",
    refresh = function(self)
        self.mbdb = ""
        self.x, self.y = love.mouse.getPosition()
        self.lmb.pressed = love.mouse.isDown(1)
        self.mmb.pressed = love.mouse.isDown(3)
        self.rmb.pressed = love.mouse.isDown(2)
        self.lmb.clicked = self.lmb.pressed and self.lmb.frames == 0
        self.mmb.clicked = self.mmb.pressed and self.mmb.frames == 0
        self.rmb.clicked = self.rmb.pressed and self.rmb.frames == 0
        self.lmb.frames = (self.lmb.frames + 1) * (self.lmb.pressed and 1 or 0)
        self.mmb.frames = (self.mmb.frames + 1) * (self.mmb.pressed and 1 or 0)
        self.rmb.frames = (self.rmb.frames + 1) * (self.rmb.pressed and 1 or 0)
        if self.lmb.pressed then self.mbdb = self.mbdb.."lmb("..self.lmb.frames.."f), " end
        if self.mmb.pressed then self.mbdb = self.mbdb.."mmb("..self.mmb.frames.."f), " end
        if self.rmb.pressed then self.mbdb = self.mbdb.."rmb("..self.rmb.frames.."f), " end
    end
}

keyboard = {["a"] = {pressed = false, frames = 0, clicked = false},
["b"] = {pressed = false, frames = 0, clicked = false},
["c"] = {pressed = false, frames = 0, clicked = false},
["d"] = {pressed = false, frames = 0, clicked = false},
["e"] = {pressed = false, frames = 0, clicked = false},
["f"] = {pressed = false, frames = 0, clicked = false},
["g"] = {pressed = false, frames = 0, clicked = false},
["h"] = {pressed = false, frames = 0, clicked = false},
["i"] = {pressed = false, frames = 0, clicked = false},
["j"] = {pressed = false, frames = 0, clicked = false},
["k"] = {pressed = false, frames = 0, clicked = false},
["l"] = {pressed = false, frames = 0, clicked = false},
["m"] = {pressed = false, frames = 0, clicked = false},
["n"] = {pressed = false, frames = 0, clicked = false},
["o"] = {pressed = false, frames = 0, clicked = false},
["p"] = {pressed = false, frames = 0, clicked = false},
["q"] = {pressed = false, frames = 0, clicked = false},
["r"] = {pressed = false, frames = 0, clicked = false},
["s"] = {pressed = false, frames = 0, clicked = false},
["t"] = {pressed = false, frames = 0, clicked = false},
["u"] = {pressed = false, frames = 0, clicked = false},
["v"] = {pressed = false, frames = 0, clicked = false},
["w"] = {pressed = false, frames = 0, clicked = false},
["x"] = {pressed = false, frames = 0, clicked = false},
["y"] = {pressed = false, frames = 0, clicked = false},
["z"] = {pressed = false, frames = 0, clicked = false},
["0"] = {pressed = false, frames = 0, clicked = false},
["1"] = {pressed = false, frames = 0, clicked = false},
["2"] = {pressed = false, frames = 0, clicked = false},
["3"] = {pressed = false, frames = 0, clicked = false},
["4"] = {pressed = false, frames = 0, clicked = false},
["5"] = {pressed = false, frames = 0, clicked = false},
["6"] = {pressed = false, frames = 0, clicked = false},
["7"] = {pressed = false, frames = 0, clicked = false},
["8"] = {pressed = false, frames = 0, clicked = false},
["9"] = {pressed = false, frames = 0, clicked = false},
["space"] = {pressed = false, frames = 0, clicked = false},
["!"] = {pressed = false, frames = 0, clicked = false},
["\""] = {pressed = false, frames = 0, clicked = false},
["#"] = {pressed = false, frames = 0, clicked = false},
["$"] = {pressed = false, frames = 0, clicked = false},
["&"] = {pressed = false, frames = 0, clicked = false},
["'"] = {pressed = false, frames = 0, clicked = false},
["("] = {pressed = false, frames = 0, clicked = false},
[")"] = {pressed = false, frames = 0, clicked = false},
["*"] = {pressed = false, frames = 0, clicked = false},
["+"] = {pressed = false, frames = 0, clicked = false},
[","] = {pressed = false, frames = 0, clicked = false},
["-"] = {pressed = false, frames = 0, clicked = false},
["."] = {pressed = false, frames = 0, clicked = false},
["/"] = {pressed = false, frames = 0, clicked = false},
[":"] = {pressed = false, frames = 0, clicked = false},
[";"] = {pressed = false, frames = 0, clicked = false},
["<"] = {pressed = false, frames = 0, clicked = false},
["="] = {pressed = false, frames = 0, clicked = false},
[">"] = {pressed = false, frames = 0, clicked = false},
["?"] = {pressed = false, frames = 0, clicked = false},
["@"] = {pressed = false, frames = 0, clicked = false},
["["] = {pressed = false, frames = 0, clicked = false},
["\\"] = {pressed = false, frames = 0, clicked = false},
["]"] = {pressed = false, frames = 0, clicked = false},
["^"] = {pressed = false, frames = 0, clicked = false},
["_"] = {pressed = false, frames = 0, clicked = false},
["`"] = {pressed = false, frames = 0, clicked = false},
["kp0"] = {pressed = false, frames = 0, clicked = false},
["kp1"] = {pressed = false, frames = 0, clicked = false},
["kp2"] = {pressed = false, frames = 0, clicked = false},
["kp3"] = {pressed = false, frames = 0, clicked = false},
["kp4"] = {pressed = false, frames = 0, clicked = false},
["kp5"] = {pressed = false, frames = 0, clicked = false},
["kp6"] = {pressed = false, frames = 0, clicked = false},
["kp7"] = {pressed = false, frames = 0, clicked = false},
["kp8"] = {pressed = false, frames = 0, clicked = false},
["kp9"] = {pressed = false, frames = 0, clicked = false},
["kp."] = {pressed = false, frames = 0, clicked = false},
["kp,"] = {pressed = false, frames = 0, clicked = false},
["kp/"] = {pressed = false, frames = 0, clicked = false},
["kp*"] = {pressed = false, frames = 0, clicked = false},
["kp-"] = {pressed = false, frames = 0, clicked = false},
["kp+"] = {pressed = false, frames = 0, clicked = false},
["kpenter"] = {pressed = false, frames = 0, clicked = false},
["kp="] = {pressed = false, frames = 0, clicked = false},
["up"] = {pressed = false, frames = 0, clicked = false},
["down"] = {pressed = false, frames = 0, clicked = false},
["right"] = {pressed = false, frames = 0, clicked = false},
["left"] = {pressed = false, frames = 0, clicked = false},
["home"] = {pressed = false, frames = 0, clicked = false},
["end"] = {pressed = false, frames = 0, clicked = false},
["pageup"] = {pressed = false, frames = 0, clicked = false},
["pagedown"] = {pressed = false, frames = 0, clicked = false},
["insert"] = {pressed = false, frames = 0, clicked = false},
["backspace"] = {pressed = false, frames = 0, clicked = false},
["tab"] = {pressed = false, frames = 0, clicked = false},
["clear"] = {pressed = false, frames = 0, clicked = false},
["return"] = {pressed = false, frames = 0, clicked = false},
["delete"] = {pressed = false, frames = 0, clicked = false},
["f1"] = {pressed = false, frames = 0, clicked = false},
["f2"] = {pressed = false, frames = 0, clicked = false},
["f3"] = {pressed = false, frames = 0, clicked = false},
["f4"] = {pressed = false, frames = 0, clicked = false},
["f5"] = {pressed = false, frames = 0, clicked = false},
["f6"] = {pressed = false, frames = 0, clicked = false},
["f7"] = {pressed = false, frames = 0, clicked = false},
["f8"] = {pressed = false, frames = 0, clicked = false},
["f9"] = {pressed = false, frames = 0, clicked = false},
["f10"] = {pressed = false, frames = 0, clicked = false},
["f11"] = {pressed = false, frames = 0, clicked = false},
["f12"] = {pressed = false, frames = 0, clicked = false},
["f13"] = {pressed = false, frames = 0, clicked = false},
["f14"] = {pressed = false, frames = 0, clicked = false},
["f15"] = {pressed = false, frames = 0, clicked = false},
["f16"] = {pressed = false, frames = 0, clicked = false},
["f17"] = {pressed = false, frames = 0, clicked = false},
["f18"] = {pressed = false, frames = 0, clicked = false},
["numlock"] = {pressed = false, frames = 0, clicked = false},
["capslock"] = {pressed = false, frames = 0, clicked = false},
["scrolllock"] = {pressed = false, frames = 0, clicked = false},
["rshift"] = {pressed = false, frames = 0, clicked = false},
["lshift"] = {pressed = false, frames = 0, clicked = false},
["rctrl"] = {pressed = false, frames = 0, clicked = false},
["lctrl"] = {pressed = false, frames = 0, clicked = false},
["ralt"] = {pressed = false, frames = 0, clicked = false},
["lalt"] = {pressed = false, frames = 0, clicked = false},
["rgui"] = {pressed = false, frames = 0, clicked = false},
["lgui"] = {pressed = false, frames = 0, clicked = false},
["escape"] = {pressed = false, frames = 0, clicked = false},
["help"] = {pressed = false, frames = 0, clicked = false},
["printscreen"] = {pressed = false, frames = 0, clicked = false},
["sysreq"] = {pressed = false, frames = 0, clicked = false},
["menu"] = {pressed = false, frames = 0, clicked = false},
["application"] = {pressed = false, frames = 0, clicked = false},
["power"] = {pressed = false, frames = 0, clicked = false},
["currencyunit"] = {pressed = false, frames = 0, clicked = false},
["undo"] = {pressed = false, frames = 0, clicked = false},
clicked = {},
pressed = {},
presseddb = "",
refresh = function(self)
    self.clicked   = {}
    self.pressed   = {}
    self.presseddb = ""
    self.clickeddb = ""
    for i,v in pairs(self) do
        if type(v) == "table" then
            if v.frames then
                self[i].pressed = love.keyboard.isDown(i)
                self[i].clicked = self[i].pressed and v.frames == 0
                self[i].frames = (v.frames + 1) * (self[i].pressed and 1 or 0)
                if self[i].pressed then self.presseddb = self.presseddb..i.."("..self[i].frames.."f), " self.pressed[i] = self[i] end
            end
        end
    end
end,
pressing = function(self, ...)
    for _,v in pairs({...}) do
        if self.pressed[v] == nil then
            return false
        end
    end

    return true
end,
clicking = function(self, ...)
    for _,v in pairs({...}) do
        if self.clicked[v] == nil then
            return false
        end
    end

    return true
end,
}