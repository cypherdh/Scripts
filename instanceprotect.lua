local function protect(lol)
	local instance = lol
	local function instances()
		local parents = {}
		local current = instance.Parent
		while current do
			local name = current.Name
			local temp = current.Parent
			while temp do
				name = temp.Name.."."..name
				temp = temp.Parent
			end
			name = name:gsub("^Game", "game")
			table.insert(parents, {name = name, instance = current})
			current = current.Parent
		end
		return parents
	end
	local parentdata = instances()
	local events = {
		"ChildAdded", "ChildRemoved",
		"DescendantAdded", "DescendantRemoving",
		"AncestryChanged",
		"Changed", "AttributeChanged", "GetPropertyChangedSignal",
		"Destroying",
		"Touched", "TouchEnded"
	}
	for _, v in ipairs(parentdata) do
		if v.instance and not rawequal(v.instance, tostring(nil)) then
			if not checkcaller() then return end
			if getconnections then
				for _, eventname in ipairs(events) do
					local h, event = pcall(function()
						return v.instance[eventname]
					end)
					if h and typeof(event) == "RBXScriptSignal" then
						for _, connection in pairs(getconnections(event)) do
							connection:Disable()
						end; task.wait(5)
						for _, connection in pairs(getconnections(event)) do
							connection:Enable()
						end
					end
				end
				if v.instance.ClassName == "ScreenGui" and gethui then
					local name = ""
					for _ = 1, math.random(4, 8) do
						name = name..string.char(math.random(97, 122))
					end
					if sethiddenproperty then
						sethiddenproperty(v.instance, "Parent", gethui())
						sethiddenproperty(v.instance, "Name", name)
					else
						v.instance.Parent = gethui()
						v.instance.Name = name
					end
				end
			end
		else
			parentdata = nil
			return error("please use a real instance")
		end
	end
	return parentdata
end

-- Example
protect(game.Players.LocalPlayer)
