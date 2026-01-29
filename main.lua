repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Script Trade",
   LoadingTitle = "Loading...", 
   LoadingSubtitle = "By Cosmic Group",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "ScriptTrade",
      FileName = "config"
   },
})

local GiftTab = Window:CreateTab("Gift", 4483362458)
local AcceptTab = Window:CreateTab("Accept", 4483362458)
local StatusTab = Window:CreateTab("Status", 4483362458)
local HistoryTab = Window:CreateTab("History", 4483362458)
local OtherTab = Window:CreateTab("Others", 4483362458)

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Carregar módulos internos do jogo (Novo Modelo)
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local ClientGlobals = require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("ClientGlobals"))

local PlayerData = ClientGlobals.PlayerData
local ActiveTrade = ClientGlobals.ActiveTrade
local TradeRequests = ClientGlobals.TradeRequests

local giftingToggle
local autoAcceptToggle

local totalSentInSession = 0 -- Contador global para a sessão atual

local function addHistoryLog(title, content, color)
    HistoryTab:CreateSection(title)
    HistoryTab:CreateLabel(content)
end

local itemSalesMapping = {
    ["Bulbito Bandito Traktorito"] = {valor = 49.90},
    ["Burgerini Bearini"] = {valor = 29.90},
    ["Strawberry Elephant"] = {valor = 39.90},
    ["Martino Gravitino"] = {valor = 59.90},
    ["Galactio Fantasma"] = {valor = 44.90},
    ["Esok Sekolah"] = {valor = 34.90}
}

-- VALUES TAB REMOVED

-- SALES FUNCTIONS REMOVED

-- =========================================================================
--                               OTHERS TAB
-- =========================================================================

OtherTab:CreateButton({
   Name = "Anti AFK",
   Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/evxncodes/mainroblox/main/anti-afk", true))()
        Rayfield:Notify({
            Title = "Anti AFK",
            Content = "Anti AFK ativado",
            Duration = 6.5,
            Image = 4483362458,
        })
   end,
})

-- WEBHOOK SYSTEM
local webhookUrl = ""
local webhookEnabled = false

local function sendWebhook(title, description, color, fields)
    if not webhookEnabled or webhookUrl == "" then 
        warn("Webhook skipped: Disabled or Empty URL")
        return 
    end
    
    local data = {
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["fields"] = fields,
            ["footer"] = {
                ["text"] = "Trade - " .. os.date("%x %X")
            }
        }}
    }
    
    local jsonData = HttpService:JSONEncode(data)
    local headers = {["Content-Type"] = "application/json"}
    
    local requestFunction = http_request or request or (syn and syn.request) or (http and http.request)
    
    print("DEBUG: Sending Webhook...", title)
    if requestFunction then
        local success, response = pcall(function()
            return requestFunction({
                Url = webhookUrl,
                Method = "POST",
                Headers = headers,
                Body = jsonData
            })
        end)
        
        if success then
            print("DEBUG: Webhook Sent! Code:", response and response.StatusCode)
        else
            warn("DEBUG: Webhook Failed:", response)
        end
    else
        warn("DEBUG: No HTTP Request function found!")
    end
end

OtherTab:CreateInput({
   Name = "Webhook URL",
   PlaceholderText = "https://discord.com/api/webhooks/...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        webhookUrl = Text
   end,
})

OtherTab:CreateToggle({
   Name = "Enable Webhook",
   CurrentValue = false,
   Flag = "WebhookToggle",
   Callback = function(Value)
        webhookEnabled = Value
   end,
})



local antiLagConnection = nil
local antiLagLoopActive = false

OtherTab:CreateToggle({
   Name = "Anti Lag (Cleanup)",
   CurrentValue = false,
   Flag = "AntiLagToggle",
   Callback = function(Value)
        if Value then
            -- 1. Immediate Sweep
            for _, item in ipairs(workspace:GetDescendants()) do
                if item:IsA("Model") and item.Name == "LuckyBlockRig_Admin" then
                    pcall(function() item:Destroy() end)
                end
            end
            
            -- 2. Aggressive Connection
            antiLagConnection = workspace.DescendantAdded:Connect(function(descendant)
                if descendant ~= player.Character and not descendant:IsDescendantOf(player.Character) then
                    pcall(function() 
                        if descendant.Name == "LuckyBlockRig_Admin" then
                            descendant:Destroy()
                        elseif descendant:IsA("BasePart") and not descendant.Anchored and descendant.Name ~= "Baseplate" then
                            descendant:Destroy()
                        end
                    end)
                end
            end)
            
            -- 3. Cleanup Loop
            antiLagLoopActive = true
            task.spawn(function()
                while antiLagLoopActive do
                    for _, item in ipairs(workspace:GetChildren()) do
                        if item.Name == "LuckyBlockRig_Admin" then
                            pcall(function() item:Destroy() end)
                        elseif item:IsA("BasePart") and not item.Anchored and item.Name ~= "Baseplate" then
                            pcall(function() item:Destroy() end)
                        end
                    end
                    task.wait(2)
                end
            end)
        else
            antiLagLoopActive = false
            if antiLagConnection then
                antiLagConnection:Disconnect()
                antiLagConnection = nil
            end
        end
   end,
})

OtherTab:CreateToggle({
   Name = "White Screen (Anti Lag)",
   CurrentValue = false,
   Flag = "WhiteScreenToggle",
   Callback = function(Value)
        game:GetService("RunService"):Set3dRenderingEnabled(not Value)
   end,
})




-- =========================================================================
--                               ACCEPT TAB
-- =========================================================================

local autoAcceptEnabled = false

local function fastClick(btn)
    if getconnections then
        for _, connection in pairs(getconnections(btn.MouseButton1Click)) do
            connection:Fire()
        end
        for _, connection in pairs(getconnections(btn.MouseButton1Down)) do
            connection:Fire()
        end
        for _, connection in pairs(getconnections(btn.Activated)) do
            connection:Fire()
        end
    else
        VirtualUser:ClickButton1(Vector2.new(btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y / 2))
    end
end

autoAcceptToggle = AcceptTab:CreateToggle({
   Name = "Auto Accept",
   CurrentValue = false,
   Flag = "AutoAcceptToggle",
   Callback = function(Value)
        autoAcceptEnabled = Value
        
        -- Conflict Resolution: Turn off Gifting if enabled
        if autoAcceptEnabled and isGifting then
            isGifting = false
            if giftingToggle then giftingToggle:Set(false) end
            Rayfield:Notify({Title = "Conflict", Content = "Auto Gift disabled", Duration = 3})
        end

        if Value then
            task.spawn(function()
                while autoAcceptEnabled do
                    -- 1. Aceitar Pedidos via Remote (script-accept.lua mode)
                    local requests = TradeRequests:TryIndex({}) or {}
                    for requestId, data in pairs(requests) do
                        pcall(function()
                            Net:RemoteFunction("Trade.RespondToTradeOffer"):InvokeServer(requestId, true)
                        end)
                    end

                    -- 2. Confirmar Troca Automática (Ready) com Resiliência
                    local guid = ActiveTrade:TryIndex({"guid"})
                    if guid then
                        local isReady = ActiveTrade:TryIndex({"player1", "ready"})
                        if not isReady then
                            -- Verifica a trava de 3 segundos
                            local lastUpdate = ActiveTrade:TryIndex({"timers", "lastUpdate"}) or 0
                            local serverTime = workspace:GetServerTimeNow()
                            
                            if serverTime > (lastUpdate + 3.1) then
                                pcall(function()
                                    Net:RemoteEvent("Trade.ReadyTrade"):FireServer(true)
                                end)
                            end
                        end
                    end

                    -- MANTÉM LÓGICA ANTIGA (UI CLICK) COMO BACKUP
                    pcall(function()
                        local playerGui = player:WaitForChild("PlayerGui", 2)
                        if playerGui then
                            local tradeRequest = playerGui:FindFirstChild("TradeRequest")
                            if tradeRequest and tradeRequest:FindFirstChild("Main") then
                                local main = tradeRequest.Main
                                local acceptBtn = main:FindFirstChild("Accept")
                                if acceptBtn and acceptBtn.Visible then
                                    fastClick(acceptBtn)
                                end
                            end
                        end
                    end)
                    
                    task.wait(1)
                end
            end)
        end
   end,
})

-- =========================================================================
--                                GIFT TAB
-- =========================================================================

local selectedTargetName = nil
local selectedItemName = "Strawberry Elephant" -- Default
local giftQuantity = 10
local isGifting = false

local brainrotItems = {
    "Bulbito Bandito Traktorito",
    "Burgerini Bearini",
    "Strawberry Elephant",
    "Martino Gravitino",
    "Galactio Fantasma",
    "Esok Sekolah"
}

-- Function to check if a tool is a valid brainrot based on Attribute
local function isBrainrot(tool, targetName)
    if not tool or not tool:IsA("Tool") then return false, nil end
    
    -- Helper to get attribute from object
    local function getAttr(obj, key)
        return obj:GetAttribute(key) or obj:GetAttribute(key:lower())
    end

    -- Check for BrainrotName match
    local name = getAttr(tool, "BrainrotName")
    local model = tool:FindFirstChild("RenderModel")
    if not name and model then
        name = getAttr(model, "BrainrotName")
    end

    if name == targetName then
        -- Check for Mutation
        local mut = getAttr(tool, "Mutation")
        if (not mut or mut == "" or mut == "None") and model then
            mut = getAttr(model, "Mutation")
        end

        if not mut or mut == "" or mut == "None" then
            mut = "Normal"
        end
        return true, mut
    end

    return false, nil
end

-- Function to get TOTAL count for a specific item
local function getBrainrotCount(name)
    local count = 0
    if player.Backpack then
        for _, item in ipairs(player.Backpack:GetChildren()) do
            local isMatch = isBrainrot(item, name)
            if isMatch then count = count + 1 end
        end
    end
    if player.Character then
        for _, item in ipairs(player.Character:GetChildren()) do
            local isMatch = isBrainrot(item, name)
            if isMatch then count = count + 1 end
        end
    end
    return count
end

local mutationsList = {"Admin", "Blood", "Diamond", "Electric", "Emerald", "Gold", "Hacker", "Lucky", "Radioactive", "UFO"}

local function getBrainrotDetailedCount(name)
    local stats = {Total = 0, Normal = 0}
    for _, m in ipairs(mutationsList) do stats[m] = 0 end
    
    local function process(container)
        for _, item in ipairs(container:GetChildren()) do
            local isMatch, mut = isBrainrot(item, name)
            if isMatch then
                stats.Total = stats.Total + 1
                stats[mut] = (stats[mut] or 0) + 1
            end
        end
    end
    
    if player.Backpack then process(player.Backpack) end
    if player.Character then process(player.Character) end
    
    return stats
end

-- MONITOR LABELS
local labels = {}
for _, itemName in ipairs(brainrotItems) do
    labels[itemName] = StatusTab:CreateLabel(itemName .. ": 0")
end

-- Loop to update Monitor
local lastCounts = {} -- Store per item+mutation
local variants = {"Normal"}
for _, m in ipairs(mutationsList) do table.insert(variants, m) end

task.spawn(function()
    local hasNotifiedEmpty = false
    while true do
        local grandTotal = 0
        for itemName, label in pairs(labels) do
            local stats = getBrainrotDetailedCount(itemName)
            grandTotal = grandTotal + stats.Total
            
            -- Sync with API for each variant
            for _, variant in ipairs(variants) do
                local key = itemName .. "_" .. variant
                local currentQty = stats[variant] or 0
                
                if currentQty ~= lastCounts[key] then
                    lastCounts[key] = currentQty
                    -- atualizarEstoque removed
                end
            end

            local text = itemName .. ": " .. stats.Total
            
            local mutStrings = {}
            if stats.Normal > 0 then table.insert(mutStrings, "Normal: " .. stats.Normal) end
            for _, m in ipairs(mutationsList) do
                if stats[m] and stats[m] > 0 then
                    table.insert(mutStrings, m .. ": " .. stats[m])
                end
            end
            
            if #mutStrings > 0 then
                text = text .. " (" .. table.concat(mutStrings, ", ") .. ")"
            end
            
            label:Set(text)
        end
        
        if grandTotal == 0 then
            if not hasNotifiedEmpty then
                hasNotifiedEmpty = true
                -- registrarContaVazia removed
            end
        else
            hasNotifiedEmpty = false
        end
        
        task.wait(1.5)
    end
end)

-- Function to get player list for dropdown
local function getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(list, p.Name)
        end
    end
    return list
end



local PlayerDropdown = GiftTab:CreateDropdown({
   Name = "Select Player",
   Options = getPlayerList(),
   CurrentOption = "",
   MultipleOptions = false,
   Flag = "PlayerDropdown",
   Callback = function(Option)
        selectedTargetName = Option[1]
   end,
})

GiftTab:CreateButton({
   Name = "Refresh Player List",
   Callback = function()
        PlayerDropdown:Refresh(getPlayerList(), true)
   end,
})

-- NEW: Item Selection Dropdown
GiftTab:CreateDropdown({
   Name = "Select Item to Send",
   Options = brainrotItems,
   CurrentOption = "Strawberry Elephant",
   MultipleOptions = false,
   Flag = "ItemDropdown",
   Callback = function(Option)
        selectedItemName = Option[1]
   end,
})

GiftTab:CreateInput({
   Name = "Quantity to Send",
   PlaceholderText = "10",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local num = tonumber(Text)
        if num then
            giftQuantity = num
        end
    end,
})

giftingToggle = GiftTab:CreateToggle({
   Name = "Auto Gift",
   CurrentValue = false,
   Flag = "StartGiftingToggle",
   Callback = function(Value)
        isGifting = Value
        
        -- Conflict Resolution: Turn off Auto Accept if enabled
        if isGifting and autoAcceptEnabled then
            autoAcceptEnabled = false
            if autoAcceptToggle then autoAcceptToggle:Set(false) end
            Rayfield:Notify({Title = "Conflict", Content = "Auto Accept disabled", Duration = 3})
        end
        
        if isGifting then
            if not selectedTargetName then
                Rayfield:Notify({Title = "Error", Content = "Select a player", Duration = 3})
                giftingToggle:Set(false)
                return 
            end

            task.spawn(function()
                local itemJaAdicionado = false
                totalSentInSession = 0 -- Reseta ao iniciar novo envio
                
                addHistoryLog("Sessão Iniciada", "Iniciando envio para: " .. selectedTargetName .. "\nObjetivo: " .. (giftQuantity == 999 and "Infinito" or giftQuantity) .. " itens.", Color3.fromRGB(0, 255, 255))

                -- Função interna para achar IDs e Mutações
                local function findItemData(itemName)
                    local data = {}
                    local inventory = PlayerData:TryIndex({"Inventory"}) or {}
                    for id, item in pairs(inventory) do
                        if item.name == itemName or (item.sub and item.sub.mutation == itemName) then
                            local mutation = "Normal"
                            if item.sub and item.sub.mutation and item.sub.mutation ~= "" and item.sub.mutation ~= "None" then
                                mutation = item.sub.mutation
                            end
                            table.insert(data, {id = id, mutation = mutation})
                        end
                    end
                    return data
                end

                local lastInventoryCount = getBrainrotCount(selectedItemName)

                while isGifting do
                    local target = Players:FindFirstChild(selectedTargetName)
                    
                    -- Verifica se o alvo saiu
                    if not target then
                        addHistoryLog("ERRO: Alvo Saiu", "O jogador " .. selectedTargetName .. " kito do servidor!", Color3.fromRGB(255, 0, 0))
                        isGifting = false
                        giftingToggle:Set(false)
                        break
                    end

                    -- Verifica se já atingiu o limite
                    if giftQuantity ~= 999 and totalSentInSession >= giftQuantity then
                        addHistoryLog("CONCLUÍDO", "Meta atingida: " .. totalSentInSession .. "/" .. giftQuantity, Color3.fromRGB(0, 255, 0))
                        isGifting = false
                        giftingToggle:Set(false)
                        break
                    end

                    local guid = ActiveTrade:TryIndex({"guid"})
                    
                    if not guid then
                        -- Detecta fim de trade e conta itens enviados
                        local currentInv = getBrainrotCount(selectedItemName)
                        if currentInv < lastInventoryCount then
                            local sentThisTrade = lastInventoryCount - currentInv
                            totalSentInSession = totalSentInSession + sentThisTrade
                            addHistoryLog("Troca Concluída", "Enviados +" .. sentThisTrade .. " itens com sucesso!\nTotal na sessão: " .. totalSentInSession .. "/" .. (giftQuantity == 999 and "Infinito" or giftQuantity), Color3.fromRGB(0, 255, 0))
                        end
                        lastInventoryCount = currentInv

                        -- MANDA TRADE
                        pcall(function()
                            Net:RemoteFunction("Trade.SendTrade"):InvokeServer(target)
                        end)
                        itemJaAdicionado = false
                        task.wait(4)
                    else
                        -- JANELA ABERTA: ADICIONA NOS SLOTS COM VERIFICAÇÃO DE LAG
                        if not itemJaAdicionado then
                            local items = findItemData(selectedItemName)
                            local totalItemIds = #items
                            local remaining = (giftQuantity == 999) and 6 or (giftQuantity - totalSentInSession)
                            local toAddLimit = math.min(totalItemIds, math.min(6, remaining))

                            if toAddLimit > 0 then
                                local mutsUsed = {}
                                for i = 1, toAddLimit do
                                    local item = items[i]
                                    local slotStr = tostring(i)
                                    
                                    -- Tenta adicionar o item até o servidor confirmar que ele entrou no slot
                                    local addedSuccess = false
                                    local retryCount = 0
                                    
                                    repeat
                                        pcall(function()
                                            Net:RemoteFunction("Trade.SetSlotOffer"):InvokeServer(slotStr, item.id)
                                        end)
                                        
                                        -- Pequena espera pro servidor processar o pacote
                                        task.wait(0.2) 
                                        
                                        -- Verifica se o item apareceu na oferta do jogador1 do ActiveTrade
                                        local currentOffer = ActiveTrade:TryIndex({"player1", "offer"}) or {}
                                        if currentOffer[slotStr] and currentOffer[slotStr].id == item.id then
                                            addedSuccess = true
                                        else
                                            retryCount = retryCount + 1
                                            task.wait(0.3) -- Espera um pouco mais se falhou (lag)
                                        end
                                    until addedSuccess or retryCount > 5 or not isGifting or not ActiveTrade:TryIndex({"guid"})
                                    
                                    if addedSuccess then
                                        table.insert(mutsUsed, item.mutation)
                                    end
                                end
                                
                                itemJaAdicionado = true
                                addHistoryLog("Itens nos Slots", "Adicionado " .. #mutsUsed .. "x " .. selectedItemName .. "\nMutações: " .. table.concat(mutsUsed, ", "), Color3.fromRGB(255, 255, 0))

                                -- CONFIRMAÇÃO RESILIENTE (READY)
                                task.spawn(function()
                                    local readyConfirmed = false
                                    local readyRetries = 0
                                    
                                    while not readyConfirmed and readyRetries < 20 and isGifting and ActiveTrade:TryIndex({"guid"}) do
                                        -- Verifica a trava de 3 segundos do servidor
                                        local lastUpdate = ActiveTrade:TryIndex({"timers", "lastUpdate"}) or 0
                                        local serverTime = workspace:GetServerTimeNow()
                                        
                                        if serverTime > (lastUpdate + 3.1) then
                                            pcall(function()
                                                Net:RemoteEvent("Trade.ReadyTrade"):FireServer(true)
                                            end)
                                            print("Tentativa de Ready enviada...")
                                        end
                                        
                                        task.wait(0.5) -- Checa a cada meio segundo
                                        
                                        -- Verifica se o servidor marcou como Ready
                                        if ActiveTrade:TryIndex({"player1", "ready"}) then
                                            readyConfirmed = true
                                            print("Ready confirmado pelo servidor!")
                                        else
                                            readyRetries = readyRetries + 1
                                        end
                                    end
                                end)
                                
                                Rayfield:Notify({Title = "Status de Lag", Content = "Sincronizando com o servidor...", Duration = 2})
                            else
                                if totalItemIds == 0 then
                                    addHistoryLog("ERRO: Sem Estoque", "Acabaram os " .. selectedItemName .. " do inventário!", Color3.fromRGB(255, 0, 0))
                                    isGifting = false
                                    giftingToggle:Set(false)
                                end
                                break
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
   end,
})

Rayfield:LoadConfiguration()
