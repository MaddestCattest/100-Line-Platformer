-- Change Stage [5]
game:GetService("ReplicatedStorage").Remotes.NewCheckpoint.OnServerEvent:Connect(function(player:Player, stage:string)
	player:SetAttribute("Stage", stage)
	player:SetAttribute("HighestStage", (tonumber(stage) > tonumber(player:GetAttribute("HighestStage")) and stage) or player:GetAttribute("HighestStage"))
	game:GetService("BadgeService"):AwardBadge(player.UserId, (tonumber(stage) >= 1 and 2966836762785711) or (tonumber(stage) >= 11 and 457901430483912) or (tonumber(stage) >= 21 and 2642762497958596) or (tonumber(stage) >= 31 and 4316930873594399) or (tonumber(stage) >= 41 and 4411909788945776) or (tonumber(stage) >= 51 and 1111916438675446))
end)

-- Load Data [5]
game:GetService("Players").PlayerAdded:Connect(function(player:Player)
	local data = game:GetService("DataStoreService"):GetDataStore("StageProgress"):GetAsync(player.UserId)
	player:SetAttribute("Stage",(data and data[1]) or "001")
	player:SetAttribute("HighestStage",(data and data[2]) or "001")
end)

-- Save Data [5]
game:GetService("Players").PlayerRemoving:Connect(function(player:Player)
	if player:GetAttribute("Stage") then
		game:GetService("DataStoreService"):GetDataStore("StageProgress"):SetAsync(player.UserId, {player:GetAttribute("Stage"), player:GetAttribute("HighestStage")})
	end
end)
