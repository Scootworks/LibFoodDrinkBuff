--Library identifiers
LFDB_LIB_IDENTIFIER = "LibFoodDrinkBuff"
LFDB_LIB_IDENTIFIER_SHORT = "LibFDB"

local libIdentifier = LFDB_LIB_IDENTIFIER

---------------
-- LANGUAGES --
---------------
-- Assure that library was not loaded yet due to a hardcoded line of code from any other addon.
-- if the AddOnManager would load it properly via the txt file, no duplicate loads would happen!
assert(_G[libIdentifier] == nil, string.format("Library \'%s\' was already loaded! Please check your addons for an embedded version of LibFoodDrinkBuff an tell the author to properly use it via the LibFoodDrinkBuff.txt file!", libIdentifier))

---------------
-- LANGUAGES --
---------------
LFDB_LANGUAGE_GERMAN    = "de"
LFDB_LANGUAGE_ENGLISH   = "en"
LFDB_LANGUAGE_FRENCH    = "fr"

----------------------------------------------------
-- BUFF TYPES - LibFoodDrinkBuff_buffTypeConstant --
----------------------------------------------------
-- Base value constants
LFDB_BUFF_TYPE_NONE                     = 0
LFDB_BUFF_TYPE_MAX_HEALTH               = 1
LFDB_BUFF_TYPE_MAX_MAGICKA              = 2
LFDB_BUFF_TYPE_MAX_STAMINA              = 4
LFDB_BUFF_TYPE_REGEN_HEALTH             = 8
LFDB_BUFF_TYPE_REGEN_MAGICKA            = 16
LFDB_BUFF_TYPE_REGEN_STAMINA            = 32
LFDB_BUFF_TYPE_SPECIAL_VAMPIRE          = 64
LFDB_BUFF_TYPE_FIND_FISHES              = 128
LFDB_BUFF_TYPE_WEREWOLF_TRANSFORMATION  = 256

-- Calculated food/drink constants based on the base value constants above
LFDB_BUFF_TYPE_MAX_ALL                                  = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_MAX_MAGICKA + LFDB_BUFF_TYPE_MAX_STAMINA
LFDB_BUFF_TYPE_MAX_ALL_REGEN_HEALTH                     = LFDB_BUFF_TYPE_MAX_ALL + LFDB_BUFF_TYPE_REGEN_HEALTH
LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA                       = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_MAX_MAGICKA
LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA_FISH                  = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_MAX_MAGICKA + LFDB_BUFF_TYPE_FIND_FISHES
LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA_REGEN_HEALTH_MAGICKA  = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_REGEN_HEALTH + LFDB_BUFF_TYPE_MAX_MAGICKA + LFDB_BUFF_TYPE_REGEN_MAGICKA
LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA_REGEN_MAGICKA         = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_MAX_MAGICKA + LFDB_BUFF_TYPE_REGEN_MAGICKA
LFDB_BUFF_TYPE_MAX_HEALTH_MAGICKA_SPECIAL_VAMPIRE       = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_MAX_MAGICKA + LFDB_BUFF_TYPE_SPECIAL_VAMPIRE
LFDB_BUFF_TYPE_MAX_HEALTH_REGEN_ALL                     = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_REGEN_HEALTH + LFDB_BUFF_TYPE_REGEN_MAGICKA + LFDB_BUFF_TYPE_REGEN_STAMINA
LFDB_BUFF_TYPE_MAX_HEALTH_REGEN_HEALTH                  = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_REGEN_HEALTH
LFDB_BUFF_TYPE_MAX_HEALTH_REGEN_MAGICKA                 = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_REGEN_MAGICKA
LFDB_BUFF_TYPE_MAX_HEALTH_REGEN_STAMINA                 = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_REGEN_STAMINA
LFDB_BUFF_TYPE_MAX_HEALTH_REGEN_MAGICKA_STAMINA         = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_REGEN_MAGICKA + LFDB_BUFF_TYPE_REGEN_STAMINA
LFDB_BUFF_TYPE_MAX_HEALTH_STAMINA                       = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_MAX_STAMINA
LFDB_BUFF_TYPE_MAX_HEALTH_STAMINA_REGEN_HEALTH_STAMINA  = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_REGEN_HEALTH + LFDB_BUFF_TYPE_MAX_STAMINA + LFDB_BUFF_TYPE_REGEN_STAMINA
LFDB_BUFF_TYPE_MAX_HEALTH_STAMINA_WEREWOLF              = LFDB_BUFF_TYPE_MAX_HEALTH_STAMINA + LFDB_BUFF_TYPE_WEREWOLF_TRANSFORMATION
LFDB_BUFF_TYPE_MAX_MAGICKA_REGEN_HEALTH                 = LFDB_BUFF_TYPE_MAX_MAGICKA + LFDB_BUFF_TYPE_REGEN_HEALTH
LFDB_BUFF_TYPE_MAX_MAGICKA_REGEN_MAGICKA                = LFDB_BUFF_TYPE_MAX_MAGICKA + LFDB_BUFF_TYPE_REGEN_MAGICKA
LFDB_BUFF_TYPE_MAX_MAGICKA_REGEN_STAMINA                = LFDB_BUFF_TYPE_MAX_MAGICKA + LFDB_BUFF_TYPE_REGEN_STAMINA
LFDB_BUFF_TYPE_MAX_MAGICKA_STAMINA                      = LFDB_BUFF_TYPE_MAX_MAGICKA + LFDB_BUFF_TYPE_MAX_STAMINA
LFDB_BUFF_TYPE_MAX_STAMINA_HEALTH_REGEN_STAMINA         = LFDB_BUFF_TYPE_MAX_HEALTH + LFDB_BUFF_TYPE_MAX_STAMINA + LFDB_BUFF_TYPE_REGEN_STAMINA
LFDB_BUFF_TYPE_MAX_STAMINA_REGEN_HEALTH                 = LFDB_BUFF_TYPE_MAX_STAMINA + LFDB_BUFF_TYPE_REGEN_HEALTH
LFDB_BUFF_TYPE_MAX_STAMINA_REGEN_MAGICKA                = LFDB_BUFF_TYPE_MAX_STAMINA + LFDB_BUFF_TYPE_REGEN_MAGICKA
LFDB_BUFF_TYPE_MAX_STAMINA_REGEN_STAMINA                = LFDB_BUFF_TYPE_MAX_STAMINA + LFDB_BUFF_TYPE_REGEN_STAMINA
LFDB_BUFF_TYPE_REGEN_ALL                                = LFDB_BUFF_TYPE_REGEN_HEALTH + LFDB_BUFF_TYPE_REGEN_MAGICKA + LFDB_BUFF_TYPE_REGEN_STAMINA
LFDB_BUFF_TYPE_REGEN_HEALTH_MAGICKA                     = LFDB_BUFF_TYPE_REGEN_HEALTH + LFDB_BUFF_TYPE_REGEN_MAGICKA
LFDB_BUFF_TYPE_REGEN_HEALTH_STAMINA                     = LFDB_BUFF_TYPE_REGEN_HEALTH + LFDB_BUFF_TYPE_REGEN_STAMINA
LFDB_BUFF_TYPE_REGEN_MAGICKA_STAMINA                    = LFDB_BUFF_TYPE_REGEN_MAGICKA + LFDB_BUFF_TYPE_REGEN_STAMINA
LFDB_BUFF_TYPE_REGEN_MAGICKA_STAMINA_FISH               = LFDB_BUFF_TYPE_REGEN_MAGICKA + LFDB_BUFF_TYPE_REGEN_STAMINA + LFDB_BUFF_TYPE_FIND_FISHES
