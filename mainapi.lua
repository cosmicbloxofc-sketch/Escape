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
local ValuesTab = Window:CreateTab("Values", 4483362458)
local OtherTab = Window:CreateTab("Others", 4483362458)

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local giftingToggle
local autoAcceptToggle

-- SALES API CONFIG
local API_KEY = "Deas231asnncasjk321312267a412sSasagnz"
local BASE_URL = "https://xssurcewybxaprixrlyz.supabase.co/functions/v1"

local itemSalesMapping = {
    ["Bulbito Bandito Traktorito"] = {endpoint = "/register-bulbito", valor = 49.90},
    ["Burgerini Bearini"] = {endpoint = "/register-burgerini", valor = 29.90},
    ["Strawberry Elephant"] = {endpoint = "/register-strawberry", valor = 39.90},
    ["Martino Gravitino"] = {endpoint = "/register-martino", valor = 59.90},
    ["Galactio Fantasma"] = {endpoint = "/register-galactio", valor = 44.90},
    ["Esok Sekolah"] = {endpoint = "/register-esok", valor = 34.90}
}

local function saveValues()
    local data = {}
    for name, mapping in pairs(itemSalesMapping) do
        data[name] = mapping.valor
    end
    writefile("SalesValues.json", HttpService:JSONEncode(data))
end

local function loadValues()
    if isfile and isfile("SalesValues.json") then
        local success, content = pcall(function() return readfile("SalesValues.json") end)
        if success then
            local data = HttpService:JSONDecode(content)
            for name, value in pairs(data) do
                if itemSalesMapping[name] then
                    itemSalesMapping[name].valor = value
                end
            end
        end
    end
end

-- Load values before creating UI
loadValues()

-- Create Values Tab Inputs
for itemName, mapping in pairs(itemSalesMapping) do
    ValuesTab:CreateInput({
        Name = "Valor: " .. itemName,
        PlaceholderText = tostring(mapping.valor),
        RemoveTextAfterFocusLost = false,
        Callback = function(Text)
            local num = tonumber(Text)
            if num then
                itemSalesMapping[itemName].valor = num
                saveValues()
                Rayfield:Notify({Title = "Salvo", Content = "Valor de " .. itemName .. " atualizado para " .. num, Duration = 2})
            end
        end,
    })
end

local function registrarVenda(itemName, cliente, mutation)
    local mapping = itemSalesMapping[itemName]
    if not mapping then return end
    
    local url = BASE_URL .. mapping.endpoint
    local body = HttpService:JSONEncode({
        cliente = cliente,
        valor = mapping.valor,
        vendedor = player.Name,
        quantidade = 1,
        mutation = mutation or "Normal"
    })
    
    local requestFunction = http_request or request or (syn and syn.request) or (http and http.request)
    if requestFunction then
        task.spawn(function()
            local success, response = pcall(function()
                return requestFunction({
                    Url = url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["x-api-key"] = API_KEY
                    },
                    Body = body
                })
            end)
            if success then
                print("DEBUG: Venda registrada para", itemName, "(", mutation, ") Valor:", mapping.valor)
            else
                warn("DEBUG: Erro ao registrar venda:", response)
            end
        end)
    end
end

local function atualizarEstoque(produto, quantidade, mutation)
    local url = BASE_URL:gsub("/v1", "") .. "/v1/update-stock"
    local body = HttpService:JSONEncode({
        pessoa = player.Name,
        produto = produto,
        quantidade = quantidade,
        mutation = mutation or "Normal"
    })
    
    local requestFunction = http_request or request or (syn and syn.request) or (http and http.request)
    if requestFunction then
        task.spawn(function()
            local success, response = pcall(function()
                return requestFunction({
                    Url = url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["x-api-key"] = API_KEY
                    },
                    Body = body
                })
            end)
            if success then
                print("DEBUG: Estoque atualizado para", produto, "(", mutation, "):", quantidade)
            else
                local err = response or "Sem resposta"
                warn("DEBUG: Erro ao atualizar estoque:", produto, mutation, err)
            end
        end)
    end
end

local function registrarContaVazia(produto, mutation)
    local url = "https://xssurcewybxaprixrlyz.supabase.co/functions/v1/add-empty-account"
    local body = HttpService:JSONEncode({
        pessoa = player.Name,
        produto = produto or "Peck Esok",
        mutation = mutation or "Normal"
    })
    
    local requestFunction = http_request or request or (syn and syn.request) or (http and http.request)
    if requestFunction then
        task.spawn(function()
            local success, response = pcall(function()
                return requestFunction({
                    Url = url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["x-api-key"] = API_KEY
                    },
                    Body = body
                })
            end)
            if success then
                print("DEBUG: Conta vazia registrada")
            else
                warn("DEBUG: Erro ao registrar conta vazia:", response)
            end
        end)
    end
end

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
   Name = "Ativar Webhook",
   CurrentValue = false,
   Flag = "WebhookToggle",
   Callback = function(Value)
        webhookEnabled = Value
   end,
})



local antiLagConnection = nil
local antiLagLoopActive = false

OtherTab:CreateToggle({
   Name = "Anti Lag (Limpeza)",
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
   Name = "Tela Branca (Anti Lag)",
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
            Rayfield:Notify({Title = "Conflito", Content = "Auto Gift desativado", Duration = 3})
        end

        if Value then
            task.spawn(function()
                while autoAcceptEnabled do
                    task.wait(0.5)
                    pcall(function()
                         -- 1. Unequip All Tools
                        if player.Character and player.Character:FindFirstChild("Humanoid") then
                            player.Character.Humanoid:UnequipTools()
                        end

                        -- 2. Check for Trade Request
                        local playerGui = player:WaitForChild("PlayerGui", 2)
                        if playerGui then
                            local tradeRequest = playerGui:FindFirstChild("TradeRequest")
                            if tradeRequest and tradeRequest:FindFirstChild("Main") then
                                local main = tradeRequest.Main
                                local acceptBtn = main:FindFirstChild("Accept")
                                
                                if acceptBtn and acceptBtn.Visible then
                                    print("Aceitando trade...")
                                    fastClick(acceptBtn)
                                end
                            end
                        end
                    end)
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
                    atualizarEstoque(itemName, currentQty, variant)
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
                registrarContaVazia("Peck Esok", "Normal")
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
   Name = "Selecionar Player",
   Options = getPlayerList(),
   CurrentOption = "",
   MultipleOptions = false,
   Flag = "PlayerDropdown",
   Callback = function(Option)
        selectedTargetName = Option[1]
   end,
})

GiftTab:CreateButton({
   Name = "Atualizar Lista de Players",
   Callback = function()
        PlayerDropdown:Refresh(getPlayerList(), true)
   end,
})

-- NEW: Item Selection Dropdown
GiftTab:CreateDropdown({
   Name = "Selecionar Item para Enviar",
   Options = brainrotItems,
   CurrentOption = "Strawberry Elephant",
   MultipleOptions = false,
   Flag = "ItemDropdown",
   Callback = function(Option)
        selectedItemName = Option[1]
   end,
})

GiftTab:CreateInput({
   Name = "Quantidade para Enviar",
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
            Rayfield:Notify({Title = "Conflito", Content = "Auto Accept desativado", Duration = 3})
        end
        
        if isGifting then
            if not selectedTargetName then
                Rayfield:Notify({Title = "Erro", Content = "Selecione um player", Duration = 3})
                giftingToggle:Set(false)
                return 
            end

            task.spawn(function()
                local target = Players:FindFirstChild(selectedTargetName)
                if not target then 
                     giftingToggle:Set(false)
                     return 
                end

                local startTotal = getBrainrotCount(selectedItemName)

                -- CHECK: Zero Stock (No webhook, just stop)
                if startTotal == 0 then
                     Rayfield:Notify({Title = "Sem Estoque", Content = "Você não tem nenhuma " .. selectedItemName, Duration = 0})
                     if giftingToggle then giftingToggle:Set(false) end
                     return
                end

                local stopTarget = startTotal - giftQuantity
                if stopTarget < 0 then stopTarget = 0 end 

                if giftQuantity == 999 then
                    stopTarget = -1 
                end
                
                -- VALIDATION: Check Missing
                if giftQuantity ~= 999 and startTotal < giftQuantity then
                    local missing = giftQuantity - startTotal
                    Rayfield:Notify({Title = "Aviso", Content = "Faltam " .. missing .. " " .. selectedItemName .. " para a meta", Duration = 5})
                    
                    sendWebhook(
                        "Estoque Insuficiente",
                        "O envio começou mas faltam itens.",
                        16711680, -- Red
                        {
                            {["name"] = "Enviado Por", ["value"] = player.Name, ["inline"] = true},
                            {["name"] = "Para", ["value"] = target.Name, ["inline"] = true},
                            {["name"] = "Item", ["value"] = selectedItemName, ["inline"] = true},
                            {["name"] = "Disponivel", ["value"] = tostring(startTotal), ["inline"] = true},
                            {["name"] = "Solicitado", ["value"] = tostring(giftQuantity), ["inline"] = true},
                            {["name"] = "Falta", ["value"] = tostring(missing), ["inline"] = true}
                        }
                    )
                end

                Rayfield:Notify({Title = "Iniciando", Content = "Item: " .. selectedItemName .. " | Alvo: " .. target.Name, Duration = 3})

                while isGifting do
                     local target = Players:FindFirstChild(selectedTargetName)
                     if not target or not target.Parent then
                         local sentSoFar = startTotal - getBrainrotCount(selectedItemName)
                         local targetGoal = (giftQuantity == 999 and "Infinito" or tostring(giftQuantity))
                         Rayfield:Notify({
                             Title = "Erro: Alvo Saiu", 
                             Content = "O player " .. selectedTargetName .. " saiu. Enviados: " .. sentSoFar .. "/" .. targetGoal, 
                             Duration = 60
                         })
                         isGifting = false
                         giftingToggle:Set(false)
                         break
                     end

                     local currentTotal = getBrainrotCount(selectedItemName)
                     
                     -- Stop condition
                     if giftQuantity ~= 999 and currentTotal <= stopTarget then
                        Rayfield:Notify({Title = "Concluido", Content = "Envio finalizado", Duration = 0})
                        
                        local sentAmount = startTotal - currentTotal
                        sendWebhook(
                            "Envio Finalizado",
                            "O processo de envio foi concluido.",
                            65280, -- Green
                            {
                                {["name"] = "Enviado Por", ["value"] = player.Name, ["inline"] = true},
                                {["name"] = "Para", ["value"] = target.Name, ["inline"] = true},
                                {["name"] = "Item", ["value"] = selectedItemName, ["inline"] = true},
                                {["name"] = "Total Enviado", ["value"] = tostring(sentAmount), ["inline"] = true}
                            }
                        )

                        isGifting = false
                        giftingToggle:Set(false)
                        break
                     end
                     
                     if currentTotal == 0 then
                        Rayfield:Notify({Title = "Vazio", Content = "Acabaram: " .. selectedItemName, Duration = 0})
                        
                        local sentAmount = startTotal - currentTotal
                        sendWebhook(
                            "Estoque Zerado",
                            "O envio parou pois o estoque acabou.",
                            16776960, -- Yellow
                            {
                                {["name"] = "Enviado Por", ["value"] = player.Name, ["inline"] = true},
                                {["name"] = "Para", ["value"] = target.Name, ["inline"] = true},
                                {["name"] = "Item", ["value"] = selectedItemName, ["inline"] = true},
                                {["name"] = "Total Enviado", ["value"] = tostring(sentAmount), ["inline"] = true}
                            }
                        )

                        isGifting = false
                        giftingToggle:Set(false)
                        break
                     end

                     local foundTool = false
                     local myChar = player.Character
                     local myHum = myChar and myChar:FindFirstChild("Humanoid")
                     local myBackpack = player.Backpack
                     
                     if myHum and myBackpack then
                        -- PRIORITY 1: Check tools in Backpack
                        for _, tool in ipairs(myBackpack:GetChildren()) do
                             if not isGifting then break end
                             
                             local isMatch, itemMut = isBrainrot(tool, selectedItemName)
                             if isMatch then
                                 foundTool = true
                                 myHum:EquipTool(tool)
                                 task.wait(0.2)
                                 
                                 -- If tool equipped, verify Target again
                                 if target.Parent and target.Character then
                                     local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                                     if targetHRP then
                                         local tradePrompt = targetHRP:FindFirstChild("TradePrompt")
                                         if tradePrompt then
                                             fireproximityprompt(tradePrompt)
                                         end
                                     end
                                 end
                                 task.wait(1)
                                 
                                 if getBrainrotCount(selectedItemName) < currentTotal then
                                     Rayfield:Notify({Title = "Enviado", Content = selectedItemName .. " enviado!", Duration = 2})
                                     registrarVenda(selectedItemName, selectedTargetName, itemMut)
                                 end
                                 break 
                             end
                        end
                        
                        -- PRIORITY 2: If no tool found in backpack, check if we are holding it already
                        if not foundTool then
                            for _, tool in ipairs(myChar:GetChildren()) do
                                local isMatch, itemMut = isBrainrot(tool, selectedItemName)
                                if isMatch and tool:IsA("Tool") then
                                    foundTool = true
                                    -- Already equipped, just trade
                                    if target.Parent and target.Character then
                                        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                                        if targetHRP then
                                            local tradePrompt = targetHRP:FindFirstChild("TradePrompt")
                                            if tradePrompt then
                                                fireproximityprompt(tradePrompt)
                                            end
                                        end
                                    end
                                    task.wait(1)
                                    
                                    if getBrainrotCount(selectedItemName) < currentTotal then
                                        Rayfield:Notify({Title = "Enviado", Content = selectedItemName .. " enviado!", Duration = 2})
                                        registrarVenda(selectedItemName, selectedTargetName, itemMut)
                                    end
                                    break
                                end
                            end
                        end
                     end
                     
                     if not foundTool then
                         -- No tool found anywhere?
                         Rayfield:Notify({Title = "Info", Content = "Nenhum(a) " .. selectedItemName .. " encontrado(a).", Duration = 0})
                         isGifting = false
                         giftingToggle:Set(false)
                         break
                     end
                     
                     task.wait(0.1)
                end
            end)
        end
   end,
})

Rayfield:LoadConfiguration()
