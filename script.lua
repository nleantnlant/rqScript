print("Executing Rumble Quest AI... (discord.gg/wQ7pnWm6nx)")

print("Game check: " .. tostring(game.PlaceId == 4390380541))
if game.PlaceId == 4390380541 then
local run = true

repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game:GetService("ReplicatedStorage"):FindFirstChild("GameType")


warn("Developer Mode: " .. tostring(getgenv().config.DeveloporMode))
warn("Auto Best Location: " .. tostring(getgenv().config.JoinBestLocation))
warn("Auto Sell: " .. tostring(getgenv().config.AutoSell))
-----------------------------------
-- Lobby Scripts --

if game:GetService("ReplicatedStorage"):FindFirstChild("GameType").Value == "Lobby" and run then
  print("In Lobby")
    
	local plr = game.Players.LocalPlayer

	if getgenv().config.HideName then
		plr.PlayerGui:WaitForChild("ScreenGui").LobbyHub.You.Background:FindFirstChild("PlayerImage").Image = "rbxthumb://type=AvatarHeadShot&id=2295308625&w=150&h=150"
		if plr.Character then
			plr.Character:WaitForChild("PlayerOverheadGui"):FindFirstChild("PlayerName").Text = "Player"
		end
		for i,v in pairs(plr.PlayerGui.ScreenGui.PlayerList.Frame:GetChildren()) do
			if v:FindFirstChild("PlayerName") and v:FindFirstChild("PlayerName").Text == plr.Name then
				v.PlayerName.Text = "Player"
				v.PlayerName:FindFirstChild("Highlight").Text = "Player"
			end
		end
	end

	task.wait(3)

	local loadModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("LoadModule"))
	local data = loadModule("GetLocalData")
	local getData = loadModule("Network"):InvokeServer("GetPlayerData")
	local modules = game.ReplicatedStorage:FindFirstChild("Modules")

	-- Auto Skill
	if getgenv().config.AutoSkillPoints then
		local skillValue = (plr:FindFirstChild("Level").Value - data().Skills.Health - data().Skills.Strength - data().Skills.Magic)

		for i = 1,skillValue,1 do
			game.ReplicatedStorage.Modules.Network:FindFirstChild("RemoteEvent"):FireServer("IncreaseSkill",getgenv().config.AutoSkillPoints)
			task.wait(0.05)
		end
		task.wait(1)
	end
	-- Auto Sell

	local weapon = data().Weapons
	local armour = data().Armors
	local ability = data().Abilities

	local items = {}
	local equipped = {}

	for i,v in pairs(data()) do
		local s = tostring(i)

		if string.sub(s,1,8) == "Equipped" then
			table.insert(equipped,v)
		end
	end
	for i = 1,2 do
		local get, get2 = loadModule("FindById")(getData.Abilities,getData["EquippedAbility" .. i])

		if get and get2 then
			table.insert(equipped,get2[1])
		end
	end

	local function sell(item)
		game.ReplicatedStorage.Modules.Network:FindFirstChild("RemoteFunction"):InvokeServer("SellItems",item)
	end

	for i,v in pairs(weapon) do
		if modules:FindFirstChild("Weapons"):FindFirstChild(v[2]) and not table.find(equipped,v[1]) and not table.find(getgenv().config.SellTab.Whitelist,v[2]) then
			local get = require(modules:FindFirstChild("Weapons"):FindFirstChild(v[2]))
			
			if getgenv().config.SellTab.Rarities[get.Rarity] and getgenv().config.SellTab.MaxLevel >= get.Level then
				table.insert(items,{"Weapon",v[1]})
			elseif table.find(getgenv().config.SellTab.Blacklist,v[2]) then
				table.insert(items,{"Weapon",v[1]})
			end
		end
	end
	for i,v in pairs(armour) do
		if modules:FindFirstChild("ItemData"):FindFirstChild("Armors") and not table.find(equipped,v[1]) and not table.find(getgenv().config.SellTab.Whitelist,v[2]) then
			local get = require(modules:FindFirstChild("ItemData"):FindFirstChild("Armors"))
			
			if getgenv().config.SellTab.Rarities[get[v[2]].Rarity] and getgenv().config.SellTab.MaxLevel >= get[v[2]].Level then
				table.insert(items,{"Armor",v[1]})
			elseif table.find(getgenv().config.SellTab.Blacklist,v[2]) then
				table.insert(items,{"Armor",v[1]})
			end
		end
	end
	for i,v in pairs(ability) do
		if modules:FindFirstChild("Abilities"):FindFirstChild(v[2]) and not table.find(equipped,v[1]) and not table.find(getgenv().config.SellTab.Whitelist,v[2]) then
			local get = require(modules:FindFirstChild("Abilities"):FindFirstChild(v[2]))
			
			if getgenv().config.SellTab.Rarities[get.Rarity] and getgenv().config.SellTab.MaxLevel >= get.Level then
				table.insert(items,{"Ability",v[1]})
			elseif table.find(getgenv().config.SellTab.Blacklist,v[2]) then
				table.insert(items,{"Ability",v[1]})
			end
		end
	end

	if getgenv().config.AutoSell then
		sell(items)
		task.wait(2)
	end

	-- Join Game
	
	while task.wait() do
		if getgenv().config.JoinBestLocation then
			local get = require(game:GetService("ReplicatedStorage").Modules.ItemData.Dungeons)

			local dungeon = nil
			local difficulty = nil
			local num = 0

			for i,v in pairs(get) do
				for a,c in pairs(v.LevelRequirements) do
					if c > num and c <= game.Players.LocalPlayer:FindFirstChild("Level").Value then
						num = c
						dungeon = i
						difficulty = a
					end
				end
			end

			local dungeonInfo = {
				Location = dungeon,
				Difficulty = difficulty,
				Hardcore = getgenv().config.Map.Hardcore,
				PartyOnly = getgenv().config.Map.PartyOnly,
			}

			game.ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("Network"):FindFirstChild("RemoteFunction"):InvokeServer("CreateLobby",dungeonInfo)
		else
			game.ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("Network"):FindFirstChild("RemoteFunction"):InvokeServer("CreateLobby",getgenv().config.Map)
		end
		task.wait(2)
		game.ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("Network"):FindFirstChild("RemoteEvent"):FireServer("StartDungeon")
		task.wait(15)
	end
end




-----------------------------------
-- Dungeon Scripts

if game:GetService("ReplicatedStorage"):FindFirstChild("GameType").Value == "Dungeon" and run then
  print("In game")
    
	local plr = game:GetService("Players").LocalPlayer
  
	if getgenv().config.HideName then
		plr.PlayerGui:WaitForChild("ScreenGui").DungeonHub.You:FindFirstChild("PlayerName").Text = "Player"
		plr.Character:FindFirstChild("PlayerOverheadGui"):FindFirstChild("PlayerName").Text = "Player"
		plr.PlayerGui:WaitForChild("ScreenGui").DungeonHub.You:FindFirstChild("PlayerName"):FindFirstChild("Highlight").Text = "Player"
		plr.PlayerGui:WaitForChild("ScreenGui").DungeonHub.You.Picture:FindFirstChild("PlayerImage").Image = "rbxthumb://type=AvatarHeadShot&id=2295308625&w=150&h=150"
	end

	task.wait(3)

	local pathService = game:GetService("PathfindingService")
	local loadModule = require(game.ReplicatedStorage:FindFirstChild("LoadModule"))
	local abilityModule = loadModule("GetAbilityModule")
	local data = loadModule("Network"):InvokeServer("GetPlayerData")

	local path = pathService:CreatePath()

	local waypoints = nil
	local nextWaypoint = nil
	local reached = nil
	local blocked = nil

	local partBehind = nil
	local currentPos = nil

	local rotate = true
	local stop = false

	plr:FindFirstChild("PlayerScripts"):FindFirstChild("ClientScript").Disabled = true
	workspace.CurrentCamera.CameraType = Enum.CameraType.Attach

	local clone = plr.Character:FindFirstChild("Animate"):Clone()
	plr.Character:FindFirstChild("Animate"):Destroy()
	clone.Parent = plr.Character

	local area = {
		["Up"] = nil,
		["Down"] = nil,
		["Back"] = nil,
		["Front"] = nil,
		["Left"] = nil,
		["Right"] = nil,

		["Around"] = nil,
	}

	local disabled = false

	getgenv().enabled = true

	getgenv().waypoint = 4
	getgenv().range = 3

	-- Script:


	-- Show/Expand collisions
	if not getgenv().executed and getgenv().config.DeveloperMode then
		for i,v in pairs(workspace.Ignore:FindFirstChild("DungeonCollisions"):GetDescendants()) do
			if v:IsA("Part") then
				local x = v.Size.X
				local z = v.Size.Z
				
				v.Transparency = 0.5
				
				if x > z then
					--v.Size = v.Size + Vector3.new(0,0,6)
				elseif z > x then
					--v.Size = v.Size + Vector3.new(6,0,0)
				end
			end
		end

		getgenv().executed = true
	end

	local selBox = Instance.new("SelectionBox")
	selBox.LineThickness = 0.1
	selBox.Color3 = Color3.new(1,0,0)
	selBox.Parent = workspace

	-- Creates Raycast Lines
	if workspace:FindFirstChild("AI_Debris") then
		workspace:FindFirstChild("AI_Debris"):Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Parent = workspace
	folder.Name = "AI_Debris"

	local root = plr.Character.HumanoidRootPart

	local function createLine(pos,size,name)
		local part = Instance.new("Part")
		part.Parent = folder
		part.Material = Enum.Material.Neon

		if name == "ExtraRaycastLine" then
			part.Color = Color3.new(0,1,1)
		else
			part.Color = Color3.new(1,0,0)
		end
		
		part.CanCollide = false
		part.Name = name

		part.FrontSurface = Enum.SurfaceType.Smooth
		part.BackSurface = Enum.SurfaceType.Smooth
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.RightSurface = Enum.SurfaceType.Smooth
		part.LeftSurface = Enum.SurfaceType.Smooth

		part.Size = size
		part.CFrame = pos
		
		local weld = Instance.new("WeldConstraint")
		weld.Parent = part
		weld.Part0 = part
		weld.Part1 = root

		return part
	end

	if getgenv().config.DeveloperMode then
		local frontLine = createLine(CFrame.new(root.Position,root.Position+root.CFrame.LookVector*(getgenv().range+10)),Vector3.new(0.25,0.25,(getgenv().range*2)),"FrontRaycastLine")
		local topLine = createLine(CFrame.new(root.Position,root.Position+root.CFrame.UpVector*(getgenv().range+10)),Vector3.new(0.25,0.25,(getgenv().range*2)),"TopRaycastLine")
		local rightLine = createLine(CFrame.new(root.Position,root.Position+root.CFrame.RightVector*(getgenv().range+10)),Vector3.new(0.25,0.25,(getgenv().range*2)),"RightRaycastLine")
		local extraLine = createLine(CFrame.new(root.Position,root.Position+root.CFrame.RightVector*(getgenv().range+10)),Vector3.new(0.05,0.05,(getgenv().range+4*2)),"ExtraRaycastLine")
	end

	-- Get target function, grabs all the enemies
	local function getTargets()
		local targets = {}

		for i,v in pairs(workspace.Enemies:GetChildren()) do
			if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
				if v:FindFirstChild("Humanoid").Health > 0 then
					table.insert(targets,v)
				end
			end
		end

		if #targets > 0 then
			return targets
		end
	end

	-- Find Closest function, finds the closest enemy
	local function findClosest(targets)
		local get = targets[1]
		local root = plr.Character:FindFirstChild("HumanoidRootPart")

		for i,v in pairs(targets) do
			if (v.HumanoidRootPart.Position - root.Position).Magnitude < (get.HumanoidRootPart.Position - root.Position).Magnitude then
				get = v
			end
		end

		return get
	end

	-- Follow Path function, moves character to the coords using PathfindingService
	local function followPath(target)
		local success, errorMessage = pcall(function()
			path:ComputeAsync(plr.Character:FindFirstChild("HumanoidRootPart").Position,target.Position)
		end)

		if success and path.Status == Enum.PathStatus.Success then
			waypoints = path:GetWaypoints()

			if getgenv().config.DeveloperMode then
				for i,v in pairs(workspace:FindFirstChild("AI_Debris"):GetChildren()) do
					if v:IsA("BasePart") and v.Name == "WaypointLine" then
						v:Destroy()
					end
				end
				for i,v in pairs(waypoints) do
					if waypoints[i+1] then
						local part = Instance.new("Part")
						part.Parent = workspace:FindFirstChild("AI_Debris")
						part.Anchored = true
						part.CanCollide = false
						part.Name = "WaypointLine"
						part.Material = Enum.Material.Neon
						part.Size = Vector3.new(0.5,0.5,(v.Position - waypoints[i+1].Position).Magnitude)
						part.CFrame = CFrame.new(v.Position/2+waypoints[i+1].Position/2,waypoints[i+1].Position)
					end
				end
			end
			
			if waypoints[getgenv().waypoint] then
				currentPos = waypoints[getgenv().waypoint]
			else
				currentPos = nil
			end
		else
			warn(errorMessage)
			currentPos = nil
			plr.Character:FindFirstChild("Humanoid"):MoveTo(target.Position)
		end
	end

	-- Raycast function, checks to see if the enemy is in plane sight
	local function raycast(target)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = {plr.Character:GetDescendants(),workspace:FindFirstChild("AI_Debris"):GetDescendants()}

		local raycast = workspace:Raycast(plr.Character:FindFirstChild("HumanoidRootPart").Position,CFrame.lookAt(plr.Character:FindFirstChild("HumanoidRootPart").Position,target.HumanoidRootPart.Position).LookVector*500,params)

		if raycast then
			if raycast.Instance:FindFirstAncestor(target.Name) then
				return true
			end
		end
	end

	-- Loops the functions to keep character up-to-date
	local dist = nil

	spawn(function()
		while task.wait() do
			if plr.Character and getgenv().enabled then
				if plr.Character:WaitForChild("Humanoid").Health > 0 then
					plr.Character:FindFirstChild("Humanoid").CameraOffset = Vector3.new(0,1.5,0)
					plr.Character:FindFirstChild("Humanoid").AutoRotate = false
					plr.Character:FindFirstChild("Humanoid").WalkSpeed = getgenv().config.Speed

					local targets = getTargets()
					local closest = nil
					local event = game:GetService("ReplicatedStorage").Modules.Network:FindFirstChild("RemoteEvent")

					if targets then
						closest = findClosest(targets)
					end

					-- Check if target is in plain site
					if closest then
						if raycast(closest) then
							getgenv().target = closest

							for i,v in pairs(workspace:FindFirstChild("AI_Debris"):GetChildren()) do
								if v:IsA("BasePart") and v.Name == "WaypointLine" then
									v:Destroy()
								end
							end

							local part = Instance.new("Part")
							part.Parent = workspace:FindFirstChild("AI_Debris")
							part.Anchored = true
							part.CanCollide = false
							part.Name = "WaypointLine"
							part.Material = Enum.Material.Neon
							part.Size = Vector3.new(0.5,0.5,(root.Position - closest.HumanoidRootPart.Position).Magnitude)
							part.CFrame = CFrame.new(closest.HumanoidRootPart.Position/2+root.Position/2,closest.HumanoidRootPart.Position)
						else
							getgenv().target = nil
							followPath(closest:FindFirstChild("HumanoidRootPart"))
						end
					end

					-- Attack with weapon
					local tool = nil

					if plr.Character:FindFirstChildOfClass("Model") and plr.Character:FindFirstChildOfClass("Model"):FindFirstChild("Handle") then
						tool = plr.Character:FindFirstChildOfClass("Model")
					end

					if tool and targets then
						for i,v in pairs(targets) do
							if v:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("HumanoidRootPart") and (v:FindFirstChild("HumanoidRootPart").Position - plr.Character.HumanoidRootPart.Position).Magnitude then
								event:FireServer("WeaponDamage",tool.Name,v.Humanoid)
							end
						end
					end

					-- Draw Hitbox
					if closest then
						selBox.Adornee = closest:FindFirstChild("HumanoidRootPart")
					else
						selBox.Adornee = nil
					end

					-- Use abilities
					if getgenv().target then
						for i = 1,2 do
							local get, get2 = loadModule("FindById")(data.Abilities,data["EquippedAbility" .. i])
						
							if get and get2 then
								local getModule = require(game:GetService("ReplicatedStorage").Modules.Abilities:FindFirstChild(get2[2]))
						
								if closest and not plr.PlayerGui.ScreenGui.Toolbar.Toolbar:FindFirstChild("Ability"..i).CooldownOverlay.Visible then
									if (closest.HumanoidRootPart.Position - plr.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < getgenv().config.Distance then
										local params = getModule.Params
										
										if params.Position then
											params.Position = closest.HumanoidRootPart.Position
										end
										
										event:FireServer("AbilityAttack",data["EquippedAbility" .. i],params)
										loadModule("GuiService").SubModules.Toolbar.startCooldown(i,getModule.Cooldown)
									end
								end
							end
						end
					end
				end
			end
		end
	end)

	local ignore = {}
	local isPlayingAnimation = nil

	local bossAnimations = {
		AbaddonCharge = "rbxassetid://4525088683", -- Beam
		AbaddonShock = "rbxassetid://4525125313", -- Spin
		AbaddonStorm = "rbxassetid://4525182843", -- Circle
	}

	game:GetService("RunService").RenderStepped:Connect(function()
		-- Checks to surroundings
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Blacklist
			params.FilterDescendantsInstances = {plr.Character:GetDescendants(),workspace.Enemies:GetDescendants(),workspace:FindFirstChild("AI_Debris"):GetDescendants()}

			local range = getgenv().range

			area.Up = workspace:Raycast(root.Position,root.CFrame.UpVector*range,params)
			area.Down = workspace:Raycast(root.Position,-root.CFrame.UpVector*(range+5),params)

			area.Front = workspace:Raycast(root.Position,root.CFrame.LookVector*range,params)
			area.Back = workspace:Raycast(root.Position,-root.CFrame.LookVector*range,params)

			area.Right = workspace:Raycast(root.Position,root.CFrame.RightVector*range,params)
			area.Left = workspace:Raycast(root.Position,-root.CFrame.RightVector*range,params)

			local params2 = OverlapParams.new()
			params2.FilterType = Enum.RaycastFilterType.Whitelist
			params2.FilterDescendantsInstances = {workspace.Ignore:GetDescendants()}
			
			area.Around = workspace:GetPartBoundsInRadius(root.Position,3,params2)
		end

		-- Find and run to enemies
		if plr.Character and getgenv().enabled and not disabled then
			if plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0 then
				local targets = getTargets()
				local closest = nil

				if targets then
					closest = findClosest(targets)
				end

				if closest then
					local root = plr.Character.HumanoidRootPart

					if rotate then
						root.CFrame = CFrame.lookAt(root.Position,Vector3.new(closest.HumanoidRootPart.Position.X,root.Position.Y,closest.HumanoidRootPart.Position.Z))
					end

					if raycast(closest) then
						local pos = closest.HumanoidRootPart.Position - root.CFrame.LookVector * getgenv().config.Distance

						if area.Back then
							if not area.Right then
								pos = root.Position + root.CFrame.RightVector * getgenv().config.Distance
							elseif not area.Left then
								pos = root.Position - root.CFrame.RightVector * getgenv().config.Distance
							else
								pos = root.Position + root.CFrame.LookVector * getgenv().config.Distance
							end
						end
						
						if not stop then
							plr.Character:FindFirstChild("Humanoid"):MoveTo(pos)
						end
					elseif currentPos then
						if currentPos.Action == Enum.PathWaypointAction.Jump then
							plr.Character.Humanoid.Jump = true
						end

						if not stop then
							plr.Character.Humanoid:MoveTo(currentPos.Position)
						end
					end
				end
			end
		end

		-- Dodge System
		local root = plr.Character:FindFirstChild("HumanoidRootPart")

		if #ignore > 0 and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid").Health > 0 and getgenv().enabled then
			for i,v in pairs(ignore) do
				task.wait()
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Whitelist
				params.FilterDescendantsInstances = {plr.Character:GetDescendants()}
				
				local params2 = RaycastParams.new()
				params2.FilterType = Enum.RaycastFilterType.Blacklist
				params2.FilterDescendantsInstances = {plr.Character:GetDescendants(),workspace:FindFirstChild("AI_Debris"):GetDescendants()}

				local cframe = CFrame.new(root.Position,v.Position)
				local cast = workspace:Raycast(v.Position,-cframe.LookVector*500,params)

				if cast then
					local checkRight = workspace:Raycast(root.Position,root.CFrame.RightVector*(getgenv().range+3),params2)
					local checkLeft = workspace:Raycast(root.Position,-root.CFrame.RightVector*(getgenv().range+3),params2)

					if not checkRight then
						root.CFrame = root.CFrame + root.CFrame.RightVector * 0.5
						--plr.Character:FindFirstChild("Humanoid"):MoveTo(root.Position+root.CFrame.RightVector*3)
					elseif not checkLeft then
						root.CFrame = root.CFrame - root.CFrame.RightVector * 0.5
						--plr.Character:FindFirstChild("Humanoid"):MoveTo(root.Position-root.CFrame.RightVector*3)
					elseif not area.Back then
						root.CFrame = root.CFrame - root.CFrame.LookVector * 1
						--plr.Character:FindFirstChild("Humanoid"):MoveTo(root.Position-root.CFrame.LookVector*3)
					end
				end
			end
		end
		if getgenv().enabled and area.Down then
			if area.Down.Instance.Name == "Circle" then
				if area.Down.Instance.Color:ToHex() ~= "72ff87" and area.Down.Instance.Color:ToHex() ~= "00c8ff" then
					local params2 = RaycastParams.new()
					params2.FilterType = Enum.RaycastFilterType.Blacklist
					params2.FilterDescendantsInstances = {plr.Character:GetDescendants(),workspace:FindFirstChild("AI_Debris"):GetDescendants()}

					local pos = (area.Down.Position-area.Down.Instance.Position)

					local checkRight = workspace:Raycast(root.Position,root.CFrame.RightVector*10,params2)
					local checkLeft = workspace:Raycast(root.Position,-root.CFrame.RightVector*10,params2)
					local checkFront = workspace:Raycast(root.Position,-root.CFrame.RightVector*10,params2)
					local checkBack = workspace:Raycast(root.Position,-root.CFrame.RightVector*10,params2)

					spawn(function()
						if not stop then
							stop = true
							task.wait(3)
							if stop then
								stop = false
							end
						end
					end)

					print(area.Down.Instance,area.Down.Instance.Parent)

					if not checkFront then
						root.CFrame = root.CFrame + root.CFrame.LookVector * 0.5
						--plr.Character:FindFirstChild("Humanoid"):MoveTo(root.Position+root.CFrame.LookVector*3)
					elseif not checkBack then
						root.CFrame = root.CFrame - root.CFrame.LookVector * 0.5
						--plr.Character:FindFirstChild("Humanoid"):MoveTo(root.Position-root.CFrame.LookVector*3)
					elseif not checkRight then
						root.CFrame = root.CFrame + root.CFrame.RightVector * 0.5
						--plr.Character:FindFirstChild("Humanoid"):MoveTo(root.Position+root.CFrame.RightVector*3)
					elseif not checkLeft then
						root.CFrame = root.CFrame - root.CFrame.RightVector * 0.5
						--plr.Character:FindFirstChild("Humanoid"):MoveTo(root.Position-root.CFrame.RightVector*3)
					end
				end
			end
			if area.Around then
				for i,v in pairs(area.Around) do
					if v.Name == "Part" then
						spawn(function()
							if not stop then
								stop = true
								task.wait(3)
								if stop then
									stop = false
								end
							end
						end)

						if not area.Right then
							--root.CFrame = root.CFrame + root.CFrame.RightVector * 3
							plr.Character:FindFirstChild("Humanoid"):MoveTo(root.Position+root.CFrame.RightVector*3)
						elseif not area.Left then
							--root.CFrame = root.CFrame - root.CFrame.RightVector * 3
							plr.Character:FindFirstChild("Humanoid"):MoveTo(root.Position-root.CFrame.RightVector*3)
						end
					end
				end
			end
		end
		if getgenv().enabled and isPlayingAnimation then
			if isPlayingAnimation == "AbaddonCharge" then
				if not area.Right then
					--root.CFrame = root.CFrame + root.CFrame.RightVector * 1
					plr.Character:FindFirstChild("Humanoid"):MoveTo(root.Position+root.CFrame.RightVector*3)
				elseif not area.Left then
					--root.CFrame = root.CFrame - root.CFrame.RightVector * 1
					plr.Character:FindFirstChild("Humanoid"):MoveTo(root.Position-root.CFrame.RightVector*3)
				end
			elseif isPlayingAnimation == "AbaddonShock" then
				if not area.Back and getgenv().target and (getgenv().target.HumanoidRootPart.Position - root.Position).Magnitude < 30 then
					--root.CFrame = root.CFrame - root.CFrame.LookVector * 1
					plr.Character:FindFirstChild("Humanoid"):MoveTo(root.Position-root.CFrame.LookVector*3)
				end
			end
		end
	end)
	
	-- Dodge System (Functions)
	spawn(function()
		repeat task.wait() until workspace.Ignore:FindFirstChild("AttachmentRoot")

		workspace.Ignore:FindFirstChild("AttachmentRoot").ChildAdded:Connect(function(child)
			task.wait()

			local check = false
			
			for i,v in pairs(child:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					local sequence = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,0.2,0)),ColorSequenceKeypoint.new(1,Color3.new(1,0,0))}

					if v.Color == sequence then
						check = true
					end
				end
			end

			if not check then
				--rotate = false
				table.insert(ignore,child)
				task.wait(2)
				for i,v in pairs(ignore) do
					if v == child then
						--rotate = true
						table.remove(ignore,i)
					end
				end
			end
		end)

		--[[workspace.Ignore:FindFirstChild("AttachmentRoot").ChildRemoved:Connect(function(child)
			for i,v in pairs(ignore) do
				if v == child then
					--rotate = true
					table.remove(ignore,i)
				end
			end
		end)]]
	end)

	spawn(function()
		while task.wait() do
			local atBoss = plr.PlayerGui.ScreenGui:FindFirstChild("DungeonProgress"):FindFirstChild("Boss").Visible

			if atBoss then
				local boss = workspace.Enemies:FindFirstChildOfClass("Model")
				local anims = boss:FindFirstChild("Humanoid"):GetPlayingAnimationTracks()

				isPlayingAnimation = nil

				if #anims >= 2 then
					for i,v in pairs(bossAnimations) do
						if v == anims[2].Animation.AnimationId then
							if anims[2].TimePosition >= 1 and anims[2].TimePosition <= 2 then
								isPlayingAnimation = i
							end
						end
					end
				end
			end
		end
	end)

	-- Get player unstuck
	spawn(function()
		while task.wait() do
			pcall(function()
				if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not plr.PlayerGui.ScreenGui:FindFirstChild("Results").Visible and getgenv().enabled then
					local atBoss = plr.PlayerGui.ScreenGui:FindFirstChild("DungeonProgress"):FindFirstChild("Boss").Visible

					if not atBoss then
						local pos1 = plr.Character.HumanoidRootPart.Position
						task.wait(5)
						local pos2 = plr.Character.HumanoidRootPart.Position
						
						if (pos1-pos2).Magnitude < 0.5 then
							if not area.Front then
								plr.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + plr.Character.HumanoidRootPart.CFrame.LookVector * 30 + Vector3.new(0,2,0)
							elseif not area.Back then
								plr.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame - plr.Character.HumanoidRootPart.CFrame.LookVector * 30 + Vector3.new(0,2,0)
							elseif not area.Right then
								plr.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + plr.Character.HumanoidRootPart.CFrame.RightVector * 30 + Vector3.new(0,2,0)
							elseif not area.Left then
								plr.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame - plr.Character.HumanoidRootPart.CFrame.RightVector * 30 + Vector3.new(0,2,0)
							end

							task.wait(0.1)

							plr.Character:FindFirstChild("Humanoid").Jump = true
						end
					end
				end
			end)
		end
	end)
end
end
  
warn("Execution Complete! Enjoy Auto Farm!")
    
    
    
    
