local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Noob Hub's Universal Script",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "When you are loading this hub in unsupported games:)",
   LoadingSubtitle = "by NormalNoobOff",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "abc",
      Subtitle = "abc",
      Note = "abc", -- Use this to tell the user how to get a key
      FileName = "abc", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"abc"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local Tab = Window:CreateTab("Movement", microwave)

Tab:CreateInput({
    Name = "Fly Speed",
    CurrentValue = "50",
    RemoveTextAfterFocusLost = false,
    PlaceholderText = "",
    Flag = "flyspeedvalue",
    Callback = function(Value)
        Rayfield.Flags["flyspeedvalue"] = { Value = Value }
    end
})

Tab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        local lp = game.Players.LocalPlayer

        if getgenv().FlyConnection then
            getgenv().FlyConnection:Disconnect()
            getgenv().FlyConnection = nil
        end

        if Value then
            getgenv().FlyConnection = RunService.RenderStepped:Connect(function()
                local character = lp.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local flySpeed = tonumber(Rayfield.Flags["flyspeedvalue"] and Rayfield.Flags["flyspeedvalue"].Value) or 50
                if hrp then
                    local direction = Vector3.new()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + workspace.CurrentCamera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - workspace.CurrentCamera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - workspace.CurrentCamera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + workspace.CurrentCamera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0,1,0) end

                    if direction.Magnitude > 0 then
                        hrp.AssemblyLinearVelocity = direction.Unit * flySpeed
                    else
                        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    end
                end
            end)
        else
            local character = lp.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end
            if getgenv().FlyConnection then
                getgenv().FlyConnection:Disconnect()
                getgenv().FlyConnection = nil
            end
        end
    end
})

Tab:CreateInput({
    Name = "WalkSpeed",
    CurrentValue = "16",
    RemoveTextAfterFocusLost = false,
    PlaceholderText = "",
    Flag = "walkspeedvalue",
    Callback = function(Value)
        local lp = game.Players.LocalPlayer
        local character = lp.Character or lp.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local speed = tonumber(Value)
        if humanoid and speed then
            humanoid.WalkSpeed = speed
        end
    end
})

Tab:CreateToggle({
    Name = "Aimbot (Always On)",
    CurrentValue = false,
    Flag = "AimbotAlwaysOn",
    Callback = function(Value)
        local RunService = game:GetService("RunService")
        local lp = game.Players.LocalPlayer
        local camera = workspace.CurrentCamera

        -- Disconnect previous connection if any
        if getgenv().AimbotConnection then
            getgenv().AimbotConnection:Disconnect()
            getgenv().AimbotConnection = nil
        end

        local function getClosestPlayer()
            local closest, minDist = nil, math.huge
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local dist = (lp.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = plr.Character.HumanoidRootPart
                    end
                end
            end
            return closest
        end

        if Value then
            getgenv().AimbotConnection = RunService.RenderStepped:Connect(function()
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    local target = getClosestPlayer()
                    if target then
                        camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
                    end
                end
            end)
        else
            if getgenv().AimbotConnection then
                getgenv().AimbotConnection:Disconnect()
                getgenv().AimbotConnection = nil
            end
        end
    end
})

Tab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        local UserInputService = game:GetService("UserInputService")
        local lp = game.Players.LocalPlayer
        local character = lp.Character or lp.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if Value then
            UserInputService.JumpRequest:Connect(function()
                if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            UserInputService.JumpRequest:Disconnect()
        end
    end
})

local Drawing = Drawing or getgenv().Drawing -- For compatibility

local espObjects = {}
local espColor = Color3.fromRGB(255, 0, 0)

Tab:CreateColorPicker({
    Name = "ESP Color",
    Color = espColor,
    Flag = "ESPColor",
    Callback = function(Color)
        espColor = Color
        for _, obj in pairs(espObjects) do
            if obj.Box then obj.Box.Color = espColor end
            if obj.Text then obj.Text.Color = espColor end
            if obj.HP then obj.HP.Color = Color3.fromRGB(0,255,0) end
        end
    end
})

Tab:CreateToggle({
    Name = "ESP (Box, Distance, HP)",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        local RunService = game:GetService("RunService")
        local lp = game.Players.LocalPlayer
        local camera = workspace.CurrentCamera

        local function clearESP()
            for _, obj in pairs(espObjects) do
                if obj.Box then obj.Box:Remove() end
                if obj.Text then obj.Text:Remove() end
                if obj.HP then obj.HP:Remove() end
            end
            espObjects = {}
        end

        if getgenv().ESPConnection then
            getgenv().ESPConnection:Disconnect()
            getgenv().ESPConnection = nil
        end
        clearESP()

        if Value then
            getgenv().ESPConnection = RunService.RenderStepped:Connect(function()
                for _, plr in ipairs(game.Players:GetPlayers()) do
                    if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                        local hrp = plr.Character.HumanoidRootPart
                        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                        local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                        if not espObjects[plr] then
                            espObjects[plr] = {
                                Box = Drawing.new("Square"),
                                Text = Drawing.new("Text"),
                                HP = Drawing.new("Text")
                            }
                            espObjects[plr].Box.Thickness = 2
                            espObjects[plr].Box.Filled = false
                            espObjects[plr].Box.Color = espColor
                            espObjects[plr].Box.Visible = false

                            espObjects[plr].Text.Size = 16
                            espObjects[plr].Text.Center = true
                            espObjects[plr].Text.Outline = true
                            espObjects[plr].Text.Color = espColor
                            espObjects[plr].Text.Visible = false

                            espObjects[plr].HP.Size = 14
                            espObjects[plr].HP.Center = true
                            espObjects[plr].HP.Outline = true
                            espObjects[plr].HP.Color = Color3.fromRGB(0,255,0)
                            espObjects[plr].HP.Visible = false
                        end
                        local box = espObjects[plr].Box
                        local text = espObjects[plr].Text
                        local hptext = espObjects[plr].HP
                        if onScreen then
                            local dist = math.floor((lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) and (lp.Character.HumanoidRootPart.Position - hrp.Position).Magnitude or 0)
                            local size = math.clamp(3000 / (hrp.Position - camera.CFrame.Position).Magnitude, 2, 50)
                            box.Size = Vector2.new(size, size * 1.8)
                            box.Position = Vector2.new(pos.X - size / 2, pos.Y - size * 0.9)
                            box.Color = espColor
                            box.Visible = true

                            text.Text = plr.DisplayName .. " [" .. dist .. " studs]"
                            text.Position = Vector2.new(pos.X, pos.Y - size)
                            text.Color = espColor
                            text.Visible = true

                            hptext.Text = "HP: " .. math.floor(humanoid.Health)
                            hptext.Position = Vector2.new(pos.X, pos.Y - size - 18)
                            hptext.Visible = true
                        else
                            box.Visible = false
                            text.Visible = false
                            hptext.Visible = false
                        end
                    elseif espObjects[plr] then
                        espObjects[plr].Box.Visible = false
                        espObjects[plr].Text.Visible = false
                        espObjects[plr].HP.Visible = false
                    end
                end
                -- Remove ESP for players who left
                for plr, obj in pairs(espObjects) do
                    if not game.Players:FindFirstChild(plr.Name) then
                        if obj.Box then obj.Box:Remove() end
                        if obj.Text then obj.Text:Remove() end
                        if obj.HP then obj.HP:Remove() end
                        espObjects[plr] = nil
                    end
                end
            end)
        else
            if getgenv().ESPConnection then
                getgenv().ESPConnection:Disconnect()
                getgenv().ESPConnection = nil
            end
            clearESP()
        end
    end
})

Tab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(Value)
        local RunService = game:GetService("RunService")
        local lp = game.Players.LocalPlayer

        if getgenv().NoClipConnection then
            getgenv().NoClipConnection:Disconnect()
            getgenv().NoClipConnection = nil
        end

        if Value then
            getgenv().NoClipConnection = RunService.Stepped:Connect(function()
                local character = lp.Character
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            local character = lp.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            if getgenv().NoClipConnection then
                getgenv().NoClipConnection:Disconnect()
                getgenv().NoClipConnection = nil
            end
        end
    end
})

Tab:CreateInput({
    Name = "JumpPower",
    CurrentValue = "50",
    RemoveTextAfterFocusLost = false,
    PlaceholderText = "",
    Flag = "jumppowervalue",
    Callback = function(Value)
        local lp = game.Players.LocalPlayer
        local character = lp.Character or lp.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local jp = tonumber(Value)
        if humanoid and jp then
            humanoid.JumpPower = jp
        end
    end
})

Tab:CreateToggle({
    Name = "Infinite Yield",
    CurrentValue = false,
    Flag = "InfiniteYieldToggle",
    Callback = function(Value)
        if Value then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        else
            -- Infinite Yield does not have a built-in way to disable it, so we won't do anything here.
            -- Users can manually disable it by using the command `end` in the game chat.
        end
    end
})

Tab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFKToggle",
    Callback = function(Value)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")

        if getgenv().AntiAFKConnection then
            getgenv().AntiAFKConnection:Disconnect()
            getgenv().AntiAFKConnection = nil
        end

        if Value then
            getgenv().AntiAFKConnection = RunService.Heartbeat:Connect(function()
                Players.LocalPlayer.Idled:Fire()
            end)
        end
    end
})

Tab:CreateToggle({
    Name = "Click to TP",
    CurrentValue = false,
    Flag = "ClickToTPToggle",
    Callback = function(Value)
        local UserInputService = game:GetService("UserInputService")
        local lp = game.Players.LocalPlayer
        local camera = workspace.CurrentCamera

        if getgenv().ClickToTPConnection then
            getgenv().ClickToTPConnection:Disconnect()
            getgenv().ClickToTPConnection = nil
        end

        if Value then
            getgenv().ClickToTPConnection = UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mouseLocation = UserInputService:GetMouseLocation()
                    local viewportPointRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {lp.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local raycastResult = workspace:Raycast(viewportPointRay.Origin, viewportPointRay.Direction * 1000, raycastParams)
                    if raycastResult then
                        local character = lp.Character or lp.CharacterAdded:Wait()
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
                        end
                    end
                end
            end)
        end
    end
})

Tab:CreateToggle({
    Name = "Anti-Cheat Cleaner",
    CurrentValue = false,
    Flag = "AntiCheatCleanerToggle",
    Callback = function(Value)
        local RunService = game:GetService("RunService")
        local lp = game.Players.LocalPlayer

        if getgenv().AntiCheatCleanerConnection then
            getgenv().AntiCheatCleanerConnection:Disconnect()
            getgenv().AntiCheatCleanerConnection = nil
        end

        local function isSafeScript(scr)
            -- Don't remove scripts in your own PlayerScripts, Backpack, or UI
            if scr:IsDescendantOf(lp.PlayerScripts) then return true end
            if scr:IsDescendantOf(lp.Backpack) then return true end
            if scr:IsDescendantOf(lp.PlayerGui) then return true end
            return false
        end

        local function cleanScripts()
            for _, obj in ipairs(game:GetDescendants()) do
                if (obj:IsA("LocalScript") or obj:IsA("Script")) and not isSafeScript(obj) then
                    pcall(function()
                        obj:Destroy()
                    end)
                end
            end
        end

        if Value then
            -- Clean immediately and then every 2 seconds
            cleanScripts()
            getgenv().AntiCheatCleanerConnection = RunService.Stepped:Connect(function(step, dt)
                cleanScripts()
            end)
        else
            if getgenv().AntiCheatCleanerConnection then
                getgenv().AntiCheatCleanerConnection:Disconnect()
                getgenv().AntiCheatCleanerConnection = nil
            end
        end
    end
})
