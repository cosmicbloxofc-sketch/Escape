repeat wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("Backpack") 

local config = {
    ["ExcludedItemName"] = "Basic Bat",
    ["DelaySendGift"] = 1,
    ["DelayStartSystem"] = 10,
    ["MainAccount"] = {"famr28dtpx27", "tdrxttqy9768"},
    ["GiftAccount"] = {
        "voidneonzoom2005",
        "dawnshadowgalaxy36",
        "evelynstarry201432",
        "gabrielprimalminer52",
        "slimeomegasilver2011",
        "jackeagle200842",
        "streameagle24yt",
        "primalsilver202355",
        "graysoncybergamer49",
        "voidflamewraithyt",
        "hazeghostpower2024",
        "zaydenphoenix2007yt",
        "mysticzeroblizzardyt",
        "tigerfusionspark43",
        "avadragonghost59",
        "willowcrazechaos2017",
        "zaydenravenvortexyt",
        "kinghero202088",
        "graysonsilver93",
        "leviinferno200392",
        "baconsilver37",
        "chillfox201412",
        "lightphoenix200350",
        "ultrashadowmagic2018",
        "ashercyberdrift74",
        "owengamercrystal2014",
        "isaacneonhyper2008",
        "blazewraithsaber2005",
        "venomfoxbeast201214",
        "zoewraithflame45",
        "flickskymaster36yt",
        "turbodawnchill2021",
        "flickphoenixfusion",
        "neonmasterbeast20154",
        "loganstormprism",
        "foxsaber202092",
        "victoriavenom200390",
        "primallavastarry2008",
        "graysonalphaultrayt",
        "saberstormlegend2006",
        "blockbaconprimal2006",
        "riderhyper2011yt",
        "skyecho202114",
        "baconchase37",
        "ghostraven97yt",
        "ninjaepicpro2016",
        "fusionsparkly58yt",
        "luckymax202355",
        "beargoldennova2010",
        "jaxondawn2015yt",
        "zapflamerift2012",
        "zoelava84",
        "logangamerpulse2014y",
        "infernoroguegamer201",
        "vortexlight201275",
        "blastpowerbeast2015",
        "harpervortexaceyt",
        "loganbanestarry2013",
        "sparkechobaconyt",
        "venompowerlight2002",
        "hazelzap2022yt",
        "oliviaroguechill2019",
        "olivialegend202276",
        "sebastianviperpanda2",
        "lunacircuithunter201",
        "zaydentoxicmagic2007",
        "stormturbophoenix202",
        "circuitstormflash",
        "oliverriftgolden2002",
        "brooklyndarkultra98",
        "glitchsilver201786",
        "aidenfox12yt",
        "pulsefury45yt",
        "shadowneon201392",
        "sophiadancerminer61",
        "brooklynnrogue39",
        "miaflamepulseyt",
        "noahrocketdawn63",
        "masterbyteshadow2013",
        "orbitprismrocket2002",
        "pulserocket35yt",
        "eliskater200294",
        "alphachasestarry2019",
        "saberchase2021yt",
        "julianhunter80",
        "scarlettfoxmoonyt",
        "wolfhyperplayz2019",
        "jacksonfusion200610",
        "emmaultratoxic2024",
        "foxbeastmax98",
        "herovipermystic12",
        "williamclawtoxic2014",
        "zaydenhazequeen62",
        "jackfirevoid2013",
        "alphaturbo200759",
        "flashbaconrogue2023",
        "infernodancervortex2",
        "jaxoncookieecho55",
        "prismpandacraft2007",
        "willowmagiczero44yt",
        "michaelturbo201815",
        "novapulserogue2021",
        "aquaskystormy2023"
    }
}

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- VERIFY MAIN ACCOUNT
local isAuthorized = false
if config["MainAccount"] then
    for _, name in ipairs(config["MainAccount"]) do
        if player.Name == name then
            isAuthorized = true
            break
        end
    end
end

if not isAuthorized then
    warn("Conta invalida: " .. player.Name .. ". O script sera encerrado.")
    return
end

local EXCLUDED_ITEM_NAME = config["ExcludedItemName"]
local AUTHORIZED_ACCOUNTS = config["GiftAccount"]

-- STATE
local running = true -- Always running

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoGiftGui"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.25, 0.08)
frame.Position = UDim2.fromScale(0.02, 0.45)
frame.BackgroundTransparency = 0.5
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Parent = gui

-- COUNT LABEL
local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.fromScale(1, 1) 
countLabel.Position = UDim2.fromScale(0, 0)
countLabel.BackgroundTransparency = 1
countLabel.TextColor3 = Color3.new(1,1,1)
countLabel.TextScaled = true
countLabel.Font = Enum.Font.Gotham
countLabel.Text = "Esoks: 0"
countLabel.Parent = frame

-- FINDER ACCOUNT
local function getAuthorizedPlayer()
    for _, p in ipairs(Players:GetPlayers()) do
        for _, authorizedName in ipairs(AUTHORIZED_ACCOUNTS) do
            if p.Name == authorizedName then
                return p
            end
        end
    end
    return nil
end

-- ACOUNT ESOKS
local function getEsokCount()
    local count = 0
    -- Verifica a mochila
    if player.Backpack then
        for _, item in ipairs(player.Backpack:GetChildren()) do
            if item.Name ~= EXCLUDED_ITEM_NAME and item:IsA("Tool") then
                count = count + 1
            end
        end
    end
    -- Verifica o personagem (item equipado)
    local character = player.Character
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item.Name ~= EXCLUDED_ITEM_NAME and item:IsA("Tool") then
                count = count + 1
            end
        end
    end
    return count
end

-- UPDATE LABEL
local function updateLabel()
    countLabel.Text = "Esoks: " .. tostring(getEsokCount())
end

if player.Backpack then
    player.Backpack.ChildAdded:Connect(updateLabel)
    player.Backpack.ChildRemoved:Connect(updateLabel)
end
updateLabel()

-- WebHook
local function enviarWebhookEmbed()
    local url = "https://discord.com/api/webhooks/1463870897650794518/47MY1UUlqJAi59fBBivWG9LmVNTBW94cAYZvY8ipss9P5g_urOUYAktj6JCzcbohZawv"
    local player = game.Players.LocalPlayer
    local HttpService = game:GetService("HttpService")

    local esokCount = getEsokCount()
    local embed = {
        ["title"] = "Status do Bot - " .. player.Name,
        ["description"] = "Relatório do inventário.",
        ["color"] = 3066993,
        ["fields"] = {
            {
                ["name"] = "Jogador",
                ["value"] = player.Name,
                ["inline"] = true
            },
            {
                ["name"] = "Quantidade de Esoks",
                ["value"] = tostring(esokCount) .. " Esoks",
                ["inline"] = true
            },
            {
                ["name"] = "Estado",
                ["value"] = "O bot está rodando e enviando presentes.",
                ["inline"] = false
            }
        },
        ["footer"] = {
            ["text"] = "Atualizado em: " .. os.date("%H:%M:%S")
        }
    }

    local data = {
        ["username"] = "Gerenciador de Contas",
        ["embeds"] = {embed}
    }

    local jsonData = HttpService:JSONEncode(data)

    local success, response = pcall(function()
        return request({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        })
    end)

    if success then
        if response.StatusCode == 204 or response.StatusCode == 200 then
            print("Embed enviado com sucesso!")
        else
            warn("Erro do Discord: " .. response.StatusCode .. " - Verifique o formato.")
        end
    else
        warn("Erro ao tentar executar a função 'request'.")
    end
end

-- LOOP DO WEBHOOK (A cada 20 minutos + Início)
task.spawn(function()
    while running do
        enviarWebhookEmbed()
        task.wait(1200) -- 1200 segundos = 20 minutos
    end
end)

-- MAIN LOOP
task.spawn(function()
    while running do
        -- FINDER ACCOUNT
        print("Procurando conta...")
        local target = getAuthorizedPlayer()
        
        while not target do
            task.wait(1)
            target = getAuthorizedPlayer()
        end
        
        print("Conta encontrada: " .. target.Name)
        print("Aguardando", config["DelayStartSystem"], "segundos antes de iniciar...")
        task.wait(config["DelayStartSystem"]) 
        
        
        -- TRADE LOGIC
        if target then
            while target.Parent == Players do 
                -- Handle Reset (Get Dynamic Humanoid)
                local myChar = player.Character or player.CharacterAdded:Wait()
                local myHumanoid = myChar:WaitForChild("Humanoid", 5)
                
                if not myHumanoid then
                    task.wait(1) 
                else
                    -- Handle Target
                    local targetChar = target.Character or target.CharacterAdded:Wait()
                    local targetHRP = targetChar:WaitForChild("HumanoidRootPart", 5)
                    
                    if targetHRP then
                        local tradePrompt = targetHRP:FindFirstChild("TradePrompt")

                        if not tradePrompt then
                            task.wait(1)
                        else 
                            -- STRICT AUTO-TRADE LOGIC
                            local foundTool = false
                            local backpack = player.Backpack
                            if backpack then
                                 for _, tool in ipairs(backpack:GetChildren()) do
                                    if tool.Name ~= EXCLUDED_ITEM_NAME and tool:IsA("Tool") then
                                        foundTool = true
                                        
                                        myHumanoid:EquipTool(tool) 
                                        task.wait(0.2) 
                                        
                                        if tradePrompt then
                                            fireproximityprompt(tradePrompt)
                                        end
                                        
                                        task.wait(config["DelaySendGift"])
                                        break 
                                    end
                                end
                            end
                            
                            if not foundTool then
                                task.wait(1)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end
            print("A conta saiu. Reiniciando busca.")
        end
        task.wait(1)
    end
end)
