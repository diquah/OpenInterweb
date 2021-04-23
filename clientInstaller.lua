local component = component or require("component")

--== RUBY'S UTITLY INSTALLER ==--

rUtil = {}

function rUtil.ljust(string, num)
    return string.format("%" .. num .. "s", string)
end

--== COMPUTER CLIENT INSTALLER ==--

local FILES = {"iweb", "ipconfig"}

for i, v in pairs(FILES) do
    local handle, data, chunk = component.proxy(component.list("internet")()).request(
        "https://raw.githubusercontent.com/rubycookinson/OpenInterweb/v2/ComputerClient/" .. v .. ".lua"), ""
    
    while true do
        chunk = handle.read(math.huge)
        
        if chunk then
            data = data .. chunk
        else
            break
        end
    end
     
    handle.close()

    local file = io.open(v, 'w')
    file:write(data)
    file:close()
end

dofile("iweb")

print("\nInstallation Complete!\n")