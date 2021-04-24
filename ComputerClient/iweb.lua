local os = os or require("os")
local component = require("component")
local event = require("event")
local m = component.modem

if MAC == nil then -- if OpenInterweb has not been installed before.
	MAC = m.address
	IP = nil
end

m.open(1)

--== LOCAL FUNCTIONS ==--

local function sendDataToMAC(mac, port, ...)
	m.send(mac, port, arg)
end

--== iWEB FUNCTIONS ==--

iweb = {}

function iweb.sendData(ip, port, ...)
	local macToSend = iweb.ARPsearch(ip)
	sendDataToMAC(macToSend, port, arg)
end

function iweb.ARPsearch(key) --find MAC of IP in ARP table.
	if ARP == nil then
		return
	end
	for i, v in pairs(ARP) do
		if v[1] == key then
			return v[2]
		elseif v[2] == key then
			return v[1]
		end
	end
end

function iweb.addToARP(ip, mac)
	ARP[#ARP+1] = {ip, mac}
end

function iweb.ping(ip, timeout) -- ping should automatically use port 1
	timeout = timeout or 3
	iweb.sendData(ip, 1, "ping")
	_, _, from, port, _, msg = event.pull(3, "modem_message")
	if msg == "return_ping" then -- if recieved a response
		return true
	end
	return false
end

function iweb.broadcast(port, ...)
	m.broadcast(port, arg)
end

--== Simple/Low-Level Stuff ==--

local function lowLevelMessageHandler(_, _, from, port, _, ...)
	if iweb.ARPsearch(from) == nil then
		sendDataToMAC(from, 1, "identify") --ask for a MAC not in ARP what their IP is
	end

	if arg[1] == "ping" then
		sendDataToMAC(from, 1, "return_ping")
	elseif arg[1] == "identify" and IP ~= nil then --return IP for computer asking what IP belongs to this MAC
		sendDataToMAC(from, 1, "return_identify", IP)
	elseif arg[1] == "return_identify" then
		iweb.addToARP(arg[2], from)
	elseif arg[1] == "find" and arg[2] == IP then
		iweb.sendDataToMAC(from, 1, "return_find")
	end
end

event.listen("modem_message", lowLevelMessageHandler)