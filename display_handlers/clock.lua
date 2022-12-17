-- http://worldtimeapi.org/api/timezone/Europe/London.txt

function display(data, untilRefresh)
    local date, time = string.match(data, "datetime: (%d%d%d%d%-%d%d%-%d%d)T(%d%d:%d%d:%d%d)")
    love.graphics.clear(0.4,0.6,1)
    love.graphics.setColor(1,1,1)
    if(not date) then
        love.graphics.print("waiting for data...",10,10)
    else
        love.graphics.print("current time: "..date.." "..time,10,10)
    end
    if(untilRefresh < 0) then
        love.graphics.printf("refreshing...",550,70,200,"right")
    else
        love.graphics.printf("estimated refresh in "..math.floor(untilRefresh + 1),550,70,200,"right")
    end
end

return display