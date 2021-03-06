local module = {}

local menu = script.Parent.gameUI.menu_abilities

function module.show()
	menu.Visible = not menu.Visible
end
function module.hide()
	menu.Visible = false
end

local replicatedStorage = game:GetService("ReplicatedStorage")
local abilityLookup = require(replicatedStorage:WaitForChild("abilityLookup"))

function module.init(Modules)
	local network = Modules.network
	local uiCreator = Modules.uiCreator

	local abilityDataPairing = {}

	local function update(abilities)
		-- playerData.abilities
		abilities = abilities or network:invoke("getCacheValueByNameTag", "abilities")
		local unlockedAbilities = {}

		print(abilities)

		for _, abilityData in pairs(abilities) do
			-- TODO: check if REALLY unlocked
			table.insert(unlockedAbilities, abilityData)
			--print(abilityData)
		end

		-- clear existing buttons
		for _, button in pairs(menu.content:GetChildren()) do
			if button:IsA("GuiObject") then
				button:Destroy()
			end
			abilityDataPairing = {}
		end

		for i = 1, 9 do
			local template = menu.sampleAbility:clone()
			template.Name = i

			local abilityData = unlockedAbilities[i]
			if abilityData then
				local abilityInfo = abilityLookup[abilityData.id]

				template.item.Image = abilityInfo.image
				abilityDataPairing[template] = abilityData

				uiCreator.drag.setIsDragDropFrame(template.item)
				uiCreator.setIsDoubleClickFrame(template.item, 0.2, function()
					local thing, error = network:invoke("abilityUseRequest", abilityData.id)
				end)
			end

			template.Parent = menu.content
			template.Visible = true
		end
	end

	update()
	network:connect("propogationRequestToSelf", "Event", function(key, value)
		if key == "abilities" then
			update(value)
		end
	end)
	network:create("getAbilitySlotDataByAbilitySlotUI", "BindableFunction", "OnInvoke", function(button)
		return abilityDataPairing[button.Parent]
	end)
end





menu.close.Activated:connect(module.hide)

return module
