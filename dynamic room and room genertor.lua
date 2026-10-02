local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local AssetsFolder = ReplicatedStorage:WaitForChild("BrianRotAssets")
local RoomTemplates = AssetsFolder:WaitForChild("RoomTemplates"):GetChildren()
local FragmentTemplate = AssetsFolder:WaitForChild("GlitchFragments"):FindFirstChild("Fragment")

local StudioFolder = Workspace:WaitForChild("SpawnedStudio")
local FinalExitDoor = Workspace:FindFirstChild("FinalExitDoor")

local TOTAL_ROOMS = 6
local FRAGMENTS_REQUIRED = 4
local spawnedRooms = {}
local collectedFragments = 0

-- Spawns procedural rooms connected sequentially
local function SpawnStudioLayout()
	StudioFolder:ClearAllChildren()
	spawnedRooms = {}
	
	local previousExitCFrame = CFrame.new(0, 5, 0)
	
	for i = 1, TOTAL_ROOMS do
		if #RoomTemplates == 0 then break end
		
		local randomIndex = math.random(1, #RoomTemplates)
		local roomClone = RoomTemplates[randomIndex]:Clone()
		
		local entrance = roomClone:FindFirstChild("Entrance")
		local exit = roomClone:FindFirstChild("Exit")
		
		if entrance and exit then
			roomClone.PrimaryPart = roomClone.PrimaryPart or entrance
			local offset = entrance.CFrame:ToObjectSpace(roomClone:GetPrimaryPartCFrame())
			roomClone:SetPrimaryPartCFrame(previousExitCFrame * offset)
			
			previousExitCFrame = exit.CFrame
			roomClone.Parent = StudioFolder
			table.insert(spawnedRooms, roomClone)
		end
	end
	
	if FinalExitDoor then
		FinalExitDoor:PivotTo(previousExitCFrame * CFrame.new(0, 0, -10))
	end
end

-- Spawns interactive glitch fragments in random rooms
local function SpawnGlitchFragments()
	collectedFragments = 0
	
	for i = 1, FRAGMENTS_REQUIRED do
		if #spawnedRooms > 0 then
			local randomRoom = spawnedRooms[math.random(1, #spawnedRooms)]
			local fragment = FragmentTemplate and FragmentTemplate:Clone() or Instance.new("Part")
			
			if not FragmentTemplate then
				fragment.Name = "GlitchFragment"
				fragment.Size = Vector3.new(2, 2, 2)
				fragment.BrickColor = BrickColor.new("Neon orange")
				fragment.Material = Enum.Material.Neon
				fragment.Anchored = true
				fragment.CanCollide = false
			end
			
			fragment.CFrame = randomRoom:GetPrimaryPartCFrame() * CFrame.new(math.random(-8, 8), 3, math.random(-8, 8))
			fragment.Parent = Workspace
			
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Collect Glitch Fragment"
			prompt.ObjectText = "BrianRot Artifact"
			prompt.HoldDuration = 0.5
			prompt.Parent = fragment
			
			prompt.Triggered:Connect(function(player)
				collectedFragments = collectedFragments + 1
				fragment:Destroy()
			end)
		end
	end
end

return {
	SpawnStudioLayout = SpawnStudioLayout,
	SpawnGlitchFragments = SpawnGlitchFragments,
	GetCollected = function() return collectedFragments end,
	GetRequired = function() return FRAGMENTS_REQUIRED end
}
