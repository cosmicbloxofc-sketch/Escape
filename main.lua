local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Script Trade",
   LoadingTitle = "Loading...", 
   LoadingSubtitle = "By Cosmic Group",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ScriptTrade",
      FileName = "config"
   },
})

local GiftTab = Window:CreateTab("Gift", 4483362458)
local AcceptTab = Window:CreateTab("Accept", 4483362458)
local OtherTab = Window:CreateTab("Others", 4483362458)

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- =========================================================================
--                               OTHERS TAB
-- =========================================================================

OtherTab:CreateButton({
   Name = "Anti AFK",
   Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/evxncodes/mainroblox/main/anti-afk", true))()
        Rayfield:Notify({
            Title = "Anti AFK",
            Content = "Anti AFK ativado com sucesso!",
            Duration = 6.5,
            Image = 4483362458,
        })
   end,
})

-- WEBHOOK SYSTEM
local webhookUrl = ""
local webhookEnabled = false

local function sendWebhook(title, description, color, fields)
    if not webhookEnabled or webhookUrl == "" then return end
    
    local data = {
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["fields"] = fields,
            ["footer"] = {
                ["text"] = "Script Trade Pro - " .. os.date("%x %X")
            }
        }}
    }
    
    local jsonData = HttpService:JSONEncode(data)
    local headers = {["Content-Type"] = "application/json"}
    
    local requestFunction = http_request or request or (syn and syn.request) or (http and http.request)
    if requestFunction then
        requestFunction({
            Url = webhookUrl,
            Method = "POST",
            Headers = headers,
            Body = jsonData
        })
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

AcceptTab:CreateToggle({
   Name = "Auto Accept",
   CurrentValue = false,
   Flag = "AutoAcceptToggle",
   Callback = function(Value)
        autoAcceptEnabled = Value
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
local giftQuantity = 10
local isGifting = false

-- Function to check if a tool is a valid ESOK based on Attribute
local function isEsok(tool)
    if not tool or not tool:IsA("Tool") then return false end
    
    local renderModel = tool:FindFirstChild("RenderModel")
    if renderModel then
        -- Tenta buscar com a capitalização correta (conforme imagem)
        local attr = renderModel:GetAttribute("BrainrotName") 
        if attr == "Esok Sekolah" then
            return true
        end
        
        -- Fallback caso seja minúsculo
        local attrLower = renderModel:GetAttribute("brainrotname")
        if attrLower == "Esok Sekolah" then
             return true
        end
    end
    return false
end

-- Function to get TOTAL count (Backpack + Equipped)
local function getEsokCount()
    local count = 0
    
    -- Check Backpack
    if player.Backpack then
        for _, item in ipairs(player.Backpack:GetChildren()) do
            if isEsok(item) then
                count = count + 1
            end
        end
    end
    
    -- Check Character (Equipped)
    if player.Character then
        for _, item in ipairs(player.Character:GetChildren()) do
            if isEsok(item) then
                count = count + 1
            end
        end
    end
    
    return count
end

-- MONITOR LABEL
local countMonitor = GiftTab:CreateLabel("Total Esoks: 0")

-- Loop to update Monitor
task.spawn(function()
    while true do
        local amount = getEsokCount()
        countMonitor:Set("Total Esoks: " .. tostring(amount))
        task.wait(1)
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

GiftTab:CreateInput({
   Name = "Quantidade de Esoks",
   PlaceholderText = "10",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local num = tonumber(Text)
        if num then
            giftQuantity = num
        end
   end,
})

local giftingToggle -- Forward declaration

giftingToggle = GiftTab:CreateToggle({
   Name = "Iniciar Envio",
   CurrentValue = false,
   Flag = "StartGiftingToggle",
   Callback = function(Value)
        isGifting = Value
        
        if isGifting then
            if not selectedTargetName then
                Rayfield:Notify({Title = "Erro", Content = "Selecione um player!", Duration = 3})
                giftingToggle:Set(false)
                return 
            end

            task.spawn(function()
                local target = Players:FindFirstChild(selectedTargetName)
                if not target then 
                     giftingToggle:Set(false)
                     return 
                end

                local startTotal = getEsokCount()
                local stopTarget = startTotal - giftQuantity
                if stopTarget < 0 then stopTarget = 0 end 

                if giftQuantity == 999 then
                    stopTarget = -1 
                end
                
                -- VALIDATION: Check Missing
                if giftQuantity ~= 999 and startTotal < giftQuantity then
                    local missing = giftQuantity - startTotal
                    Rayfield:Notify({Title = "Aviso", Content = "Faltam " .. missing .. " Esoks para a meta!", Duration = 5})
                    
                    sendWebhook(
                        "Estoque Insuficiente",
                        "O envio começou mas faltam itens.",
                        16711680, -- Red
                        {
                            {["name"] = "Enviado Por", ["value"] = player.Name, ["inline"] = true},
                            {["name"] = "Para", ["value"] = target.Name, ["inline"] = true},
                            {["name"] = "Disponivel", ["value"] = tostring(startTotal), ["inline"] = true},
                            {["name"] = "Solicitado", ["value"] = tostring(giftQuantity), ["inline"] = true},
                            {["name"] = "Falta", ["value"] = tostring(missing), ["inline"] = true}
                        }
                    )
                end

                Rayfield:Notify({Title = "Iniciando", Content = "Total: " .. startTotal .. " | Meta paragem: " .. stopTarget, Duration = 3})

                while isGifting do
                     local currentTotal = getEsokCount()
                     
                     -- Stop condition
                     if giftQuantity ~= 999 and currentTotal <= stopTarget then
                        Rayfield:Notify({Title = "Concluido", Content = "Envio finalizado!", Duration = 3})
                        
                        local sentAmount = startTotal - currentTotal
                        sendWebhook(
                            "Envio Finalizado",
                            "O processo de envio foi concluido.",
                            65280, -- Green
                            {
                                {["name"] = "Enviado Por", ["value"] = player.Name, ["inline"] = true},
                                {["name"] = "Para", ["value"] = target.Name, ["inline"] = true},
                                {["name"] = "Total Enviado", ["value"] = tostring(sentAmount), ["inline"] = true}
                            }
                        )

                        isGifting = false
                        giftingToggle:Set(false)
                        break
                     end
                     
                     if currentTotal == 0 then
                        Rayfield:Notify({Title = "Vazio", Content = "Acabaram as Esoks!", Duration = 3})
                        
                        local sentAmount = startTotal - currentTotal
                        sendWebhook(
                            "Estoque Zerado",
                            "O envio parou pois o estoque acabou.",
                            16776960, -- Yellow
                            {
                                {["name"] = "Enviado Por", ["value"] = player.Name, ["inline"] = true},
                                {["name"] = "Para", ["value"] = target.Name, ["inline"] = true},
                                {["name"] = "Total Enviado", ["value"] = tostring(sentAmount), ["inline"] = true},
                                {["name"] = "Restante Faltante", ["value"] = tostring(stopTarget - currentTotal), ["inline"] = true}
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
                             
                             if isEsok(tool) then
                                 foundTool = true
                                 myHum:EquipTool(tool)
                                 task.wait(0.2)
                                 
                                 -- If tool equipped, verify Target again
                                 if target.Parent and target.Character then
                                     local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                                     if targetHRP then
                                         local tradePrompt = targetHRP:FindFirstChild("TradePrompt")
                                         if tradePrompt then
                                             tradePrompt:InputHoldBegin()
                                             task.wait(tradePrompt.HoldDuration)
                                             tradePrompt:InputHoldEnd()
                                         end
                                     end
                                 end
                                 task.wait(1)
                                 break 
                             end
                        end
                        
                        -- PRIORITY 2: If no tool found in backpack, check if we are holding it already
                        if not foundTool then
                            for _, tool in ipairs(myChar:GetChildren()) do
                                if isEsok(tool) and tool:IsA("Tool") then
                                    foundTool = true
                                    -- Already equipped, just trade
                                    if target.Parent and target.Character then
                                        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                                        if targetHRP then
                                            local tradePrompt = targetHRP:FindFirstChild("TradePrompt")
                                            if tradePrompt then
                                                tradePrompt:InputHoldBegin()
                                                task.wait(tradePrompt.HoldDuration)
                                                tradePrompt:InputHoldEnd()
                                            end
                                        end
                                    end
                                    task.wait(1)
                                    break
                                end
                            end
                        end
                     end
                     
                     if not foundTool then
                         -- No tool found anywhere?
                         Rayfield:Notify({Title = "Info", Content = "Nenhuma Esok encontrada.", Duration = 3})
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
