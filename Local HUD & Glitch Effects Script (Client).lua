local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create Screengui dynamically for Glitch UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrianRotHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Glitch Overlay Frame
local glitchFrame = Instance.new("Frame")
glitchFrame.Size = UDim2.new(1, 0, 1, 0)
glitchFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 85)
glitchFrame.BackgroundTransparency = 0.95
glitchFrame.Visible = false
glitchFrame.Parent = screenGui

-- Fragment Counter UI
local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(0, 200, 0, 50)
counterLabel.Position = UDim2.new(0.02, 0, 0.02, 0)
counterLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
counterLabel.BackgroundTransparency = 0.5
counterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
counterLabel.TextSize = 20
counterLabel.Font = Enum.Font.SpecialElite
counterLabel.Text = "Glitch Fragments: 0 / 4"
counterLabel.Parent = screenGui

-- Trigger Screen Glitch Visual Effect
local function TriggerGlitchFlash()
	glitchFrame.Visible = true
	local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 3, true)
	local tween = TweenService:Create(glitchFrame, tweenInfo, {BackgroundTransparency = 0.6})
	tween:Play()
	tween.Completed:Connect(function()
		glitchFrame.Visible = false
	end)
end

-- Periodic ambient glitches
task.spawn(function()
	while true do
		task.wait(math.random(5, 15))
		TriggerGlitchFlash()
	end
end)
