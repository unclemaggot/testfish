-- Download Arcvour.lua and save it locally
local url = "https://arcvourhub.my.id/scripts/Arcvour.lua"
local fileName = "Arcvour.lua"

-- Fetch the script
local success, response = pcall(function()
    return game:HttpGet(url)
end)

-- Save to file
if success then
    writefile(fileName, response)
    print("[+] File saved as " .. fileName)
else
    warn("[-] Failed to download: " .. tostring(response))
end
