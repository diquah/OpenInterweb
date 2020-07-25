local os = os or require("os")
local component = require("component")
local event = require("event")
local thread = require("thread")
local m = component.modem

local args={...}

m.open(1)

if m.address ~= MAC then --todo: disable this feature
	IPv4 = nil
end

local function check_if_ip_taken(ip)
	local taken = false
	
	local function listen()
		taken = true
	end
	
	m.broadcast(1, "ping", ip)
	event.listen("modem_message", listen)
	
	os.sleep(2.9)
	event.ignore("modem_message", listen)
	os.sleep(0.1)
	
	return taken
end

local function generate_ip(givenip)
	local claimed = true
	local tempip = givenip or nil
	
	while claimed do
		if givenip == nil then
			local ip4a = string.format("%.2d", tostring(math.random(1, 99)))
			local ip4b = string.format("%.3d", tostring(math.random(1, 999)))
			local ip4c = string.format("%.3d", tostring(math.random(1, 999)))
			local ip4d = string.format("%.2d", tostring(math.random(1, 99)))
			tempip = ip4a .. '.' .. ip4b .. '.' .. ip4c .. '.' .. ip4d
		end
		
		print("Attempting to aquire IP: " .. tempip)
		claimed = check_if_ip_taken(tempip)
	end
	
	return tempip
end

if IPv4 ~= nil then
	if args[1] == IPv4 then
		print("This IPv4 Address is already assigned to this computer.")
	elseif args[1] ~= nil then
		print("It is highly discouraged to change your IPv4 Address; this program does not support it.")
	end
	IPv4 = IPv4 or args[1]
	print("Your IP: " .. IPv4)
elseif IPv4 == nil and args[1] == nil then
	IPv4 = generate_ip()
	MAC = m.address
	print("This computer has claimed the IPv4 Address: " .. IPv4 .. " (MAC: " .. MAC .. ")")
elseif IPv4 == nil and args[1] ~= nil then
	print("Checking for availability of IP: " .. args[1])
	if check_if_ip_taken(args[1]) then
		print(args[1] .. " is taken. Try submitting a different IP or run the network command without arguments.")
		os.exit()
	end
	IPv4 = args[1]
	MAC = m.address
	print("This computer has claimed the IPv4 Address: " .. IPv4 .. " (MAC: " .. MAC .. ")")
end

--######################--

local function recieve(_, _, from, port, _, ...)
	local arg = {...}
	if port == 1 then
		if arg[1] == "ping"	 then
			if IPv4 == arg[2] then
				m.send(from, 1, "ping_response")
			end
		end
	end
end
	
event.listen("modem_message", recieve)
