local gameScripts = {
    { 
        Name = "Fish It",
        PlaceIds = { 121864768012064 },
        Url = "https://raw.githubusercontent.com/unclemaggot/testfish/refs/heads/main/download.lua", 
        Version = "6.3.0",
        Status = "<font color='#4ade80'>Aktif</font>",
        Icon = "https://tr.rbxcdn.com/180DAY-23fac77aaa79ee5008290d43bdd34a3f/256/256/Image/Webp/noFilter"
    },
    { 
        Name = "Climb And Jump Tower",
        PlaceIds = { 123921593837160, 102499196000712 },
        Url = "https://arcvourhub.my.id/scripts/CAJT.lua",
        Version = "4.5.0",
        Status = "<font color='#4ade80'>Aktif</font>",
        Icon = "https://tr.rbxcdn.com/180DAY-f85fa6f3b516da35f1a91e9fce1b3497/256/256/Image/Webp/noFilter"
    },
    { 
        Name = "My Singing Brainrot",
        PlaceIds = { 89343390950953 },
        Url = "https://arcvourhub.my.id/scripts/MSB.lua",
        Version = "1.1.0",
        Status = "<font color='#4ade80'>Aktif</font>",
        Icon = "https://tr.rbxcdn.com/180DAY-c1dce5f8b6aa2f431589d41f5bb17ef3/256/256/Image/Webp/noFilter"
    },
    { 
        Name = "Catch and Feed a Brainrot",
        PlaceIds = { 110931811137535 },
        Url = "https://arcvourhub.my.id/scripts/CAFAB.lua",
        Version = "1.0.0",
        Status = "<font color='#4ade80'>Aktif</font>",
        Icon = "https://tr.rbxcdn.com/180DAY-7e515dc5242944e7663d57a913fd6435/256/256/Image/Webp/noFilter"
    },
    { 
        Name = "Prospecting",
        PlaceIds = { 129827112113663 },
        Url = "https://arcvourhub.my.id/scripts/PROSPEC.lua",
        Version = "3.0.0",
        Status = "<font color='#4ade80'>Aktif</font>",
        Icon = "https://tr.rbxcdn.com/180DAY-db4be5a4ed37ad9600a773272561535a/256/256/Image/Webp/noFilter"
    },
    { 
        Name = "Climb and Slide",
        PlaceIds = { 134236244017051 },
        Url = "https://arcvourhub.my.id/scripts/CAS.lua",
        Version = "1.2.0",
        Status = "<font color='#4ade80'>Aktif</font>",
        Icon = "https://tr.rbxcdn.com/180DAY-f2d2662ebdd6a1aaf81bce1396ddcd85/256/256/Image/Webp/noFilter"
    },
    { 
        Name = "Poop A Brainrot",
        PlaceIds = { 82321750197896 },
        Url = "https://arcvourhub.my.id/scripts/PAB.lua",
        Version = "1.0.5",
        Status = "<font color='#4ade80'>Aktif</font>",
        Icon = "https://tr.rbxcdn.com/180DAY-d0433d87af6899e91da2fa352539c58e/512/512/Image/Webp/noFilter"
    },
    {
        Name = "Fish A Brainrot",
        PlaceIds = { 130686953724730 },
        Url = "https://arcvourhub.my.id/scripts/FAB.lua",
        Version = "1.3.2",
        Status = "<font color='#4ade80'>Aktif</font>",
        Icon = "https://tr.rbxcdn.com/180DAY-5ece9dc50ae8167cf59131a80da80074/512/512/Image/Webp/noFilter"
    },
    { 
        Name = "Mines",
        PlaceIds = { 112279762578792 },
        Url = "https://arcvourhub.my.id/scripts/MINES.lua",
        Version = "1.0.0",
        Status = "<font color='#4ade80'>Aktif</font>",
        Icon = "https://tr.rbxcdn.com/180DAY-2b73003c5d27c6aa587171be554e6b9f/256/256/Image/Webp/noFilter"
    },
    { 
        Name = "Kayak Racing",
        PlaceIds = { 97777561575736 },
        Url = "https://arcvourhub.my.id/scripts/KR.lua",
        Version = "1.1.0",
        Status = "<font color='#4ade80'>Aktif</font>",
        Icon = "https://tr.rbxcdn.com/180DAY-681fd4cc0d5fdc6d6770c7e5ca1d074c/256/256/Image/Webp/noFilter"
    },
    { 
        Name = "Trade A Brainrot",
        PlaceIds = { 138384544898173 },
        Url = "https://arcvourhub.my.id/scripts/TAB.lua",
        Version = "1.0.0",
        Status = "<font color='#4ade80'>Aktif</font>",
        Icon = "https://tr.rbxcdn.com/180DAY-46df2d75b37931646d927a603f2f7fb4/512/512/Image/Webp/noFilter"
    }
}

local currentGameInfo = nil
for _, gameInfo in ipairs(gameScripts) do
    for _, placeId in ipairs(gameInfo.PlaceIds) do
        if placeId == game.PlaceId then
            currentGameInfo = gameInfo
            break
        end
    end
    if currentGameInfo then
        break
    end
end

if currentGameInfo and currentGameInfo.Url then
    local success, scriptContent = pcall(game.HttpGet, game, currentGameInfo.Url)
    if success then
        local gameFunction, err = loadstring(scriptContent)
        if gameFunction and type(gameFunction) == "function" then
            local returnedFunction = gameFunction()
            if type(returnedFunction) == "function" then
                pcall(returnedFunction, gameScripts)
            else
                warn("ArcvourHUB Loader: Script did not return a callable function.")
            end
        else
            warn("ArcvourHUB Loader Error: Failed to load script chunk -", err)
        end
    else
        warn("ArcvourHUB Loader Error: Failed to download script -", scriptContent)
    end
end
