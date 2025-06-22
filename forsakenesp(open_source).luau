local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local lp = game.Players.LocalPlayer

local SAFE_DISTANCE = 50 -- studs to keep away from killer
local STAMINA_ATTRIBUTE = "Stamina"
local STAMINA_MIN = 15
local STAMINA_MAX = 20
local GENERATOR_DO_TIME = 5 -- seconds to "do" generator

-- Helper: Find nearest killer
local function getNearestKiller()
    local killersFolder = workspace:FindFirstChild("Killers")
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not killersFolder or not hrp then return nil, math.huge end
    local nearest, minDist = nil, math.huge
    for _, killer in ipairs(killersFolder:GetChildren()) do
        if killer:IsA("Model") then
            local killerHRP = killer:FindFirstChild("HumanoidRootPart")
            if killerHRP then
                local dist = (hrp.Position - killerHRP.Position).Magnitude
                if dist < minDist then
                    nearest = killerHRP
                    minDist = dist
                end
            end
        end
    end
    return nearest, minDist
end

-- Helper: Get stamina percent (0-100)
local function getStaminaPercent()
    local char = lp.Character
    if not char then return 100 end
    local stamina = char:GetAttribute(STAMINA_ATTRIBUTE)
    local maxStamina = char:GetAttribute("MaxStamina") or 100
    if not stamina then return 100 end
    return (stamina / maxStamina) * 100
end

-- Helper: Get a random safe position (not near walls)
local function getRandomSafePosition()
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return hrp.Position end
    local tries = 0
    while tries < 10 do
        local offset = Vector3.new(math.random(-40,40), 0, math.random(-40,40))
        local pos = hrp.Position + offset
        local ray = workspace:Raycast(pos + Vector3.new(0,10,0), Vector3.new(0,-20,0))
        if ray and ray.Position then
            local wallRay = workspace:Raycast(hrp.Position, offset.Unit * 10)
            if not wallRay then
                return ray.Position
            end
        end
        tries = tries + 1
    end
    return hrp.Position
end

-- Helper: Find nearest generator
local function getNearestGenerator()
    local generatorsFolder = workspace:FindFirstChild("Generators")
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not generatorsFolder or not hrp then return nil, math.huge end
    local nearest, minDist = nil, math.huge
    for _, gen in ipairs(generatorsFolder:GetChildren()) do
        local genPart = gen.PrimaryPart or gen:FindFirstChild("HumanoidRootPart") or gen:FindFirstChildWhichIsA("BasePart")
        if genPart then
            local dist = (hrp.Position - genPart.Position).Magnitude
            if dist < minDist then
                nearest = genPart
                minDist = dist
            end
        end
    end
    return nearest, minDist
end

-- Main auto-play loop
getgenv().AutoPlayEnabled = true
task.spawn(function()
    while getgenv().AutoPlayEnabled do
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and humanoid then
            local killer, dist = getNearestKiller()
            local staminaPercent = getStaminaPercent()
            local generator, genDist = getNearestGenerator()

            -- 1. If killer is close, run away
            if killer and dist < SAFE_DISTANCE then
                local away = (hrp.Position - killer.Position).Unit * SAFE_DISTANCE
                local targetPos = hrp.Position + away
                local ray = workspace:Raycast(hrp.Position, away)
                if ray then
                    targetPos = ray.Position - away.Unit * 5
                end
                if staminaPercent > STAMINA_MIN then
                    humanoid.WalkSpeed = 24
                else
                    humanoid.WalkSpeed = 10
                end
                TweenService:Create(hrp, TweenInfo.new(0.5), {Position = targetPos}):Play()
            -- 2. If generator is found and killer is NOT close, do generator
            elseif generator and genDist < 100 then
                -- Move to generator
                humanoid.WalkSpeed = 16
                TweenService:Create(hrp, TweenInfo.new(1), {Position = generator.Position + Vector3.new(0,2,0)}):Play()
                -- Wait until close enough or killer appears
                local doingGen = true
                local startTime = tick()
                while doingGen and tick() - startTime < GENERATOR_DO_TIME do
                    local killer2, dist2 = getNearestKiller()
                    if killer2 and dist2 < SAFE_DISTANCE then
                        doingGen = false -- abort if killer comes
                        break
                    end
                    if (hrp.Position - generator.Position).Magnitude > 7 then
                        -- Not close enough, move closer
                        TweenService:Create(hrp, TweenInfo.new(0.5), {Position = generator.Position + Vector3.new(0,2,0)}):Play()
                    end
                    task.wait(0.5)
                end
                -- Simulate generator interaction (replace with remote event if needed)
                print("Generator done (simulated).")
            else
                -- 3. AI random move if no killer or generator nearby
                if staminaPercent < STAMINA_MAX then
                    humanoid.WalkSpeed = 10
                else
                    humanoid.WalkSpeed = 24
                end
                local safePos = getRandomSafePosition()
                TweenService:Create(hrp, TweenInfo.new(1), {Position = safePos}):Play()
            end
        end
        task.wait(1)
    end
end)
