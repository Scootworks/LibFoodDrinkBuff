--Library constants are missing?
assert(not LIB_FOOD_DRINK_BUFF, GetString(SI_LIB_FOOD_DRINK_BUFF_LIBRARY_CONSTANTS_MISSING))

--Local variable for global LIB_FOOD_DRINK_BUFF
local lib = LIB_FOOD_DRINK_BUFF

--------------------
-- DRINKS'n'FOODS --
--------------------
--The drink buff abilityIds and their LibFoodDrinkBuff_buffTypeConstant
local DRINK_BUFF_ABILITIES = {
	[61322] = LFDB_BUFF_TYPE_REGEN_HEALTH, -- Health Recovery
	[61325] = LFDB_BUFF_TYPE_REGEN_MAGICKA, -- Magicka Recovery
	[61328] = LFDB_BUFF_TYPE_REGEN_STAMINA, -- Health & Magicka Recovery
	[61335] = LFDB_BUFF_TYPE_REGEN_HEALTH_MAGICKA, -- Health & Magicka Recovery
	[61340] = LFDB_BUFF_TYPE_REGEN_HEALTH_STAMINA, -- Health & Stamina Recovery
	[61345] = LFDB_BUFF_TYPE_REGEN_MAGICKA_STAMINA, -- Magicka & Stamina Recovery
	[61350] = LFDB_BUFF_TYPE_REGEN_ALL, -- All Primary Stat Recovery
	[66125] = LFDB_BUFF_TYPE_MAX_HEALTH, -- Increase Max Health
	[66132] = LFDB_BUFF_TYPE_REGEN_HEALTH, -- Health Recovery (Alcoholic Drinks)
	[66137] = LFDB_BUFF_TYPE_REGEN_MAGICKA, -- Magicka Recovery (Tea)
	[66141] = LFDB_BUFF_TYPE_REGEN_STAMINA, -- Stamina Recovery (Tonics)
	[66586] = LFDB_BUFF_TYPE_REGEN_HEALTH, -- Health Recovery
	[66590] = LFDB_BUFF_TYPE_REGEN_MAGICKA, -- Magicka Recovery
	[66594] = LFDB_BUFF_TYPE_REGEN_STAMINA, -- Stamina Recovery
	[68416] = LFDB_BUFF_TYPE_REGEN_ALL, -- All Primary Stat Recovery (Crown Refreshing Drink)
	[72816] = LFDB_BUFF_TYPE_REGEN_HEALTH_MAGICKA, -- Red Frothgar
	[72965] = LFDB_BUFF_TYPE_REGEN_HEALTH_STAMINA, -- Health and Stamina Recovery (Cyrodilic Field Brew)
	[72968] = LFDB_BUFF_TYPE_REGEN_HEALTH_MAGICKA, -- Health and Magicka Recovery (Cyrodilic Field Tea)
	[72971] = LFDB_BUFF_TYPE_REGEN_MAGICKA_STAMINA, -- Magicka and Stamina Recovery (Cyrodilic Field Tonic)
	[84700] = LFDB_BUFF_TYPE_REGEN_HEALTH_MAGICKA, -- 2h Witches event: Eyeballs
	[84704] = LFDB_BUFF_TYPE_REGEN_ALL, -- 2h Witches event: Witchmother's Party Punch
	[84720] = LFDB_BUFF_TYPE_MAX_MAGICKA_REGEN_MAGICKA, -- 2h Witches event: Eye Scream
	[84731] = LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA_REGEN_MAGICKA, -- 2h Witches event: Witchmother's Potent Brew
	[84732] = LFDB_BUFF_TYPE_REGEN_HEALTH, -- Increase Health Regen
	[84733] = LFDB_BUFF_TYPE_REGEN_HEALTH, -- Increase Health Regen
	[84735] = LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA_SPECIAL_VAMPIRE, -- 2h Witches event: Double Bloody Mara
	[85497] = LFDB_BUFF_TYPE_REGEN_ALL, -- All Primary Stat Recovery
	[86559] = LFDB_BUFF_TYPE_REGEN_MAGICKA_STAMINA_FISH, -- Hissmir Fish Eye Rye
	[86560] = LFDB_BUFF_TYPE_REGEN_STAMINA, -- Stamina Recovery
	[86673] = LFDB_BUFF_TYPE_MAX_STAMINA_REGEN_STAMINA, -- Lava Foot Soup & Saltrice
	[86674] = LFDB_BUFF_TYPE_REGEN_STAMINA, -- Stamina Recovery
	[86677] = LFDB_BUFF_TYPE_MAX_STAMINA_REGEN_HEALTH, -- Warning Fire (Bergama Warning Fire)
	[86678] = LFDB_BUFF_TYPE_REGEN_HEALTH, -- Health Recovery
	[86746] = LFDB_BUFF_TYPE_REGEN_HEALTH_MAGICKA, -- Betnikh Spiked Ale (Betnikh Twice-Spiked Ale)
	[86747] = LFDB_BUFF_TYPE_REGEN_HEALTH, -- Health Recovery
	[86791] = LFDB_BUFF_TYPE_REGEN_STAMINA, -- Increase Stamina Recovery (Ice Bear Glow-Wine)
	[89957] = LFDB_BUFF_TYPE_MAX_STAMINA_HEALTH_REGEN_STAMINA, -- Dubious Camoran Throne
	[92433] = LFDB_BUFF_TYPE_REGEN_HEALTH_MAGICKA, -- Health & Magicka Recovery
	[92476] = LFDB_BUFF_TYPE_REGEN_HEALTH_STAMINA, -- Health & Stamina Recovery
	[100488] = LFDB_BUFF_TYPE_MAX_ALL, -- Spring-Loaded Infusion
	[127531] = LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA, -- Disastrously Bloody Mara
	[127572] = LFDB_BUFF_TYPE_MAX_HEALTH_STAMINA_WEREWOLF, -- Pack Leader's Bone Broth
}
lib.DRINK_BUFF_ABILITIES = DRINK_BUFF_ABILITIES

--The food buff abilityIds and their LibFoodDrinkBuff_buffTypeConstant
local FOOD_BUFF_ABILITIES = {
	[17407] = LFDB_BUFF_TYPE_MAX_HEALTH, -- Increase Max Health
	[17577] = LFDB_BUFF_TYPE_MAX_MAGICKA_STAMINA, -- Increase Max Magicka & Stamina
	[17581] = LFDB_BUFF_TYPE_MAX_ALL, -- Increase All Primary Stats
	[17608] = LFDB_BUFF_TYPE_REGEN_MAGICKA_STAMINA, -- Magicka & Stamina Recovery
	[17614] = LFDB_BUFF_TYPE_REGEN_ALL, -- All Primary Stat Recovery
	[61218] = LFDB_BUFF_TYPE_MAX_ALL, -- Increase All Primary Stats
	[61255] = LFDB_BUFF_TYPE_MAX_HEALTH_STAMINA, -- Increase Max Health & Stamina
	[61257] = LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA, -- Increase Max Health & Magicka
	[61259] = LFDB_BUFF_TYPE_MAX_HEALTH, -- Increase Max Health
	[61260] = LFDB_BUFF_TYPE_MAX_MAGICKA, -- Increase Max Magicka
	[61261] = LFDB_BUFF_TYPE_MAX_STAMINA, -- Increase Max Stamina
	[61294] = LFDB_BUFF_TYPE_MAX_MAGICKA_STAMINA, -- Increase Max Magicka & Stamina
	[66128] = LFDB_BUFF_TYPE_MAX_MAGICKA, -- Increase Max Magicka
	[66130] = LFDB_BUFF_TYPE_MAX_STAMINA, -- Increase Max Stamina
	[66551] = LFDB_BUFF_TYPE_MAX_HEALTH, -- Garlic and Pepper Venison Steak
	[66568] = LFDB_BUFF_TYPE_MAX_MAGICKA, -- Increase Max Magicka
	[66576] = LFDB_BUFF_TYPE_MAX_STAMINA, -- Increase Max Stamina
	[68411] = LFDB_BUFF_TYPE_MAX_ALL, -- Crown store
	[72819] = LFDB_BUFF_TYPE_MAX_HEALTH_REGEN_STAMINA, -- Tripe Trifle Pocket
	[72822] = LFDB_BUFF_TYPE_MAX_HEALTH_REGEN_HEALTH, -- Blood Price Pie
	[72824] = LFDB_BUFF_TYPE_MAX_HEALTH_REGEN_ALL, -- Smoked Bear Haunch
	[72956] = LFDB_BUFF_TYPE_MAX_HEALTH_STAMINA, -- Max Health and Stamina (Cyrodilic Field Tack)
	[72959] = LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA, -- Max Health and Magicka (Cyrodilic Field Treat)
	[72961] = LFDB_BUFF_TYPE_MAX_MAGICKA_STAMINA, -- Max Stamina and Magicka (Cyrodilic Field Bar)
	[84678] = LFDB_BUFF_TYPE_MAX_MAGICKA, -- Increase Max Magicka
	[84681] = LFDB_BUFF_TYPE_MAX_MAGICKA_STAMINA, -- Pumpkin Snack Skewer
	[84709] = LFDB_BUFF_TYPE_MAX_MAGICKA_REGEN_STAMINA, -- Crunchy Spider Skewer
	[84725] = LFDB_BUFF_TYPE_MAX_MAGICKA_REGEN_HEALTH, -- The Brains!
	[84736] = LFDB_BUFF_TYPE_MAX_HEALTH, -- Increase Max Health
	[85484] = LFDB_BUFF_TYPE_MAX_ALL, -- Increase All Primary Stats
	[86749] = LFDB_BUFF_TYPE_MAX_MAGICKA_STAMINA, -- Mud Ball
	[86787] = LFDB_BUFF_TYPE_MAX_STAMINA, -- Rajhin's Sugar Claws
	[86789] = LFDB_BUFF_TYPE_MAX_HEALTH, -- Alcaire Festival Sword-Pie
	[89955] = LFDB_BUFF_TYPE_MAX_STAMINA_REGEN_MAGICKA, -- Candied Jester's Coins
	[89971] = LFDB_BUFF_TYPE_MAX_HEALTH_REGEN_MAGICKA_STAMINA, -- Jewels of Misrule
	[92435] = LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA, -- Increase Health & Magicka
	[92437] = LFDB_BUFF_TYPE_MAX_MAGICKA, -- Increase Health (but descriptions says max magicka)
	[92474] = LFDB_BUFF_TYPE_MAX_HEALTH_STAMINA, -- Increase Health & Stamina
	[92477] = LFDB_BUFF_TYPE_MAX_MAGICKA, -- Increase Health (but descriptions says max magicka)
	[100498] = LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA_REGEN_HEALTH_MAGICKA, -- Clockwork Citrus Filet
	[100502] = LFDB_BUFF_TYPE_REGEN_HEALTH_MAGICKA, -- Deregulated Mushroom Stew
	[107748] = LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA_FISH, -- Lure Allure
	[107789] = LFDB_BUFF_TYPE_MAX_HEALTH_STAMINA_REGEN_HEALTH_STAMINA, -- Artaeum Takeaway Broth
	[127537] = LFDB_BUFF_TYPE_MAX_MAGICKA, -- Increase Health (but descriptions says max magicka)
	[127578] = LFDB_BUFF_TYPE_MAX_MAGICKA, -- Increase Health (but descriptions says max magicka)
	[127596] = LFDB_BUFF_TYPE_MAX_ALL_REGEN_HEALTH, -- Bewitched Sugar Skulls
	[127619] = LFDB_BUFF_TYPE_MAX_MAGICKA, -- Increase Health (but descriptions says max magicka)
	[127736] = LFDB_BUFF_TYPE_MAX_MAGICKA, -- Increase Health (but descriptions says max magicka)
}
lib.FOOD_BUFF_ABILITIES = FOOD_BUFF_ABILITIES