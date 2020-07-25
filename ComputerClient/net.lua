local os = os or require("os")
local component = require("component")
local event = require("event")
local m = component.modem

args = {...}

if not m.isOpen(1) then
	m.open(1)
end

local function ping(ip, mode)
	if ip == nil then
		print("Cannot ping nil IPv4.")
		os.exit()
	end
	local mode = mode or 'value'
	
	m.broadcast(1, "ping", ip)
	local _, _, from, port, _, message = event.pull(3, "modem_message")
	
	if mode == 'value' then
		print("\nFrom IPv4	.	.	" .. ip)
		print("From MAC	.	.	.	" .. from)
		print("Port	.	.	.	.	.	" .. port)
		print("Message	.	.	.	" .. message .. "\n")
		return from, port, message
	elseif mode == 'bool' then
		if from == nil then
			return false
		else
			return true
		end
	end
end

if args[1] == nil then
	print("Specify a command.")
	os.exit()
elseif args[1] == 'ping' then
	if args[2] == nil then
		print("You must specify an address to ping, and optionally, the ping mode.")
		os.exit()
	elseif args[3] == nil then
		ping(args[2])
		os.exit()
	else
		print(ping(args[2]))
	end
end
