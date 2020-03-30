-- Library was not loaded yet?
assert(not LIB_FOOD_DRINK_BUFF, string.format(GetString(SI_LIB_FOOD_DRINK_BUFF_LIBRARY_LOADED), LFDB_LIB_IDENTIFIER))

local lib = { }

-- Reads the addon version from the addon's txt manifest file tag ##AddOnVersion
local addOnManager = GetAddOnManager()
function lib:GetAddonVersionFromManifest(addOnNameString)
-- Returns 1: number nilable:addOnVersion
	if addOnNameString then
		local numAddOns = addOnManager:GetNumAddOns()
		for i = 1, numAddOns do
			if addOnManager:GetAddOnInfo(i) == addOnNameString then
				return addOnManager:GetAddOnVersion(i)
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
			buffTypeFoodDrink, isDrink = lib:GetBuffTypeInfos(abilityId)
			if buffTypeFoodDrink ~= LFDB_BUFF_TYPE_NONE then
				return buffTypeFoodDrink, isDrink, abilityId, ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_ABILITY_NAME, buffName), timeStarted, timeEnding, iconTexture, self:GetTimeLeftInSeconds(timeEnding)
			end
		end
	end
	return LFDB_BUFF_TYPE_NONE, nil, nil, nil, nil, nil, nil, 0
end

function lib:GetFoodBuffAbilityData()
-- Returns 1: table foodBuffAbilityIds = LibFoodDrinkBuff_buffTypeConstant
	return lib.FOOD_BUFF_ABILITIES
end

function lib:GetDrinkBuffAbilityData()
-- Returns 1: table drinkBuffAbilityIds = LibFoodDrinkBuff_buffTypeConstant
	return lib.DRINK_BUFF_ABILITIES
end

function lib:IsFoodBuffActive(unitTag)
-- Returns 1: bool isBuffActive
	local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		local abilityId, buffTypeFoodDrink
		for i = 1, numBuffs do
			abilityId = select(11, GetUnitBuffInfo(unitTag, i))
			buffTypeFoodDrink = lib:GetBuffTypeInfos(abilityId)
			if buffTypeFoodDrink ~= LFDB_BUFF_TYPE_NONE then
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
			buffTypeFoodDrink = lib:GetBuffTypeInfos(abilityId)
			if buffTypeFoodDrink ~= LFDB_BUFF_TYPE_NONE then
				return true, self:GetTimeLeftInSeconds(timeEnding), abilityId
			end
		end
	end
	return false, 0, nil
end

function lib:IsAbilityAFoodBuff(abilityId)
-- Returns 1: nilable:bool isAbilityAFoodBuff(true) or false; or nil if not a food or drink buff
	local _, isDrinkTrueOrFoodFalse = lib:GetBuffTypeInfos(abilityId)
	if isDrinkTrueOrFoodFalse == true then
		return false
	elseif isDrinkTrueOrFoodFalse == false then
		return true
	end
	return nil
end

function lib:IsAbilityADrinkBuff(abilityId)
-- Returns 1: nilable:bool isAbilityADrinkBuff(true) or false; or nil if not a food or drink buff
	local _, isDrinkTrueOrFoodFalse = lib:GetBuffTypeInfos(abilityId)
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
		return lib:DoesStringContainsBlacklistPattern(GetItemName(bagId, slotIndex)) == false
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

----------------
-- INITIALIZE --
----------------
function lib:Initialize()
	LibFoodDrinkBuff_InitializeConstants(self)
	LibFoodDrinkBuff_InitializeData(self)

	self.version = self:GetAddonVersionFromManifest(LFDB_LIB_IDENTIFIER)
	self.eventList = { }

	-- the collector is only active, if you have LibAsync
	self.async = LibAsync
	if self.async then
		LibFoodDrinkBuff_InitializeCollector(self)
	end
end

local function OnAddOnLoaded(_, addOnName)
	if addOnName == LFDB_LIB_IDENTIFIER then
		EVENT_MANAGER:UnregisterForEvent(LFDB_LIB_IDENTIFIER, EVENT_ADD_ON_LOADED)
		lib:Initialize()
		CALLBACK_MANAGER:FireCallbacks("LibFoodDrinkBuff_Initialized")
	end
end
EVENT_MANAGER:RegisterForEvent(LFDB_LIB_IDENTIFIER, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-------------
-- GLOBALS --
-------------
function DEBUG_ACTIVE_BUFFS(unitTag)
	unitTag = unitTag or "player"

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


LIB_FOOD_DRINK_BUFF = lib