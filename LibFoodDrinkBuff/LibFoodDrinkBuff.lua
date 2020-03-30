--Library constants are missing?
assert(not LIB_FOOD_DRINK_BUFF, GetString(SI_LIB_FOOD_DRINK_BUFF_LIBRARY_CONSTANTS_MISSING))

--Get global which was defined in constants
local lib = LIB_FOOD_DRINK_BUFF

----------------------------
-- LOCAL HELPER FUNCTIONS --
----------------------------
--Get the clien'ts language
local function GetClientLang()
	local language = GetCVar("language.2")
	return lib.LANGUAGES_SUPPORTED[language] and language or LFDB_LANGUAGE_ENGLISH
end

--Check if a string contains a blacklisted pattern
local function DoesStringContainsBlacklistPattern(text)
	local patternFound
	local blacklistStringPattern = lib.BLACKLIST_STRING_PATTERN[lib.clientLanguage]
	for index, pattern in ipairs(blacklistStringPattern) do
		patternFound = text:lower():find(pattern:lower())
		if patternFound then
			return true
		end
	end
	return false
end

--Get the ability's buffType (food or drink)
local function GetBuffTypeInfos(abilityId)
-- Returns 2: number buffTypeFoodDrink, bool isDrink
	local drinkBuffType = lib.DRINK_BUFF_ABILITIES[abilityId]
	if drinkBuffType then
		return drinkBuffType, true
	end
	local foodBuffType = lib.FOOD_BUFF_ABILITIES[abilityId]
	if foodBuffType then
		return foodBuffType, false
	end
	return NONE, nil --NONE = 0
end


---------------
-- COLLECTOR --
---------------
local ARGUMENT_ALL = 1
local ARGUMENT_NEW = 2

local MAX_ABILITY_ID = 2000000
local MAX_ABILITY_DURATION = 2000000

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


local collector = { }

function collector:Initialize(async)
	self.TaskScan = async:Create(LFDB_LIB_IDENTIFIER.. "_Collector")
	self:InitializeSlashCommands()
end

function collector:InitializeSlashCommands()
	SLASH_COMMANDS["/dumpfdb"] = function(saveType)
		saveType = saveType == "new" and ARGUMENT_NEW or saveType == "all" and ARGUMENT_ALL
		if saveType then
			lib.chat:Print(GetString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_START))

			-- get/set savedVars
			if not self.sv then
				LibFoodDrinkBuff_Save = LibFoodDrinkBuff_Save or { }
				self.sv = LibFoodDrinkBuff_Save
				LibFoodDrinkBuff_Save = self.sv 
			end
			-- clear old savedVars
			self.sv.foodDrinkBuffList = { }

			-- start new scan
			self.TaskScan:For(1, MAX_ABILITY_ID):Do(function(abilityId)
				if DoesAbilityExist(abilityId) then
					self:AddToFoodDrinkTable(abilityId, saveType)
				end
			end):Then(function()
				-- update the savedVars timestamp
				self.sv.lastUpdated = { }
				self.sv.lastUpdated.timestamp = os.date()
				self.sv.lastUpdated.saveType = saveType
				self:NotificationAfterCreatingFoodDrinkTable()
			end)

		else
			lib.chat:Print(ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING, GetString(SI_ERROR_INVALID_COMMAND)))
		end
	end
end

function collector:NotificationAfterCreatingFoodDrinkTable()
	local countEntries = #self.sv.foodDrinkBuffList
	if countEntries > 0 then
		local data = { countEntries = countEntries }
		ZO_Dialogs_ShowDialog("LIB_FOOD_DRINK_BUFF_FOUND_DATA", data)
	else
		lib.chat:Print(ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_EXPORT_FINISH, countEntries))
	end
end

function collector:AddToFoodDrinkTable(abilityId, saveType)
	if saveType == ARGUMENT_NEW and GetBuffTypeInfos(abilityId) ~= NONE then
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
									if not DoesStringContainsBlacklistPattern(abilityName) then
										local ability = { }
										ability.abilityId = abilityId
										ability.abilityName = ZO_CachedStrFormat(SI_ABILITY_NAME, abilityName)
										ability.lua = ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_EXCEL, abilityId, abilityName)
										table.insert(self.sv.foodDrinkBuffList, ability)
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


---------------------
-- FOOD AND DRINKS --
---------------------
function lib:Initialize()
	self.addOnManager = GetAddOnManager()
	self.clientLanguage = GetClientLang()
	self.version = self:GetAddonVersionFromManifest()
	self.eventList = { }

	-- the collector is only active, if you have LibAsync
	self.async = LibAsync
	if self.async then
		collector:Initialize(self.async)
	end
end

-- Reads the addon version from the addon's txt manifest file tag ##AddOnVersion
function lib:GetAddonVersionFromManifest(addOnNameString)
-- Returns 1: number nilable:addOnVersion
	addOnNameString = addOnNameString or LFDB_LIB_IDENTIFIER
	if addOnNameString then
		local numAddOns = self.addOnManager:GetNumAddOns()
		for i = 1, numAddOns do
			if self.addOnManager:GetAddOnInfo(i) == addOnNameString then
				return self.addOnManager:GetAddOnVersion(i)
			end
		end
	end
	return nil
end

-- Get the clientLanguage of this lib
function lib:GetLanguage()
-- Returns 1: string language
	return self.clientLanguage
end

-- Get the allowed languages of this lib
function lib:GetSupportedLanguages()
-- Returns 1: table supportedLanguages[languageString] = boolean true/false
	return self.LANGUAGES_SUPPORTED
end

-- Get the addOnVersion of this lib
function lib:GetVersion()
-- Returns 1: number version
	return self.version
end

-- Maybe it helps for debug function to get all the active events
function lib:GetEvents()
-- Returns 1: table eventList
	return self.eventList
end

-- Calculate time left of a food/drink buff
function lib:GetTimeLeftInSeconds(timeEndingInMilliseconds)
-- Returns 1: number seconds
	return math.max(zo_roundToNearest(timeEndingInMilliseconds - GetGameTimeMilliseconds() / 1000, 1), 0)
end

function lib:GetFoodBuffInfos(unitTag)
-- Returns 8: number buffTypeFoodDrink, bool nilable:isDrink, number nilable:abilityId, string nilable:buffName, number nilable:timeStarted, number nilable:timeEnds, string nilable:iconTexture, number timeLeftInSeconds
	local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		local buffName, timeStarted, timeEnding, iconTexture, abilityId, buffTypeFoodDrink, isDrink
		for i = 1, numBuffs do
			-- Returns 13: string buffName, number timeStarted, number timeEnding, number buffSlot, number stackCount, string iconFilename, string buffType, number effectType, number abilityType, number statusEffectType, number abilityId, bool canClickOff, bool castByPlayer
			buffName, timeStarted, timeEnding, _, _, iconTexture, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
			buffTypeFoodDrink, isDrink = GetBuffTypeInfos(abilityId)
			if buffTypeFoodDrink ~= NONE then
				return buffTypeFoodDrink, isDrink, abilityId, ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_ABILITY_NAME, buffName), timeStarted, timeEnding, iconTexture, self:GetTimeLeftInSeconds(timeEnding)
			end
		end
	end
	return NONE, nil, nil, nil, nil, nil, nil, 0
end

function lib:GetFoodBuffAbilityData()
--returns 1: table foodBuffAbilityIds = LibFoodDrinkBuff_buffTypeConstant
	return lib.FOOD_BUFF_ABILITIES
end

function lib:GetDrinkBuffAbilityData()
--returns 1: table drinkBuffAbilityIds = LibFoodDrinkBuff_buffTypeConstant
	return lib.DRINK_BUFF_ABILITIES
end

function lib:IsFoodBuffActive(unitTag)
-- Returns 1: bool isBuffActive
	local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		local abilityId, buffTypeFoodDrink
		for i = 1, numBuffs do
			abilityId = select(11, GetUnitBuffInfo(unitTag, i))
			buffTypeFoodDrink = GetBuffTypeInfos(abilityId)
			if buffTypeFoodDrink ~= NONE then
				return true
			end
		end
	end
	return false
end

function lib:IsFoodBuffActiveAndGetTimeLeft(unitTag)
-- Returns 3: bool isBuffActive, number timeLeftInSeconds, number nilable:abilityId
	local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		local timeEnding, abilityId, buffTypeFoodDrink
		for i = 1, numBuffs do
			timeEnding, _, _, _, _, _, _, _, abilityId = select(3, GetUnitBuffInfo(unitTag, i))
			buffTypeFoodDrink = GetBuffTypeInfos(abilityId)
			if buffTypeFoodDrink ~= NONE then
				return true, self:GetTimeLeftInSeconds(timeEnding), abilityId
			end
		end
	end
	return false, 0, nil
end

function lib:IsAbilityAFoodBuff(abilityId)
-- Returns 1: nilable:bool isAbilityADrinkBuff(true) or isAbilityAFoodBuff(false), or nil if not a food or drink buff
	local _, isDrinkTrueOrFoodFalse = GetBuffTypeInfos(abilityId)
	if isDrinkTrueOrFoodFalse == true then
		return false
	elseif isDrinkTrueOrFoodFalse == false then
		return true
	end
	return nil
end

function lib:IsAbilityADrinkBuff(abilityId)
-- Returns 1: nilable:bool isAbilityADrinkBuff(true) or isAbilityAFoodBuff(false), or nil if not a food or drink buff
	local _, isDrinkTrueOrFoodFalse = GetBuffTypeInfos(abilityId)
	if isDrinkTrueOrFoodFalse == true then
		return true
	elseif isDrinkTrueOrFoodFalse == false then
		return false
	end
	return nil
end

function lib:IsConsumableItem(bagId, slotIndex)
-- Returns 1: bool isConsumableItem
	local itemType = GetItemType(bagId, slotIndex)
	if itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_FOOD then
		return DoesStringContainsBlacklistPattern(GetItemName(bagId, slotIndex)) == false
	end
	return false
end

function lib:ConsumeItemFromInventory(slotIndex)
-- Returns 1: bool successfulConsummation
	local usable, usableOnlyFromActionSlot = IsItemUsable(BAG_BACKPACK, slotIndex)
	local canInteract = CanInteractWithItem(BAG_BACKPACK, slotIndex)
	if usable and canInteract and not usableOnlyFromActionSlot then
		if self:IsConsumableItem(BAG_BACKPACK, slotIndex) then
			if IsProtectedFunction("UseItem") then
				return CallSecureProtected("UseItem", BAG_BACKPACK, slotIndex)
			else
				return UseItem(BAG_BACKPACK, slotIndex)
			end
		end
	end
	return false
end

function lib:GetConsumablesItemListFromInventory()
-- Returns 1: table consumableItemsInInventory
	return PLAYER_INVENTORY:GenerateListOfVirtualStackedItems(INVENTORY_BACKPACK, function(bagId, slotIndex)
		return self:IsConsumableItem(bagId, slotIndex)
	end)
end


------------
-- EVENTS --
------------
local function GetIndexOfNamespaceInEventsList(table, element)
	for index, value in ipairs(table) do
		if value.addonEventNamespace == element then
			return index
		end
	end
	return nil
end

-- Filter the event EVENT_EFFECT_CHANGED to the local player and only the abilityIds of the food/drink buffs
-- Possible additional filterTypes are:
-- REGISTER_FILTER_UNIT_TAG, REGISTER_FILTER_UNIT_TAG_PREFIX or more https://wiki.esoui.com/AddFilterForEvent ,
-- but DO NOT USE the filterType REGISTER_FILTER_ABILITY_ID, because this is already handled by the function (RegisterAbilityIdsFilterOnEventEffectChanged) itself!
--> Performance gain as you check if a food/drink buff got active (gained, refreshed), or was removed (faded, refreshed)
function lib:RegisterAbilityIdsFilterOnEventEffectChanged(addonEventNamespace, callbackFunc, ...)
-- Returns 1: nilable:succesfulRegister
	local typeNamespace = type(addonEventNamespace) == "string"
	if typeNamespace then
		assert(addonEventNamespace ~= "", LFDB_LIB_IDENTIFIER .. ": Parameter 'addonEventNameSpace' is an empty string.")
		assert(type(callbackFunc) == "function", LFDB_LIB_IDENTIFIER .. ": Parameter 'callbackFunc' is not a function.")

		local index = GetIndexOfNamespaceInEventsList(self.eventList, addonEventNameSpace)
		if not index then
			EVENT_MANAGER:RegisterForEvent(addonEventNameSpace, EVENT_EFFECT_CHANGED, function(_, ...)
				local abilityId = select(15, ...)
				if lib.FOOD_BUFF_ABILITIES[abilityId] or lib.DRINK_BUFF_ABILITIES[abilityId] then
					callbackFunc(...)
					-- Returns 16: changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType
				end
			end)

			-- Multiple filters are handled here:
			-- ... is a table like { filterType1, filterParameter1, filterType2, filterParameter2, filterType3, filterParameter3, ... }
			-- You can only have one filterParameter for each filterType.
			local filterParams = { ... }
			if next(filterParams) then
				for i = 1, select("#", filterParams), 2 do
					local filterType = select(i, filterParams)
					local filterParameter = select(i + 1, filterParams)
					EVENT_MANAGER:AddFilterForEvent(addonEventNameSpace, EVENT_EFFECT_CHANGED, filterType, filterParameter)
				end
			end

			table.insert(self.eventList, { addonEventNamespace = addonEventNamespace, callbackFunc = callbackFunc, filterParams = filterParams })
			return true
		end
	end
	assert(typeNamespace, LFDB_LIB_IDENTIFIER .. ": Parameter 'addonEventNameSpace' is not a string.")
	return nil
end

-- Unregister the register function above
function lib:UnRegisterAbilityIdsFilterOnEventEffectChanged(addonEventNamespace)
-- Returns 1: nilable:succesfulUnregister
	local index = GetIndexOfNamespaceInEventsList(self.eventList, addonEventNamespace)
	if index then
		EVENT_MANAGER:UnregisterForEvent(addonEventNamespace, EVENT_EFFECT_CHANGED)
		table.remove(self.eventList, index)
		return true
	end
	return nil
end

local function OnAddOnLoaded(_, addOnName)
	if addOnName == LFDB_LIB_IDENTIFIER then
		EVENT_MANAGER:UnregisterForEvent(LFDB_LIB_IDENTIFIER, EVENT_ADD_ON_LOADED)
		lib:Initialize()
	end
end
EVENT_MANAGER:RegisterForEvent(LFDB_LIB_IDENTIFIER, EVENT_ADD_ON_LOADED, OnAddOnLoaded)


-------------
-- GLOBALS --
-------------
function DEBUG_ACTIVE_BUFFS(unitTag)
	unitTag = unitTag or LFDB_PLAYER_TAG

	local entries = {}
	table.insert(entries, zo_strformat("Debug \"<<1>>\" Buffs:", unitTag))
	local buffName, abilityId, _
	local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		for i = 1, numBuffs do
			buffName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
			table.insert(entries, zo_strformat("<<1>>. [<<2>>] <<C:3>>", i, abilityId, ZO_SELECTED_TEXT:Colorize(buffName)))
		end
	else
		table.insert(entries, GetString(SI_LIB_FOOD_DRINK_BUFF_NO_BUFFS))
	end

	lib.chat:Print(table.concat(entries, "\n"))
end