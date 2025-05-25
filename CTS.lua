local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()

local localPlayer = game.Players.LocalPlayer
local scriptEnabled = false
local nameTextSize = 15
local distanceTextSize = 12
local runService = game:GetService("RunService")
local teamcheck = false
local FOVSliderValue = 70
local FOV = 70
local FOVStatus = false
local cam = game.Workspace.Camera
local vehicles = game.Workspace.Vehicles
local priorFOV = 70
local localV = nil

local highlights = {}
local billboards = {}

local function getLocalVehicle()
    for _,v in pairs(game.Workspace.Vehicles:GetChildren()) do
        if v.Name == "Chassis"..(localPlayer.Name) then
            localV = v
        end
    end
end

local function createCombinedBillboard(player)
    local playerName = tostring(player.Owner.Value)
    local actualPlayer = game.Players:FindFirstChild(playerName)

    if not actualPlayer then return end

    if (teamcheck and actualPlayer.Team == localPlayer.Team) then
        return
    end

    if player then
        if player:FindFirstChild("CombinedDisplay") then
            player.Character.CombinedDisplay:Destroy()
        end

        if not player:FindFirstChild("HullNode") then print("No HullNode found!") end

        local combinedBillboard = Instance.new("BillboardGui")
        combinedBillboard.Name = "CombinedDisplay"
        combinedBillboard.Size = UDim2.new(0, 100, 0, 100)
        combinedBillboard.Adornee = player.HullNode
        combinedBillboard.StudsOffset = Vector3.new(0, 5, 0)
        combinedBillboard.AlwaysOnTop = true
        combinedBillboard.Parent = player

        local background = Instance.new("Frame")
        background.Name = "Background"
        background.Size = UDim2.new(1, 0, 0.65, 0)
        background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        background.BackgroundTransparency = 0.4
        background.BorderSizePixel = 0
        background.Parent = combinedBillboard

        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(1, -10, 1, -10)
        container.Position = UDim2.new(0, 5, 0, 5)
        container.BackgroundTransparency = 1
        container.Parent = background

        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Font = Enum.Font.RobotoMono
        distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
        distanceLabel.Position = UDim2.new(0, 0, 0, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distanceLabel.TextScaled = false
        distanceLabel.TextSize = distanceTextSize
        distanceLabel.Text = "dist: 0m"
        distanceLabel.Name = "DistanceLabel"
        distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
        distanceLabel.TextYAlignment = Enum.TextYAlignment.Bottom
        distanceLabel.Parent = container

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Font = Enum.Font.RobotoMono
        nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
        nameLabel.Position = UDim2.new(0, 0, 0.4, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = actualPlayer.Team and actualPlayer.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = false
        nameLabel.TextSize = nameTextSize
        nameLabel.Text = actualPlayer.Name
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.TextYAlignment = Enum.TextYAlignment.Top
        nameLabel.Parent = container

        local uICorner = Instance.new("UICorner")
        uICorner.CornerRadius = UDim.new(0, 6)
        uICorner.Parent = background

        table.insert(billboards, combinedBillboard)
    end
end

local function createHighlight(player)
    local playerName = tostring(player.Owner.Value)
    local actualPlayer = game.Players:FindFirstChild(playerName)
    if teamcheck then
        if actualPlayer.Team ~= localPlayer.Team then
            if player and not player:FindFirstChild("Highlight") then
                local outline = Instance.new("Highlight")
                outline.FillTransparency = 1
                outline.OutlineColor = actualPlayer.Team and actualPlayer.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                outline.Parent = player

                table.insert(highlights, highlight)
            end
        end
    else
        if player and not player:FindFirstChild("Highlight") then
            local outline = Instance.new("Highlight")
            outline.FillTransparency = 1
            outline.OutlineColor = actualPlayer.Team and actualPlayer.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
            outline.Parent = player
            
            table.insert(highlights, highlight)
        end
    end
end

local function updateBillboardInfo(display, player)
    if not localV or not player then return end
    local localRoot = localV:FindFirstChild("HullNode")
    local targetPart = player:FindFirstChild("HullNode")
    if localRoot and targetPart then
        local distanceInStuds = (localRoot.Position - targetPart.Position).Magnitude
        local distanceInMeters = distanceInStuds * 0.28
        display:FindFirstChild("DistanceLabel", true).Text = string.format("dist: %.2fm", distanceInMeters)
    end
end

local function destroyAllDrawings()
    for _, highlight in ipairs(highlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    highlights = {}

    for _, billboard in ipairs(billboards) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    billboards = {}
end

local function updateFOV(fov)
    cam.FieldOfView = fov
end

local function updateHighlightingScript()
    if not scriptEnabled then return end
    getLocalVehicle()
    for _, player in pairs(game.Workspace.Vehicles:GetChildren()) do
        if player ~= localV then
            createHighlight(player)
            
            if not player:FindFirstChild("CombinedDisplay") then
                createCombinedBillboard(player)
            end
                
            local display = player:FindFirstChild("CombinedDisplay")
            if display then
                updateBillboardInfo(display, player)
            end
        end
    end
end

local function safeCall(fn, ...)
    local functionName = tostring(fn):match("function: (.*)") or "anonymous"
    local success, err = pcall(fn, ...)
    if not success then
        warn("Error in "..functionName..": "..tostring(err))
    end
end

runService.RenderStepped:Connect(function()
    safeCall(updateHighlightingScript)
    if FOVStatus then
        FOV = FOVSliderValue
        updateFOV(FOV)
    end
end)

local Goat = library:CreateWindow({
    Name = "Goated chair",
    Themeable = {
        Info = "credits to Cowray"
    }
})

local visualsTab = Goat:CreateTab({
    Name = "visuals"
})

local espSection = visualsTab:CreateSection({
    Name = "esp"
})

local MiscTab = Goat:CreateTab({
    Name = "Misc"
})

local dex = MiscTab:CreateSection({
    Name = "Dex"
})

dex:AddButton({
    Name = "Start Dex",
    Callback = function() 
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Dex-Explorer-24220"))()
    end
})

espSection:AddToggle({
    Name = "esp toggle",
    Callback = function(value) 
        scriptEnabled = value
        if scriptEnabled then
            print("ESP Loop started")
        else
            print("ESP Loop stopped")
            destroyAllDrawings()
        end
    end
})

espSection:AddToggle({
    Name = "team check",
    Callback = function(value)
        teamcheck = value
        if teamcheck then
            destroyAllDrawings() 
        end
    end
})

espSection:AddToggle({
    Name = "FOV Toggle",
    KeyBind = Enum.KeyCode.H,
    Callback = function(value)
        FOVStatus = value
        if value then
            priorFOV = cam.FieldOfView
        else
            FOV = priorFOV
            updateFOV(FOV)
        end
        print("FOV Status set to: ", FOVStatus)
        print("FOV Set to: ", FOV)
    end
})

espSection:AddSlider({
    Name = "FOV Value",
    Value = 70,
    Min = 0,
    Max = 200,
    Callback = function(value) 
        FOVSliderValue = tonumber(value)
    end
})