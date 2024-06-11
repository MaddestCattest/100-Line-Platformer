-- Change Stage [4]
game:GetService("ReplicatedStorage").Remotes.DataTransfer.OnServerEvent:Connect(function(player:Player, stage:string, death:number)
	player:SetAttribute("Data", string.format("%s|%s|%s", stage, (tonumber(stage) > tonumber( string.split(player:GetAttribute("Data"), "|")[2] ) and stage) or string.split(player:GetAttribute("Data"), "|")[2], death))
	game:GetService("BadgeService"):AwardBadge(player.UserId, (tonumber(stage) >= 51 and 1111916438675446) or (tonumber(stage) >= 41 and 4411909788945776) or (tonumber(stage) >= 31 and 4316930873594399) or (tonumber(stage) >= 21 and 2642762497958596) or (tonumber(stage) >= 11 and 457901430483912) or (tonumber(stage) >= 1 and 2966836762785711))
end)

-- Load Data [4]
game:GetService("Players").PlayerAdded:Connect(function(player:Player)
	local data = game:GetService("DataStoreService"):GetDataStore("StageProgress"):GetAsync(player.UserId)
	player:SetAttribute("Data", (data ~= nil and string.format("%s|%s|%s", data[1] or "001", data[2] or "001", data[3] or "0")) or "001|001|0")
end)

-- Save Data [5]
game:GetService("Players").PlayerRemoving:Connect(function(player:Player)
	if player:GetAttribute("Data") then
		game:GetService("DataStoreService"):GetDataStore("StageProgress"):SetAsync(player.UserId, string.split(player:GetAttribute("Data", "|")))
	end
end)
