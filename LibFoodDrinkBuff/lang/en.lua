local strings = {
	SI_LIB_FOOD_DRINK_BUFF_EXCEL = "[<<1>>] = true, -- <<2>>",
	SI_LIB_FOOD_DRINK_BUFF_RELOAD = "The user interface will be reloaded in |cFF00005 seconds|r!",
	SI_LIB_FOOD_DRINK_BUFF_EXPORT_START = "Searching food / drinks has begun. This may take several seconds...",
	SI_LIB_FOOD_DRINK_BUFF_EXPORT_FINISH = "The search is over. <<C:1[No/$d/$d]>> food / drinks were exported.",
	SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING = "<<1>>!\nArgument for |cFFFFFF/dumpfdb|r is missing!\nuse |cFFFFFFall|r - dumps the full list\nor |cFFFFFFnew|r - only dump new foods / drinks",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end