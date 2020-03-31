local lib = LIB_FOOD_DRINK_BUFF or { }
LIB_FOOD_DRINK_BUFF = lib

function lib:InitializeCollector()
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
	local startScanAbilities = lib.async:Create(LFDB_LIB_IDENTIFIER .. "_Collector")
	SLASH_COMMANDS["/dumpfdb"] = function(saveType)
		saveType = saveType == "new" and ARGUMENT_NEW or saveType == "all" and ARGUMENT_ALL
		if saveType then
			lib.chat:Print(GetString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_START))

			-- get/set savedVars
			if not lib.sv then
				LibFoodDrinkBuff_Save = LibFoodDrinkBuff_Save or { }
				lib.sv = LibFoodDrinkBuff_Save
				LibFoodDrinkBuff_Save = lib.sv 
			end
			-- clear old savedVars
			lib.sv.foodDrinkBuffList = { }

			-- start new scan
			startScanAbilities:For(1, MAX_ABILITY_ID):Do(function(abilityId)
				if DoesAbilityExist(abilityId) then
					lib:AddToFoodDrinkTable(abilityId, saveType)
				end
			end):Then(function()
				-- update the savedVars timestamp
				lib.sv.lastUpdated = { }
				lib.sv.lastUpdated.timestamp = os.date()
				lib.sv.lastUpdated.saveType = saveType
				lib:NotificationAfterCreatingFoodDrinkTable()
			end)

		else
			lib.chat:Print(ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING, GetString(SI_ERROR_INVALID_COMMAND)))
		end
	end

	function lib:NotificationAfterCreatingFoodDrinkTable()
		local countEntries = #lib.sv.foodDrinkBuffList
		if countEntries > 0 then
			local data = { countEntries = countEntries }
			ZO_Dialogs_ShowDialog("LIB_FOOD_DRINK_BUFF_FOUND_DATA", data)
		else
			lib.chat:Print(ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_EXPORT_FINISH, countEntries))
		end
	end

	function lib:AddToFoodDrinkTable(abilityId, saveType)
		if saveType == ARGUMENT_NEW and lib:GetBuffTypeInfos(abilityId) ~= NONE then
			return
		end

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
										if not lib:DoesStringContainsBlacklistPattern(abilityName) then
											local ability = { }
											ability.abilityId = abilityId
											ability.abilityName = ZO_CachedStrFormat(SI_ABILITY_NAME, abilityName)
											ability.lua = ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_EXCEL, abilityId, abilityName)
											table.insert(lib.sv.foodDrinkBuffList, ability)
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