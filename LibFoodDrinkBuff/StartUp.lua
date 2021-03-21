local lib =
{
	data = { },
	collector = { },
	chat = { },
	eventList = { },
	version = 0,
	savedVarsName = "LibFoodDrinkBuff_Save",
	async = LibAsync, -- can be nil
}

-- Chat
if LibChatMessage then
	lib.chat = LibChatMessage(LFDB_LIB_IDENTIFIER, LFDB_LIB_IDENTIFIER_SHORT)
end
if not lib.chat.Print then
	function lib.chat:Print(message)
		CHAT_ROUTER:AddDebugMessage(ZO_CachedStrFormat(SI_CONVERSATION_OPTION_SPEECHCRAFT_FORMAT, LFDB_LIB_IDENTIFIER, message))
	end
end

-- Version
local function GetAddonVersion()
	-- Reads the addon version from the addon's txt manifest file tag ##AddOnVersion
	local AddOnManager = GetAddOnManager()
	local numAddOns = AddOnManager:GetNumAddOns()
	for i = 1, numAddOns do
		if AddOnManager:GetAddOnInfo(i) == LFDB_LIB_IDENTIFIER then
			return AddOnManager:GetAddOnVersion(i)
		end
	end
end
lib.version = GetAddonVersion()

-- Supported Languages
lib.LANGUAGES_SUPPORTED =
{
	[LFDB_LANGUAGE_ENGLISH] = true,
	[LFDB_LANGUAGE_GERMAN] = true,
	[LFDB_LANGUAGE_FRENCH] = true,
}
local language = GetCVar("language.2")
lib.clientLanguage = lib.LANGUAGES_SUPPORTED[language] and language or LFDB_LANGUAGE_ENGLISH

-- Global pointers
LIB_FOOD_DRINK_BUFF = lib
LibFoodDrinkBuff = lib
