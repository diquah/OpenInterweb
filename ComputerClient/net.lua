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
		print(ping(args[2], args[3]))
	end
elseif args[1] == 'arp' then
	print("\nALIAS	.	.	.	 IPv4	.	.	.	.	.	.	.	MAC")
	print("---------------------------------------")
	for i, v in pairs(ARP) do
		print(string.format("%s	.	.	%s	.	.	%s", v[1], v[2], v[3]))
	end
	print()
elseif args[1] == 'stat' then
	if args[2] == nil then
		
	elseif args[2] == 'port' then
		print("\nScanning for open ports...")
		local ret = ""
		for i=1, 65535 do
			if m.isOpen(i) then
				ret = ret .. tostring(i) .. ", "
			end
		end
		print("\n{" .. ret:sub(1, -3) .. "}\n")
	end
else
	print("Invalid command.")
end
