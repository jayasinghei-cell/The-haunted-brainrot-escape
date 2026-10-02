local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local function SetupEnemyAI(charactersFolder, spawnedRooms)
	local monsterPrefab = charactersFolder:FindFirstChildOfClass("Model")
	if not monsterPrefab then return end
	
	local monster = monsterPrefab:Clone()
	monster.Parent = Workspace
	monster:MoveTo(Vector3.new(0, 5, 0))
	
	local humanoid = monster:FindFirstChildOfClass("Humanoid")
	local rootPart = monster:FindFirstChild("HumanoidRootPart")
	
	task.spawn(function()
		while monster and humanoid and rootPart do
			task.wait(1.5)
			
			local nearestPlayer = nil
			local shortestDistance = 35 -- Detection radius
			
			for _, player in ipairs(Players:GetPlayers()) do
				local character = player.Character
				if character and character:FindFirstChild("HumanoidRootPart") then
					local dist = (character.HumanoidRootPart.Position - rootPart.Position).Magnitude
					
					-- Raycast line-of-sight check
					local rayOrigin = rootPart.Position
					local rayDirection = (character.HumanoidRootPart.Position - rootPart.Position)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterAncestorsInstances = {monster}
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					
					local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
					if result and result.Instance:IsDescendantOf(character) and dist < shortestDistance then
						shortestDistance = dist
						nearestPlayer = character
					end
				end
			end
			
			if nearestPlayer then
				humanoid:MoveTo(nearestPlayer.HumanoidRootPart.Position)
			elseif #spawnedRooms > 0 then
				local targetRoom = spawnedRooms[math.random(1, #spawnedRooms)]
				humanoid:MoveTo(targetRoom:GetPrimaryPartCFrame().Position)
			end
		end
	end)
end

return { SetupEnemyAI = SetupEnemyAI }
