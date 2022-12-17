local url, timeout, channel = ...
local http = require("socket.http")
require "love.timer"
while true do
    love.thread.getChannel(channel):push(http.request(url))
    love.timer.sleep(timeout)
end