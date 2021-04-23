local os = os or require("os")
local component = require("component")
local event = require("event")
local m = component.modem

iweb = {}

function iweb.ping(ip) -- ping should automatically use port 1
	print(ip)
end

function iweb.broadcast(port, ...)
	print(port, ...)
end