local LIB_IDENTIFIER = "LibFoodDrinkBuff"

local lib = { }

if LibChatMessage then
	lib.chat = LibChatMessage(LIB_IDENTIFIER, "LibFDB")
else
	lib.chat.Print = function(self, message) df("[%s] %s", LIB_IDENTIFIER, message) end
end

---------------
-- LANGUAGES --
---------------
local LANGUAGE_ENGLISH = "en"
local LANGUAGE_GERMAN = "de"
local LANGUAGE_FRENCH = "fr"

local LANGUAGES_SUPPORTED =
{
 [LANGUAGE_ENGLISH] = true,
 [LANGUAGE_GERMAN] = true,
 [LANGUAGE_FRENCH] = true,
}

local function IsSupportedLanguage(language)
	if LANGUAGES_SUPPORTED[language] then
		return true
	end
	return false
end

----------------
-- BUFF TYPES --
----------------
local NONE = 0
local MAX_HEALTH = 1
local MAX_MAGICKA = 2
local MAX_STAMINA = 4
local REGEN_HEALTH = 8
local REGEN_MAGICKA = 16
local REGEN_STAMINA = 32
local SPECIAL_VAMPIRE = 64
local FIND_FISHES = 128
local WEREWOLF_TRANSFORMATION = 256
local MAX_ALL = MAX_HEALTH + MAX_MAGICKA + MAX_STAMINA
local MAX_ALL_REGEN_HEALTH = MAX_ALL + REGEN_HEALTH
local MAX_HEALTH_MAGICKA = MAX_HEALTH + MAX_MAGICKA
local MAX_HEALTH_MAGICKA_FISH = MAX_HEALTH + MAX_MAGICKA + FIND_FISHES
local MAX_HEALTH_MAGICKA_REGEN_HEALTH_MAGICKA = MAX_HEALTH + REGEN_HEALTH + MAX_MAGICKA + REGEN_MAGICKA
local MAX_HEALTH_MAGICKA_REGEN_MAGICKA = MAX_HEALTH + MAX_MAGICKA + REGEN_MAGICKA
local MAX_HEALTH_MAGICKA_SPECIAL_VAMPIRE = MAX_HEALTH + MAX_MAGICKA + SPECIAL_VAMPIRE
local MAX_HEALTH_REGEN_ALL = MAX_HEALTH + REGEN_HEALTH + REGEN_MAGICKA + REGEN_STAMINA
local MAX_HEALTH_REGEN_HEALTH = MAX_HEALTH + REGEN_HEALTH
local MAX_HEALTH_REGEN_MAGICKA = MAX_HEALTH + REGEN_MAGICKA
local MAX_HEALTH_REGEN_STAMINA = MAX_HEALTH + REGEN_STAMINA
local MAX_HEALTH_REGEN_MAGICKA_STAMINA = MAX_HEALTH + REGEN_MAGICKA + REGEN_STAMINA
local MAX_HEALTH_STAMINA = MAX_HEALTH + MAX_STAMINA
local MAX_HEALTH_STAMINA_REGEN_HEALTH_STAMINA = MAX_HEALTH + REGEN_HEALTH + MAX_STAMINA + REGEN_STAMINA
local MAX_HEALTH_STAMINA_WEREWOLF = MAX_HEALTH_STAMINA + WEREWOLF_TRANSFORMATION
local MAX_MAGICKA_REGEN_HEALTH = MAX_MAGICKA + REGEN_HEALTH
local MAX_MAGICKA_REGEN_MAGICKA = MAX_MAGICKA + REGEN_MAGICKA
local MAX_MAGICKA_REGEN_STAMINA = MAX_MAGICKA + REGEN_STAMINA
local MAX_MAGICKA_STAMINA = MAX_MAGICKA + MAX_STAMINA
local MAX_STAMINA_HEALTH_REGEN_STAMINA = MAX_HEALTH + MAX_STAMINA + REGEN_STAMINA
local MAX_STAMINA_REGEN_HEALTH = MAX_STAMINA + REGEN_HEALTH
local MAX_STAMINA_REGEN_MAGICKA = MAX_STAMINA + REGEN_MAGICKA
local MAX_STAMINA_REGEN_STAMINA = MAX_STAMINA + REGEN_STAMINA
local REGEN_ALL = REGEN_HEALTH + REGEN_MAGICKA + REGEN_STAMINA
local REGEN_HEALTH_MAGICKA = REGEN_HEALTH + REGEN_MAGICKA
local REGEN_HEALTH_STAMINA = REGEN_HEALTH + REGEN_STAMINA
local REGEN_MAGICKA_STAMINA = REGEN_MAGICKA + REGEN_STAMINA
local REGEN_MAGICKA_STAMINA_FISH = REGEN_MAGICKA + REGEN_STAMINA + FIND_FISHES


--------------------
-- DRINKS'n'FOODS --
--------------------
local DRINK_BUFF_ABILITIES = {
	[61322] = REGEN_HEALTH, -- Health Recovery
	[61325] = REGEN_MAGICKA, -- Magicka Recovery
	[61328] = REGEN_STAMINA, -- Health & Magicka Recovery
	[61335] = REGEN_HEALTH_MAGICKA, -- Health & Magicka Recovery
	[61340] = REGEN_HEALTH_STAMINA, -- Health & Stamina Recovery
	[61345] = REGEN_MAGICKA_STAMINA, -- Magicka & Stamina Recovery
	[61350] = REGEN_ALL, -- All Primary Stat Recovery
	[66125] = MAX_HEALTH, -- Increase Max Health
	[66132] = REGEN_HEALTH, -- Health Recovery (Alcoholic Drinks)
	[66137] = REGEN_MAGICKA, -- Magicka Recovery (Tea)
	[66141] = REGEN_STAMINA, -- Stamina Recovery (Tonics)
	[66586] = REGEN_HEALTH, -- Health Recovery
	[66590] = REGEN_MAGICKA, -- Magicka Recovery
	[66594] = REGEN_STAMINA, -- Stamina Recovery
	[68416] = REGEN_ALL, -- All Primary Stat Recovery (Crown Refreshing Drink)
	[72816] = REGEN_HEALTH_MAGICKA, -- Red Frothgar
	[72965] = REGEN_HEALTH_STAMINA, -- Health and Stamina Recovery (Cyrodilic Field Brew)
	[72968] = REGEN_HEALTH_MAGICKA, -- Health and Magicka Recovery (Cyrodilic Field Tea)
	[72971] = REGEN_MAGICKA_STAMINA, -- Magicka and Stamina Recovery (Cyrodilic Field Tonic)
	[84700] = REGEN_HEALTH_MAGICKA, -- 2h Witches event: Eyeballs
	[84704] = REGEN_ALL, -- 2h Witches event: Witchmother's Party Punch
	[84720] = MAX_MAGICKA_REGEN_MAGICKA, -- 2h Witches event: Eye Scream
	[84731] = MAX_HEALTH_MAGICKA_REGEN_MAGICKA, -- 2h Witches event: Witchmother's Potent Brew
	[84732] = REGEN_HEALTH, -- Increase Health Regen
	[84733] = REGEN_HEALTH, -- Increase Health Regen
	[84735] = MAX_HEALTH_MAGICKA_SPECIAL_VAMPIRE, -- 2h Witches event: Double Bloody Mara
	[85497] = REGEN_ALL, -- All Primary Stat Recovery
	[86559] = REGEN_MAGICKA_STAMINA_FISH, -- Hissmir Fish Eye Rye
	[86560] = REGEN_STAMINA, -- Stamina Recovery
	[86673] = MAX_STAMINA_REGEN_STAMINA, -- Lava Foot Soup & Saltrice
	[86674] = REGEN_STAMINA, -- Stamina Recovery
	[86677] = MAX_STAMINA_REGEN_HEALTH, -- Warning Fire (Bergama Warning Fire)
	[86678] = REGEN_HEALTH, -- Health Recovery
	[86746] = REGEN_HEALTH_MAGICKA, -- Betnikh Spiked Ale (Betnikh Twice-Spiked Ale)
	[86747] = REGEN_HEALTH, -- Health Recovery
	[86791] = REGEN_STAMINA, -- Increase Stamina Recovery (Ice Bear Glow-Wine)
	[89957] = MAX_STAMINA_HEALTH_REGEN_STAMINA, -- Dubious Camoran Throne
	[92433] = REGEN_HEALTH_MAGICKA, -- Health & Magicka Recovery
	[92476] = REGEN_HEALTH_STAMINA, -- Health & Stamina Recovery
	[100488] = MAX_ALL, -- Spring-Loaded Infusion
	[127531] = MAX_HEALTH_MAGICKA, -- Disastrously Bloody Mara
}

local FOOD_BUFF_ABILITIES = {
	[17407] = MAX_HEALTH, -- Increase Max Health
	[17577] = MAX_MAGICKA_STAMINA, -- Increase Max Magicka & Stamina
	[17581] = MAX_ALL, -- Increase All Primary Stats
	[17608] = REGEN_MAGICKA_STAMINA, -- Magicka & Stamina Recovery
	[17614] = REGEN_ALL, -- All Primary Stat Recovery
	[61218] = MAX_ALL, -- Increase All Primary Stats
	[61255] = MAX_HEALTH_STAMINA, -- Increase Max Health & Stamina
	[61257] = MAX_HEALTH_MAGICKA, -- Increase Max Health & Magicka
	[61259] = MAX_HEALTH, -- Increase Max Health
	[61260] = MAX_MAGICKA, -- Increase Max Magicka
	[61261] = MAX_STAMINA, -- Increase Max Stamina
	[61294] = MAX_MAGICKA_STAMINA, -- Increase Max Magicka & Stamina
	[66128] = MAX_MAGICKA, -- Increase Max Magicka
	[66130] = MAX_STAMINA, -- Increase Max Stamina
	[66551] = MAX_HEALTH, -- Garlic and Pepper Venison Steak
	[66568] = MAX_MAGICKA, -- Increase Max Magicka
	[66576] = MAX_STAMINA, -- Increase Max Stamina
	[68411] = MAX_ALL, -- Crown store
	[72819] = MAX_HEALTH_REGEN_STAMINA, -- Tripe Trifle Pocket
	[72822] = MAX_HEALTH_REGEN_HEALTH, -- Blood Price Pie
	[72824] = MAX_HEALTH_REGEN_ALL, -- Smoked Bear Haunch
	[72956] = MAX_HEALTH_STAMINA, -- Max Health and Stamina (Cyrodilic Field Tack)
	[72959] = MAX_HEALTH_MAGICKA, -- Max Health and Magicka (Cyrodilic Field Treat)
	[72961] = MAX_MAGICKA_STAMINA, -- Max Stamina and Magicka (Cyrodilic Field Bar)
	[84678] = MAX_MAGICKA, -- Increase Max Magicka
	[84681] = MAX_MAGICKA_STAMINA, -- Pumpkin Snack Skewer
	[84709] = MAX_MAGICKA_REGEN_STAMINA, -- Crunchy Spider Skewer
	[84725] = MAX_MAGICKA_REGEN_HEALTH, -- The Brains!
	[84736] = MAX_HEALTH, -- Increase Max Health
	[85484] = MAX_ALL, -- Increase All Primary Stats
	[86749] = MAX_MAGICKA_STAMINA, -- Mud Ball
	[86787] = MAX_STAMINA, -- Rajhin's Sugar Claws
	[86789] = MAX_HEALTH, -- Alcaire Festival Sword-Pie
	[89955] = MAX_STAMINA_REGEN_MAGICKA, -- Candied Jester's Coins
	[89971] = MAX_HEALTH_REGEN_MAGICKA_STAMINA, -- Jewels of Misrule
	[92435] = MAX_HEALTH_MAGICKA, -- Increase Health & Magicka
	[92437] = MAX_MAGICKA, -- Increase Health (but descriptions says max magicka)
	[92474] = MAX_HEALTH_STAMINA, -- Increase Health & Stamina
	[92477] = MAX_MAGICKA, -- Increase Health (but descriptions says max magicka)
	[100498] = MAX_HEALTH_MAGICKA_REGEN_HEALTH_MAGICKA, -- Clockwork Citrus Filet
	[100502] = REGEN_HEALTH_MAGICKA, -- Deregulated Mushroom Stew
	[107748] = MAX_HEALTH_MAGICKA_FISH, -- Lure Allure
	[107789] = MAX_HEALTH_STAMINA_REGEN_HEALTH_STAMINA, -- Artaeum Takeaway Broth
	[127537] = MAX_MAGICKA, -- Increase Health (but descriptions says max magicka)
	[127572] = MAX_HEALTH_STAMINA_WEREWOLF, -- Pack Leader's Bone Broth
	[127578] = MAX_MAGICKA, -- Increase Health (but descriptions says max magicka)
	[127596] = MAX_ALL_REGEN_HEALTH, -- Bewitched Sugar Skulls
	[127619] = MAX_MAGICKA, -- Increase Health (but descriptions says max magicka)
	[127736] = MAX_MAGICKA, -- Increase Health (but descriptions says max magicka)
}

local function GetBuffTypeInfos(abilityId)
-- Returns 2: number buffTypeFoodDrink, bool isDrink
	local isDrinkBuff = DRINK_BUFF_ABILITIES[abilityId]
	return (isDrinkBuff or FOOD_BUFF_ABILITIES[abilityId] or NONE), (isDrinkBuff ~= nil and true or false)
end


---------------
-- COLLECTOR --
---------------
local ARGUMENT_ALL = 1
local ARGUMENT_NEW = 2

local MAX_ABILITY_ID = 2000000
local MAX_ABILITY_DURATION = 2000000

local BLACKLIST_STRING_PATTERN =
{
	[LANGUAGE_ENGLISH] = { "Soul Summons", "Experience", "EXP Buff", "Pelinal", "MillionHealth" },
	[LANGUAGE_GERMAN] = { "Seelenbeschwörung", "Erfahrungs", "Pelinal", "MillionHealth" },
	[LANGUAGE_FRENCH] = { "Invocation d'âme", "Expérience", "Bonus EXP", "Pélinal", "MillionHealth"},
}

ESO_Dialogs["LIB_FOOD_DRINK_BUFF_FOUND_DATA"] = 
{
	title =
	{
		text = SI_LIB_FOOD_DRINK_BUFF_DIALOG_TITLE,
	},
	mainText = 
	{
		-- text = SI_LIB_FOOD_DRINK_BUFF_DIALOG_MAINTEXT,
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

function collector:Initialize(async, clientLang)
	self.sv = ZO_SavedVars:NewAccountWide("LibFoodDrinkBuff_Save", 1, nil, {}, "Default")
	self.sv.foodDrinkBuffList = { }

	self.clientLang = clientLang
	self.TaskScan = async:Create("FoodDrinkBuffCheck")

	self:InitializeSlashCommands()
end

function collector:DoesStringContainsBlacklistPattern(abilityName)
	for index, pattern in ipairs(BLACKLIST_STRING_PATTERN[self.clientLang]) do
		local patternFound = abilityName:lower():find(pattern:lower())
		if patternFound then
			return true
		end
	end
	return false
end

function collector:NotificationAfterCreatingFoodDrinkTable()
	local countEntries = #self.sv.foodDrinkBuffList
	if countEntries > 0 then
		ZO_Dialogs_ShowDialog("LIB_FOOD_DRINK_BUFF_FOUND_DATA", { countEntries = countEntries })
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
					if cost == 0 and mechanic == 0 then
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

function collector:InitializeSlashCommands()
	SLASH_COMMANDS["/dumpfdb"] = function(saveType)
		saveType = saveType == "new" and ARGUMENT_NEW or saveType == "all" and ARGUMENT_ALL
		if saveType then
			lib.chat:Print(GetString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_START))

			ZO_ClearNumericallyIndexedTable(self.sv.foodDrinkBuffList)

			self.TaskScan:For(1, MAX_ABILITY_ID):Do(function(abilityId)
				if DoesAbilityExist(abilityId) then
					self:AddToFoodDrinkTable(abilityId, saveType)
				end
			end):Then(function()
				self:NotificationAfterCreatingFoodDrinkTable()
			end)

		else
			lib.chat:Print(ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING, GetString(SI_ERROR_INVALID_COMMAND)))
		end
	end
end


---------------------
-- FOOD AND DRINKS --
---------------------
function lib:Initialize()
	self.version = self:GetAddonVersionFromManifest()
	self.eventList = { }

	-- the collector is only active, if you have LibAsync and if it's a supported client language
	local clientLang = GetCVar("language.2")
	self.async = LibAsync
	if self.async and IsSupportedLanguage(clientLang) then
		collector:Initialize(self.async, clientLang)
	end
end

-- Reads the addon version from the addon's txt manifest file tag ##AddOnVersion
function lib:GetAddonVersionFromManifest(addOnNameString)
-- Returns 1: number nilable:addOnVersion
	addOnNameString = addOnNameString or LIB_IDENTIFIER
	if addOnNameString then
		local ADDON_MANAGER = GetAddOnManager()
		local numAddOns = ADDON_MANAGER:GetNumAddOns()
		for i = 1, numAddOns do
			if ADDON_MANAGER:GetAddOnInfo(i) == addOnNameString then
				return ADDON_MANAGER:GetAddOnVersion(i)
			end
		end
	end
	return nil
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
function lib:GetTimeLeftInSeconds(timeInMilliseconds)
-- Returns 1: number seconds
	return math.max(zo_roundToNearest(timeInMilliseconds-(GetGameTimeMilliseconds()/1000), 1), 0)
end

function lib:GetFoodBuffInfos(unitTag)
-- Returns 8: number buffTypeFoodDrink, bool isDrink, number abilityId, string buffName, number timeStarted, number timeEnds, string iconTexture, number timeLeftInSeconds
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
	return NONE, nil, nil, nil, nil, nil, nil, nil
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
-- Returns 3: bool isBuffActive, number timeLeftInSeconds, number abilityId
	local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		local timeEnding, abilityId, buffTypeFoodDrink
		for i = 1, numBuffs do
			_, _, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
			buffTypeFoodDrink = GetBuffTypeInfos(abilityId)
			if buffTypeFoodDrink ~= NONE then
				return true, self:GetTimeLeftInSeconds(timeEnding), abilityId
			end
		end
	end
	return false, 0, nil
end

function lib:IsAbilityADrinkBuff(abilityId)
-- Returns 1: nilable:bool isAbilityADrinkBuff(true) or isAbilityAFoodBuff(false), or nil if not a food or drink buff
	local buffTypeFoodDrink, isDrink = GetBuffTypeInfos(abilityId)
	if buffTypeFoodDrink ~= NONE then
		return isDrink
	end
	return nil
end

-- Filter the event EVENT_EFFECT_CHANGED to the local player and only the abilityIds of the food/drink buffs
-- Possible additional filterTypes are: REGISTER_FILTER_UNIT_TAG, REGISTER_FILTER_UNIT_TAG_PREFIX
--> Performance gain as you check if a food/drink buff got active (gained, refreshed), or was removed (faded, refreshed)
function lib:RegisterAbilityIdsFilterOnEventEffectChanged(addonEventNameSpace, callbackFunc, filterType, filterParameter)
-- Returns 16: changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType
	if type(addonEventNameSpace) == "string" and addonEventNameSpace ~= "" and type(callbackFunc) == "function" then
		local isElement = ZO_IsElementInNumericallyIndexedTable(self.eventList, addonEventNameSpace)
		if not isElement then
			EVENT_MANAGER:RegisterForEvent(addonEventNameSpace, EVENT_EFFECT_CHANGED, function(_, ...)
				local abilityId = select(15, ...)
				if FOOD_BUFF_ABILITIES[abilityId] or DRINK_BUFF_ABILITIES[abilityId] then
					callbackFunc(...)
				end
			end)
			if filterType and filterParameter then
				EVENT_MANAGER:AddFilterForEvent(addonEventNameSpace, EVENT_EFFECT_CHANGED, filterType, filterParameter)
			end
			table.insert(self.eventList, addonEventNameSpace)
			return true
		end
	end
	return nil
end

-- Unregister the register function above
function lib:UnRegisterAbilityIdsFilterOnEventEffectChanged(addonEventNameSpace)
	local data = ZO_IndexOfElementInNumericallyIndexedTable(self.eventList, addonEventNameSpace)
	if data then
		EVENT_MANAGER:UnregisterForEvent(addonEventNameSpace, EVENT_EFFECT_CHANGED)
		table.remove(self.eventList, data)
		return true
	end
	return nil
end

local function OnAddOnLoaded(_, addOnName)
	if addOnName == LIB_IDENTIFIER then
		EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_ADD_ON_LOADED)
		lib:Initialize()
	end
end
EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_ADD_ON_LOADED, OnAddOnLoaded)


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
