-- Assure that library was loaded properly
assert(LIB_FOOD_DRINK_BUFF, string.format(GetString(SI_LIB_FOOD_DRINK_BUFF_LIBRARY_CONSTANTS_MISSING), LFDB_LIB_IDENTIFIER))

local lib = LIB_FOOD_DRINK_BUFF

function lib:InitializeCollector()
	--The collector is only active, if LibAsync is loaded
	if not self.async then return end

	--Register new ESO dialog
	ESO_Dialogs["LIB_FOOD_DRINK_BUFF_FOUND_DATA"] =
	{
		title =
		{
			text = SI_LIB_FOOD_DRINK_BUFF_DIALOG_TITLE,
		},
		mainText =
		{
			text = function(dialog) return zo_strformat(SI_LIB_FOOD_DRINK_BUFF_DIALOG_MAINTEXT, dialog.data.countEntries) end
		},
		buttons =
		{
			[1] =
			{
				text = SI_DIALOG_YES,
				callback = function() ReloadUI("ingame") end,
			},
			[2] =
			{
				text = SI_DIALOG_NO,
			},
		},
	}

	local ARGUMENT_ALL = 1
	local ARGUMENT_NEW = 2

	local MAX_ABILITY_ID = 2000000
	local MAX_ABILITY_DURATION = 2000000

	-- Add a slash command, to start collecting food/drink buffs
	local startScanAbilities = self.async:Create(LFDB_LIB_IDENTIFIER .. "_Collector")
	SLASH_COMMANDS["/dumpfdb"] = function(saveType)
		saveType = saveType == "new" and ARGUMENT_NEW or saveType == "all" and ARGUMENT_ALL
		if saveType then
			self.chat:Print(GetString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_START))
			local worldName = GetWorldName()

			-- Get and set the SavedVariables. We are not using ZO_SavedVars wrapper here but just the global table of self.svName!
			if not self.sv then
				_G[self.svName] = _G[self.svName] or { }
				self.sv = _G[self.svName]
				--TODO: Why do we need this?
				_G[self.svName] = self.sv
			end
			-- Clear old savedVars food and drink buff list of the current server
			local sv = self.sv
			local foodDrinkBuffList = sv.foodDrinkBuffList
			foodDrinkBuffList = foodDrinkBuffList or {}
			foodDrinkBuffList[worldName] = {}

			-- start new scan
			startScanAbilities:For(1, MAX_ABILITY_ID):Do(function(abilityId)
				if DoesAbilityExist(abilityId) then
					self:AddToFoodDrinkTable(abilityId, saveType, worldName)
				end
			end):Then(function()
				-- update the savedVars timestamp
				sv.lastUpdated = sv.lastUpdated or {}
				sv.lastUpdated[worldName] = {}
				local lastUpdated = sv.lastUpdated[worldName]
				lastUpdated.timestamp = os.date()
				lastUpdated.saveType = saveType
				self:NotificationAfterCreatingFoodDrinkTable(worldName)
			end)

		else
			self.chat:Print(ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING, GetString(SI_ERROR_INVALID_COMMAND)))
		end
	end

	function lib:NotificationAfterCreatingFoodDrinkTable(worldName)
		worldName = worldName or GetWorldName()
		if not self.sv or not self.sv.foodDrinkBuffList or not self.sv.foodDrinkBuffList[worldName] then return end
		local countEntries = #self.sv.foodDrinkBuffList[worldName]
		if countEntries > 0 then
			local data = { countEntries = countEntries }
			ZO_Dialogs_ShowDialog("LIB_FOOD_DRINK_BUFF_FOUND_DATA", data)
		else
			self.chat:Print(ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_EXPORT_FINISH, countEntries))
		end
	end

	function lib:AddToFoodDrinkTable(abilityId, saveType, worldName)
		if not self.sv then return end
		worldName = worldName or GetWorldName()
		if saveType == ARGUMENT_NEW and self:GetBuffTypeInfos(abilityId) ~= NONE then
			return
		end
		self.sv.foodDrinkBuffList = self.sv.foodDrinkBuffList or {}
		self.sv.foodDrinkBuffList[worldName] = self.sv.foodDrinkBuffList[worldName] or {}
		local foodDrinkBuffListOfWorldName = self.sv.foodDrinkBuffList[worldName]
		-- We gonna check the abilityId parameter step by step to increase performance during the check.
		if GetAbilityAngleDistance(abilityId) == 0 then
			if GetAbilityRadius(abilityId) == 0 then
				if GetAbilityDuration(abilityId) > MAX_ABILITY_DURATION then
					local minRangeCM, maxRangeCM = GetAbilityRange(abilityId)
					if minRangeCM == 0 and maxRangeCM == 0 then
						local cost, mechanic = GetAbilityCost(abilityId)
						if cost == 0 and mechanic == POWERTYPE_MAGICKA then
							local channeled, castTime = GetAbilityCastInfo(abilityId)
							if not channeled and castTime == 0 then
								if GetAbilityTargetDescription(abilityId) == GetString(SI_TARGETTYPE2) then
									if GetAbilityDescription(abilityId) ~= "" and GetAbilityEffectDescription(abilityId) == "" then
										local abilityName = GetAbilityName(abilityId)
										if not self:DoesStringContainsBlacklistPattern(abilityName) then
											local ability = { }
											ability.abilityId = abilityId
											ability.abilityName = ZO_CachedStrFormat(SI_ABILITY_NAME, abilityName)
											ability.lua = ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_EXCEL, abilityId, abilityName)
											table.insert(foodDrinkBuffListOfWorldName, ability)
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end