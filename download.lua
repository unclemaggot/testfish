-- ArcvourHub Script Fetcher (Roblox Studio version)
-- Prints all scripts to Output (manual copy required)

local gameScripts = {
    {Name = "Fish It", Url = "https://arcvourhub.my.id/scripts/FI.lua"},
    {Name = "Climb And Jump Tower", Url = "https://arcvourhub.my.id/scripts/CAJT.lua"},
    {Name = "My Singing Brainrot", Url = "https://arcvourhub.my.id/scripts/MSB.lua"},
    {Name = "Catch and Feed a Brainrot", Url = "https://arcvourhub.my.id/scripts/CAFAB.lua"},
    {Name = "Prospecting", Url = "https://arcvourhub.my.id/scripts/PROSPEC.lua"},
    {Name = "Climb and Slide", Url = "https://arcvourhub.my.id/scripts/CAS.lua"},
    {Name = "Poop A Brainrot", Url = "https://arcvourhub.my.id/scripts/PAB.lua"},
    {Name = "Fish A Brainrot", Url = "https://arcvourhub.my.id/scripts/FAB.lua"},
    {Name = "Mines", Url = "https://arcvourhub.my.id/scripts/MINES.lua"},
    {Name = "Kayak Racing", Url = "https://arcvourhub.my.id/scripts/KR.lua"},
    {Name = "Trade A Brainrot", Url = "https://arcvourhub.my.id/scripts/TAB.lua"},
}

for _, scriptInfo in ipairs(gameScripts) do
    print("\n\n===== " .. scriptInfo.Name .. " =====\n")

    local success, response = pcall(function()
        return game:HttpGet(scriptInfo.Url)
    end)

    if success then
        print(response) -- script code printed here
        print("\n===== END OF " .. scriptInfo.Name .. " =====\n\n")
    else
        warn("[-] Failed to fetch " .. scriptInfo.Name .. ": " .. tostring(response))
    end
end
