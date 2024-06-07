-- Clone the stages [1] -- Part 1 of ensuring client-sided objects are unaffected by others
game:GetService("ReplicatedStorage"):WaitForChild("Stages"):Clone().Parent = game:GetService("Workspace");

-- Checkpoints & Recharge resets [13]
for _, obj:BasePart in game:GetService("CollectionService"):GetTagged("Checkpoint") do
	obj.Touched:Connect(function(hit:BasePart)
		for _, obj:BasePart in game:GetService("CollectionService"):GetTagged("Recharge") do
			obj:SetAttribute("Cooldown", nil)
			obj.Parent:ScaleTo(1)
		end
		if obj.Parent.Parent.Name ~= game:GetService("Players").LocalPlayer.PlayerGui.Overlay.Stage.Text then
			script.Checkpoint:Play()
			game:GetService("Players").LocalPlayer.PlayerGui.Overlay.Stage.Text = obj.Parent.Parent.Name
			game:GetService("ReplicatedStorage").Remotes.NewCheckpoint:FireServer(obj.Parent.Parent.Name)
		end
	end)
end

-- Teleports [6]
for _, obj:BasePart in game:GetService("CollectionService"):GetTagged("Teleport") do
	obj.Touched:Connect(function(hit:BasePart)
		script[(obj.Parent.Name == "Teleport" and "Teleport") or "Death"]:Play()
		game:GetService("Players").LocalPlayer.Character.PrimaryPart.CFrame = (obj:FindFirstChild("Destination") and obj.Destination.Value.CFrame) or game:GetService("Workspace").Stages[game:GetService("Players").LocalPlayer.PlayerGui.Overlay.Stage.Text or "001"].Checkpoint.Hitbox.CFrame
	end)
end

-- Recharge [16]
for _, obj:BasePart in game:GetService("CollectionService"):GetTagged("Recharge") do
	obj.Touched:Connect(function(hit:BasePart)
		if obj:GetAttribute("Cooldown") == nil or obj:GetAttribute("Cooldown") <= time() then
			obj:SetAttribute("Cooldown", time() + 3)
			obj.Parent:ScaleTo(0.5)
			task.delay(3.01, function()
				obj.Parent:ScaleTo((obj:GetAttribute("Cooldown") == nil or obj:GetAttribute("Cooldown") <= time() and 1) or 0.5)
			end)
			script.Recharge:Play()
			script:SetAttribute("DoubleJump", true)
			game:GetService("Players").LocalPlayer.PlayerGui.Overlay.Abilities.DoubleJump.ImageColor3 = Color3.fromRGB(255, 255, 255)
			script:SetAttribute("Dash", nil)
			game:GetService("Players").LocalPlayer.PlayerGui.Overlay.Abilities.Dash.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end
	end)
end

-- Spawn player (also sets stage) [1]
(game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart").CFrame = game:GetService("Workspace").Stages[(game:GetService("Players").LocalPlayer:GetAttribute("Stage") ~= nil or game:GetService("Players").LocalPlayer:GetAttributeChangedSignal("Stage"):Wait() == nil) and game:GetService("Players").LocalPlayer:GetAttribute("Stage")].Checkpoint.Hitbox.CFrame

-- Set Player's CollisionGroup [3] -- Part 2 of ensuring client-sided objects are unaffected by others
for _, playerPart in {"Head", "Hitbox", "HumanoidRootPart", "Left Arm", "Left Leg", "Right Arm", "Right Leg", "Torso"} do
	game:GetService("Players").LocalPlayer.Character:WaitForChild(playerPart).CollisionGroup = (playerPart == "Hitbox" and "PlayerHitbox") or "LocalPlayer"
end

-- Camera follow & Player transparency [6]
game:GetService("RunService").RenderStepped:Connect(function()
	game:GetService("Workspace").CurrentCamera.CFrame = CFrame.new(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 25), game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position)
	for _, plrPart in game:GetService("CollectionService"):GetTagged("PlayerPart") do
		plrPart.LocalTransparencyModifier = (game:GetService("Players"):GetPlayerFromCharacter(plrPart:FindFirstAncestorWhichIsA("Model")) == game:GetService("Players").LocalPlayer and plrPart.LocalTransparencyModifier) or (tonumber(game:GetService("Players").LocalPlayer.PlayerGui.Overlay.PlayerTransparency.Text) or 0)
	end
end)

-- Remote reset logic [3] -- Was originally a teleport, but consistent spinners were a higher priority.
task.delay(2, function() -- Not good practice (since it COULD fail), but saves 3 lines.
	game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
end)

-- Double Jump & Dash [29]
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.Space and game:GetService("Players").LocalPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall and script:GetAttribute("DoubleJump") == true then
		script:SetAttribute("DoubleJump", false)
		game:GetService("Players").LocalPlayer.PlayerGui.Overlay.Abilities.DoubleJump.ImageColor3 = Color3.fromRGB(255, 0, 0)
		script.DoubleJump:Play()
		game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	elseif not gameProcessed and input.KeyCode == Enum.KeyCode.L and ( script:GetAttribute("Dash") == nil or script:GetAttribute("Dash") <= time() ) then
		script:SetAttribute("Dash", time() + 0.7)
		game:GetService("Players").LocalPlayer.PlayerGui.Overlay.Abilities.Dash.ImageColor3 = Color3.fromRGB(255, 0, 0)
		task.delay(0.71, function()
			game:GetService("Players").LocalPlayer.PlayerGui.Overlay.Abilities.Dash.ImageColor3 = ( (script:GetAttribute("Dash") == nil or script:GetAttribute("Dash") <= time()) and Color3.fromRGB(255, 255, 255) ) or Color3.fromRGB(255, 0, 0)
		end)
		script.Dash:Play()
		game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Dash.Enabled = true
		task.wait(0.2)
		game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Dash.Enabled = false
	elseif not gameProcessed and input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
		game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.AlignOrientation.CFrame = (input.KeyCode == Enum.KeyCode.A and CFrame.Angles(0, math.rad(180), 0)) or (input.KeyCode == Enum.KeyCode.D and CFrame.new()) or game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.AlignOrientation.CFrame
	end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
		game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.AlignOrientation.CFrame = (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) and CFrame.Angles(0, math.rad(180), 0)) or (game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) and CFrame.new()) or game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.AlignOrientation.CFrame
	end
end)
game:GetService("Players").LocalPlayer.Character.Humanoid.Running:Connect(function()
	game:GetService("Players").LocalPlayer.PlayerGui.Overlay.Abilities.DoubleJump.ImageColor3 = Color3.fromRGB(255, 255, 255)
	script:SetAttribute("DoubleJump", true)
end)

-- Stage teleportation [5]
game:GetService("TextChatService").SendingMessage:Connect(function(msg:TextChatMessage)
	if string.find(msg.Text, ":") and tonumber(string.sub(msg.Text, 2)) <= tonumber(game:GetService("Players").LocalPlayer:GetAttribute("HighestStage")) and game:GetService("Workspace").Stages:FindFirstChild(string.sub(msg.Text, 2)) then
		game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Stages[string.sub(msg.Text, 2)].Checkpoint.Hitbox.CFrame
	end
end)
