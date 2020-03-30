local collector

function LibFoodDrinkBuff_InitializeCollector(lib)
	collector = lib

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

	local startScanAbilities = collector.async:Create(LFDB_LIB_IDENTIFIER .. "_Collector")
	SLASH_COMMANDS["/dumpfdb"] = function(saveType)
		saveType = saveType == "new" and ARGUMENT_NEW or saveType == "all" and ARGUMENT_ALL
		if saveType then
			collector.chat:Print(GetString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_START))

			-- get/set savedVars
			if not collector.sv then
				LibFoodDrinkBuff_Save = LibFoodDrinkBuff_Save or { }
				collector.sv = LibFoodDrinkBuff_Save
				LibFoodDrinkBuff_Save = collector.sv 
			end
			-- clear old savedVars
			collector.sv.foodDrinkBuffList = { }

			-- start new scan
			startScanAbilities:For(1, MAX_ABILITY_ID):Do(function(abilityId)
				if DoesAbilityExist(abilityId) then
					collector:AddToFoodDrinkTable(abilityId, saveType)
				end
			end):Then(function()
				-- update the savedVars timestamp
				collector.sv.lastUpdated = { }
				collector.sv.lastUpdated.timestamp = os.date()
				collector.sv.lastUpdated.saveType = saveType
				collector:NotificationAfterCreatingFoodDrinkTable()
			end)

		else
			collector.chat:Print(ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING, GetString(SI_ERROR_INVALID_COMMAND)))
		end
	end

	function collector:NotificationAfterCreatingFoodDrinkTable()
		local countEntries = #collector.sv.foodDrinkBuffList
		if countEntries > 0 then
			local data = { countEntries = countEntries }
			ZO_Dialogs_ShowDialog("LIB_FOOD_DRINK_BUFF_FOUND_DATA", data)
		else
			collector.chat:Print(ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_EXPORT_FINISH, countEntries))
		end
	end

	function collector:AddToFoodDrinkTable(abilityId, saveType)
		if saveType == ARGUMENT_NEW and collector:GetBuffTypeInfos(abilityId) ~= NONE then
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
										if not collector:DoesStringContainsBlacklistPattern(abilityName) then
											local ability = { }
											ability.abilityId = abilityId
											ability.abilityName = ZO_CachedStrFormat(SI_ABILITY_NAME, abilityName)
											ability.lua = ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_EXCEL, abilityId, abilityName)
											table.insert(collector.sv.foodDrinkBuffList, ability)
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

	LibFoodDrinkBuff_InitializeCollector = nil
end