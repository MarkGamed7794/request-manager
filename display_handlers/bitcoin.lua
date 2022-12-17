-- https://api.coindesk.com/v1/bpi/currentprice.json
json = require "json"

function display(data, untilRefresh, cache, justUpdated)
    local cacheIn = cache
    love.graphics.clear(0.4,0.6,1)
    love.graphics.setColor(1,1,1)
    if(data == "") then
        love.graphics.print("waiting for data...",10,10)
    elseif(justUpdated) then
        cacheIn = json.decode(data)
    end

    if(cacheIn) then
        love.graphics.print("BTC price: "..cacheIn.bpi.USD.rate_float,10,10)
    end

    if(untilRefresh < 0) then
        love.graphics.printf("refreshing...",550,70,200,"right")
    else
        love.graphics.printf("estimated refresh in "..math.floor(untilRefresh + 1),550,70,200,"right")
    end
    return cacheIn
end

return display