local os = os or require("os")
local component = require("component")
local event = require("event")
local thread = require("thread")
local m = component.modem

local args={...}
m.open(1)

if m.address ~= MAC then --todo: disable this feature
	MAC = m.address
	IPv4 = nil
end

if #args == 0 then
	local ipv4 = IPv4 or " "
	print("\nIPv4	.	.	.	.	" .. ipv4)
	print("MAC	.	.	.	.	" .. MAC .. "\n")
elseif args[1] == '-S' then
	local function check_if_ip_taken(ip)
		local taken = false
		
		local function listen()
			taken = true
		end
		
		m.broadcast(1, "find", ip)
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
		if args[2] == IPv4 then
			print("This IPv4 Address is already assigned to this computer.")
		elseif args[2] ~= nil then
			print("It is highly discouraged to change your IPv4 Address; this program does not support it.")
		end
		IPv4 = IPv4 or args[2]
		print("Your IP: " .. IPv4)
	elseif IPv4 == nil and args[2] == nil then
		IPv4 = generate_ip()
		MAC = m.address
		print("This computer has claimed the IPv4 Address: " .. IPv4 .. " (MAC: " .. MAC .. ")")
	elseif IPv4 == nil and args[2] ~= nil then
		--check if given is IPv4 address
		local is_IPv4 = true
		local chunks = {args[2]:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")}
		if (#chunks == 4) then
			for _,v in pairs(chunks) do
				if (tonumber(v) <= 0 or tonumber(v) > 999) then
					is_IPv4 = false
				end
			end
		else
			print(args[2] .. " is not a valid IPv4 address. IPv4 addresses follow the format xx.xxx.xxx.xx")
			os.exit()
		end
		if not is_IPv4 then
			print(args[2] .. " is not a valid IPv4 address. IPv4 addresses follow the format xx.xxx.xxx.xx")
			os.exit()
		end
		--end check if given is IPv4 address
		print("Checking for availability of IP: " .. args[2])
		if check_if_ip_taken(args[2]) then
			print(args[2] .. " is taken. Try submitting a different IP or run the network command without arguments.")
			os.exit()
		end
		IPv4 = args[2]
		print("This computer has claimed the IPv4 Address: " .. IPv4 .. " (MAC: " .. MAC .. ")")
	end
	ARP = ARP or {{"localhost", IPv4, MAC}}
end -- end if arg 1

local function recieve(_, _, from, port, _, ...)
	local arg = {...}
	if port == 1 then
		if arg[1] == "find"	 then
			if IPv4 == arg[2] then
				m.send(from, 1, "ping_response")
			end
		elseif arg[1] == "dirPing" then
			if ARP ~= nil then
				ARP[#ARP+1] = {nil, arg[2], from}
			end
			m.send(from, 1, "ping_response")
		end
	end
end
		
event.listen("modem_message", recieve)
