local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

-- Function to play opening Intro Cutscene
local function PlayIntroCutscene()
	camera.CameraType = Enum.CameraType.Scriptable
	
	-- Starting camera angle (panning over studio set)
	local startCFrame = CFrame.new(0, 30, -50) * CFrame.Angles(math.rad(-20), 0, 0)
	local endCFrame = CFrame.new(0, 10, -10) * CFrame.Angles(0, 0, 0)
	
	camera.CFrame = startCFrame
	
	local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
	local tween = TweenService:Create(camera, tweenInfo, {CFrame = endCFrame})
	
	tween:Play()
	tween.Completed:Connect(function()
		camera.CameraType = Enum.CameraType.Custom
	end)
end

-- Run intro on spawn
if player.Character then
	PlayIntroCutscene()
else
	player.CharacterAdded:Connect(function()
		PlayIntroCutscene()
	end)
end