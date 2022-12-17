http = require("socket.http")

requestTrackers = {}

nextAvailableChannel = 0

function newTracker(url,timeout,displayFunction)
    local thread = love.thread.newThread("request.lua")
    table.insert(requestTrackers,{
        untilRefresh = 0,
        timeout = timeout,
        cache = "",
        handler = require(displayFunction),
        canvas = love.graphics.newCanvas(760, 100),
        url = url,
        channel = "request"..nextAvailableChannel,
        thread = thread,
        storedData = nil,
        justUpdated = false
    })
    thread:start(url, timeout, "request"..nextAvailableChannel)
    nextAvailableChannel = nextAvailableChannel + 1
end

addingTracker = false
step = 0
newUrl = ""
newTimeout = ""
newCallback = ""

function love.update(dt)
    for _,tracker in pairs(requestTrackers) do
        local msg = love.thread.getChannel(tracker.channel):pop()
        tracker.untilRefresh = tracker.untilRefresh - dt
        if(msg) then
            tracker.cache = msg
            tracker.untilRefresh = tracker.timeout
            tracker.justUpdated = true
        end
    end
end

function love.draw()
    love.graphics.clear(0.2,0.3,0.6)
    for i,tracker in ipairs(requestTrackers) do
        love.graphics.setCanvas(tracker.canvas)
        tracker.storedData = tracker.handler(tracker.cache, tracker.untilRefresh, tracker.storedData, tracker.justUpdated)
        tracker.justUpdated = false
        love.graphics.setCanvas()
        love.graphics.draw(tracker.canvas, 20, 30+(i-1)*120)
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.print("press SPACE to add a new tracker, or press a number key (1, 2, 3...) to delete the corresponding tracker",5,5)

    if(addingTracker) then
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", 0, 0, 800, 600)
        love.graphics.setColor(0.3, 0.45, 1)
        love.graphics.rectangle("fill", 200, 250, 400, 100)
        if(step == 1) then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("enter a URL to request, or nothing to paste from clipboard", 220, 270)
            love.graphics.setColor(0.1,0.15,0.45)
            love.graphics.rectangle("fill", 220, 300, 360, 20)
            love.graphics.setColor(1,1,1)
            love.graphics.print(newUrl, 223, 303)
        end
        if(step == 2) then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("enter how many seconds to wait between requests:", 220, 270)
            love.graphics.setColor(0.1,0.15,0.45)
            love.graphics.rectangle("fill", 220, 300, 360, 20)
            love.graphics.setColor(1,1,1)
            love.graphics.print(newTimeout, 223, 303)
        end
        if(step == 3) then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("enter the display module path (e.g. display_handler.clock):", 220, 270)
            love.graphics.setColor(0.1,0.15,0.45)
            love.graphics.rectangle("fill", 220, 300, 360, 20)
            love.graphics.setColor(1,1,1)
            love.graphics.print(newCallback, 223, 303)
        end
        if(step == 4) then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("press enter to confirm, or space to deny", 220, 270)
            love.graphics.print("url: "..newUrl.."\ntimeout: "..newTimeout.." seconds\nmodule: "..newCallback, 223, 303)
        end
    end
end

function love.keypressed(key, scancode, rept)
    if(key == "space" and not addingTracker) then
        addingTracker = true
        step = 1
        newUrl = ""
        newTimeout = ""
        newCallback = ""
        if(addingTracker and step == 4) then addingTracker = false end
    elseif(addingTracker and key == "return") then
        step = step + 1
        if(step == 2 and newUrl == "") then newUrl = love.system.getClipboardText() end
        if(step == 5) then
            addingTracker = false
            newTracker(newUrl, tonumber(newTimeout), newCallback)
        end
    elseif(addingTracker and key == "backspace") then
        if(step == 1) then
            newUrl = string.sub(newUrl, 1, #newUrl - 1)
        elseif(step == 2) then
            newTimeout = string.sub(newTimeout, 1, #newTimeout - 1)
        elseif(step == 3) then
            newCallback = string.sub(newCallback, 1, #newCallback - 1)
        end
    end
end

function love.textinput(str)
    if(addingTracker and str ~= "\n") then
        if(step == 1 and not (#newUrl == 0 and str == " ")) then
            newUrl = newUrl .. str
        elseif(step == 2) then
            newTimeout = newTimeout .. str
        elseif(step == 3) then
            newCallback = newCallback .. str
        end
    end
end