-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")

-- Assets Folders
local AssetsFolder = ReplicatedStorage:WaitForChild("BrianRotAssets")
local RoomTemplates = AssetsFolder:WaitForChild("RoomTemplates"):GetChildren()
local CharactersFolder = AssetsFolder:WaitForChild("Characters")
local FragmentTemplate = AssetsFolder:WaitForChild("GlitchFragments"):FindFirstChild("Fragment")

-- Workspace Containers
local StudioFolder = Workspace:WaitForChild("SpawnedStudio")
local FinalExitDoor = Workspace:FindFirstChild("FinalExitDoor")

-- Game Settings
local TOTAL_ROOMS = 6
local FRAGMENTS_REQUIRED = 4
local COLLAPSE_TIME = 60 -- seconds for final escape

-- Game State Variables
local collectedFragments = 0
local spawnedRooms = {}
local isCollapsing = false

--------------------------------------------------------------------------------
-- 1. DYNAMIC ENVIRONMENT SETUP (Procedural Spawning)
--------------------------------------------------------------------------------

local function SpawnStudioLayout()
	StudioFolder:ClearAllChildren()
	spawnedRooms = {}
	
	local previousExitCFrame = CFrame.new(0, 5, 0) -- Start position
	
	for i = 1, TOTAL_ROOMS do
		-- Pick a random room template
		local randomIndex = math.random(1, #RoomTemplates)
		local roomClone = RoomTemplates[randomIndex]:Clone()
		
		local entrance = roomClone:FindFirstChild("Entrance")
		local exit = roomClone:FindFirstChild("Exit")
		
		if entrance and exit then
			-- Align room entrance to previous room's exit
			local primaryPart = roomClone.PrimaryPart or entrance
			roomClone.PrimaryPart = primaryPart
			
			local offset = entrance.CFrame:ToObjectSpace(roomClone:GetPrimaryPartCFrame())
			roomClone:SetPrimaryPartCFrame(previousExitCFrame * offset)
			
			previousExitCFrame = exit.CFrame
			roomClone.Parent = StudioFolder
			table.insert(spawnedRooms, roomClone)
		else
			warn("Room template missing Entrance or Exit part: " .. roomClone.Name)
		end
	end
	
	-- Position Final Exit Door at the end of the studio
	if FinalExitDoor then
		FinalExitDoor:PivotTo(previousExitCFrame * CFrame.new(0, 0, -10))
	end
end

--------------------------------------------------------------------------------
-- 2. GLITCH FRAGMENTS & PUZZLE SYSTEM
--------------------------------------------------------------------------------

local function SpawnGlitchFragments()
	collectedFragments = 0
	
	if not FragmentTemplate then
		-- Fallback fragment creation if no mesh is imported
		FragmentTemplate = Instance.new("Part")
		FragmentTemplate.Name = "GlitchFragment"
		FragmentTemplate.Size = Vector3.new(2, 2, 2)
		FragmentTemplate.BrickColor = BrickColor.new("Neon orange")
		FragmentTemplate.Material = Enum.Material.Neon
		FragmentTemplate.Anchored = true
		FragmentTemplate.CanCollide = false
	end

	for i = 1, FRAGMENTS_REQUIRED do
		if #spawnedRooms > 0 then
			local randomRoom = spawnedRooms[math.random(1, #spawnedRooms)]
			local fragment = FragmentTemplate:Clone()
			
			-- Position within room space
			local primaryCFrame = randomRoom:GetPrimaryPartCFrame()
			fragment.CFrame = primaryCFrame * CFrame.new(math.random(-10, 10), 3, math.random(-10, 10))
			fragment.Parent = Workspace
			
			-- Collection Prompt
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Collect Glitch Fragment"
			prompt.ObjectText = "BrianRot Artifact"
			prompt.HoldDuration = 1
			prompt.Parent = fragment
			
			prompt.Triggered:Connect(function(player)
				collectedFragments = collectedFragments + 1
				print(player.Name .. " collected a fragment! (" .. collectedFragments .. "/" .. FRAGMENTS_REQUIRED .. ")")
				fragment:Destroy()
				
				if collectedFragments >= FRAGMENTS_REQUIRED then
					print("All Glitch Fragments collected! Final Exit Unlocked.")
				end
			end)
		end
	end
end

--------------------------------------------------------------------------------
-- 3. AI CHARACTER PATROL & STEALTH MECHANICS
--------------------------------------------------------------------------------

local function SetupEnemyAI()
	local monsterPrefab = CharactersFolder:FindFirstChildOfClass("Model")
	if not monsterPrefab then return end
	
	local monster = monsterPrefab:Clone()
	monster.Parent = Workspace
	monster:MoveTo(Vector3.new(0, 5, 0))
	
	local humanoid = monster:FindFirstChildOfClass("Humanoid")
	local rootPart = monster:FindFirstChild("HumanoidRootPart")
	
	task.spawn(function()
		while monster and humanoid and rootPart do
			task.wait(2)
			
			-- Search for nearest player (Stealth Detection)
			local nearestPlayer = nil
			local shortestDistance = 40 -- Detection Radius
			
			for _, player in ipairs(Players:GetPlayers()) do
				local character = player.Character
				if character and character:FindFirstChild("HumanoidRootPart") then
					local distance = (character.HumanoidRootPart.Position - rootPart.Position).Magnitude
					
					-- Raycast to check line-of-sight (Stealth check)
					local rayOrigin = rootPart.Position
					local rayDirection = (character.HumanoidRootPart.Position - rootPart.Position)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterAncestorsInstances = {monster}
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					
					local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
					
					if result and result.Instance:IsDescendantOf(character) then
						if distance < shortestDistance then
							shortestDistance = distance
							nearestPlayer = character
						end
					end
				end
			end
			
			-- Chase or Patrol
			if nearestPlayer then
				humanoid:MoveTo(nearestPlayer.HumanoidRootPart.Position)
			else
				-- Random Patrol across spawned rooms
				if #spawnedRooms > 0 then
					local randomTargetRoom = spawnedRooms[math.random(1, #spawnedRooms)]
					humanoid:MoveTo(randomTargetRoom:GetPrimaryPartCFrame().Position)
				end
			end
		end
	end)
end

--------------------------------------------------------------------------------
-- 4. FINAL CHALLENGE: ESCAPE THE GLITCH (Collapse Timer)
--------------------------------------------------------------------------------

local function TriggerStudioCollapse()
	isCollapsing = true
	print("WARNING: Studio Glitch Collapse Initiated!")
	
	-- Environmental Glitch Effects
	task.spawn(function()
		while isCollapsing do
			for _, room in ipairs(spawnedRooms) do
				for _, part in ipairs(room:GetDescendants()) do
					if part:IsA("BasePart") and math.random() > 0.8 then
						part.Transparency = math.random(0, 1)
						part.Color = Color3.fromRGB(math.random(0, 255), 0, math.random(0, 255))
					end
				end
			end
			task.wait(0.2)
		end
	end)
	
	-- Countdown Timer
	task.spawn(function()
		for i = COLLAPSE_TIME, 0, -1 do
			print("Escape Time Left: " .. i .. "s")
			task.wait(1)
		end
		
		if isCollapsing then
			print("The studio collapsed! Players trapped.")
			for _, player in ipairs(Players:GetPlayers()) do
				if player.Character and player.Character:FindFirstChild("Humanoid") then
					player.Character.Humanoid.Health = 0
				end
			end
		end
	end)
end

-- Wire up Final Exit Prompt
if FinalExitDoor then
	local exitPrompt = Instance.new("ProximityPrompt")
	exitPrompt.ActionText = "Escape Studio"
	exitPrompt.ObjectText = "Final Exit"
	exitPrompt.HoldDuration = 2
	exitPrompt.Parent = FinalExitDoor
	
	exitPrompt.Triggered:Connect(function(player)
		if collectedFragments >= FRAGMENTS_REQUIRED then
			isCollapsing = false
			print(player.Name .. " HAS ESCAPED THE BRIANROT STUDIO!")
		else
			print("Door locked! Find all Glitch Fragments first.")
		end
	end)
end

--------------------------------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------------------------------

local function InitGame()
	SpawnStudioLayout()
	SpawnGlitchFragments()
	SetupEnemyAI()
	
	-- Trigger collapse after 2 minutes of gameplay
	task.delay(120, function()
		TriggerStudioCollapse()
	end)
end

InitGame()