local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AssetsFolder = ReplicatedStorage:WaitForChild("BrianRotAssets")
local AudioFolder = AssetsFolder:WaitForChild("Audio")
local SahurMusic = AudioFolder:FindFirstChild("SahurChaseMusic")

-- Function to play/stop chase music when NPC spots a player
local function SetChaseMusicState(isPlaying)
	if SahurMusic then
		if isPlaying and not SahurMusic.IsPlaying then
			SahurMusic:Play()
		elseif not isPlaying and SahurMusic.IsPlaying then
			SahurMusic:Stop()
		end
	end
end

-- Monitor distance between NPC and players
task.spawn(function()
	while true do
		task.wait(0.5)
		local monster = workspace:FindFirstChildOfClass("Model") -- Detect spawned NPC
		local chasing = false
		
		if monster and monster:FindFirstChild("HumanoidRootPart") then
			for _, player in ipairs(Players:GetPlayers()) do
				local char = player.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					local dist = (char.HumanoidRootPart.Position - monster.HumanoidRootPart.Position).Magnitude
					if dist < 35 then
						chasing = true
						break
					end
				end
			end
		end
		
		SetChaseMusicState(chasing)
	end
end)
