repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local player = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- API CONFIG
local API_KEY = "Deas231asnncasjk321312267a412sSasagnz"
local BASE_URL = "https://xssurcewybxaprixrlyz.supabase.co/functions/v1"

-- DYNAMIC ITEM LIST
local brainrotItems = {}
local divineFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Brainrots"):WaitForChild("Divine")

if divineFolder then
    for _, item in ipairs(divineFolder:GetChildren()) do
        table.insert(brainrotItems, item.Name)
    end
end
-- Fallback manual items if needed
-- table.insert(brainrotItems, "Esok Sekolah")

local mutationsList = {"Admin", "Blood", "Diamond", "Electric", "Emerald", "Gold", "Hacker", "Lucky", "Radioactive", "UFO"}

-- Helper: Identify item and mutation via Attributes
local function isBrainrot(tool, targetName)
    if not tool or not tool:IsA("Tool") then return false, nil end
    local function getAttr(obj, key) return obj:GetAttribute(key) or obj:GetAttribute(key:lower()) end

    local name = getAttr(tool, "BrainrotName")
    local model = tool:FindFirstChild("RenderModel")
    if not name and model then name = getAttr(model, "BrainrotName") end

    if name == targetName then
        local mut = getAttr(tool, "Mutation")
        if (not mut or mut == "" or mut == "None") and model then mut = getAttr(model, "Mutation") end
        if not mut or mut == "" or mut == "None" then mut = "Normal" end
        return true, mut
    end
    return false, nil
end

-- Function to get detailed count per mutation
local function getBrainrotDetailedCount(name)
    local stats = {Total = 0, Normal = 0}
    for _, m in ipairs(mutationsList) do stats[m] = 0 end
    
    local function process(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            local isMatch, mut = isBrainrot(item, name)
            if isMatch then
                stats.Total = stats.Total + 1
                stats[mut] = (stats[mut] or 0) + 1
            end
        end
    end
    
    process(player.Backpack)
    process(player.Character)
    return stats
end

-- BATCH API UPDATE
local function updateStockBatch(playerName, items)
    local url = BASE_URL:gsub("/v1", "") .. "/v1/update-stock-batch"
    local body = HttpService:JSONEncode({
        pessoa = playerName,
        items = items -- Array de {produto, quantidade, mutation}
    })
    
    local req = http_request or request or (syn and syn.request) or (http and http.request)
    if req then
        task.spawn(function()
            pcall(function()
                req({
                    Url = url,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json", ["x-api-key"] = API_KEY},
                    Body = body
                })
            end)
        end)
    end
end

local function registrarContaVazia()
    local url = BASE_URL:gsub("/v1", "") .. "/v1/add-empty-account"
    local body = HttpService:JSONEncode({
        pessoa = player.Name,
        produto = "Peck Esok",
        mutation = "Normal"
    })
    
    local req = http_request or request or (syn and syn.request) or (http and http.request)
    if req then
        task.spawn(function()
            pcall(function()
                req({
                    Url = url,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json", ["x-api-key"] = API_KEY},
                    Body = body
                })
            end)
        end)
    end
end

-- Main Update Loop
local variants = {"Normal"}
for _, m in ipairs(mutationsList) do table.insert(variants, m) end
local lastHash = "" -- Simple way to detect changes (or just update periodically)

task.spawn(function()
    while true do
        local grandTotal = 0
        local batchItems = {}
        
        -- SCAN INVENTORY
        for _, itemName in ipairs(brainrotItems) do
            local stats = getBrainrotDetailedCount(itemName)
            grandTotal = grandTotal + stats.Total
            
            -- Add ALL items to batch (including zero quantities)
            for _, variant in ipairs(variants) do
                local qty = stats[variant] or 0
                -- ALWAYS send, even if zero
                table.insert(batchItems, {
                    produto = itemName,
                    quantidade = qty,
                    mutation = variant
                })
            end
        end
        
        -- Generate hash to simulate "lastCounts" logic for ALL items combined
        -- Actually, user asked for batch update, maybe we just update every 10s regardless? 
        -- Or only if something changed. For simplicity and robustness, updating every 10s ensures sync.
        -- But let's try to avoid spam if nothing changed.
        
        local currentHash = HttpService:JSONEncode(batchItems)
        
        if currentHash ~= lastHash then
            lastHash = currentHash
            
            if #batchItems > 0 then
                updateStockBatch(player.Name, batchItems)
                print("Checker: Stock Updated (Batch)")
            end
        end
        
        -- Handle Empty Account status
        if grandTotal == 0 then
             -- Logic to only send once or periodically? Original sent once per "session" of emptiness via flag
             -- We can keep a flag, but since we are in a loop, let's just do it
             if lastHash ~= "EMPTY" then
                 registrarContaVazia()
                 lastHash = "EMPTY"
             end
        end
        
        task.wait(10)
    end
end)
