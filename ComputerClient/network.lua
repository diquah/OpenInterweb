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

local function check_if_ip_taken(ip, End)
	local taken = false
	local End = End or false
	
	local ipg_thread = thread.create(function()
		local function listen()
			taken = false --IPv4 cannot be claimed
			event.cancel(canceltimer)
			print("IP already assigned.")
		end
		
		local function cancel()
			print("canceltimer")
			event.ignore("modem_message", listen) --ignore responses
			ipg_thread:kill()
		end
		
		local canceltimer = event.timer(4.5, cancel) --If no computer responds in 5 seconds
		
		m.broadcast(1, "computer_exists", tempip)
		taken = true
		
		event.listen("modem_message", listen)
	end)
	
	os.sleep(5)
	ipg_thread:kill()
	
	if taken and End then
		print("This IPv4 is already taken. Try generating a new IPv4 or choosing a different custom IPv4.")
		os.exit()
	end
	
	return taken
end

local function generate_ip(givenip)
	local claimed = false
	local tempip = givenip or nil
	
	while not claimed do
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
	IPv4 = check_if_ip_taken(args[1], true)
	MAC = m.address
	print("This computer has claimed the IPv4 Address: " .. IPv4 .. " (MAC: " .. MAC .. ")")
end

--ARP = {}
