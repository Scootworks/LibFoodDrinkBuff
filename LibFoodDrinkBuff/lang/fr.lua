SafeAddString(SI_LIB_FOOD_DRINK_BUFF_LIBRARY_LOADED, "La bibliothèque \'%s\' a déjà été chargée.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_LIBRARY_CONSTANTS_MISSING, "Erreur: Les constantes de la bibliothèque \'%s\' sont manquantes!", 0)

SafeAddString(SI_LIB_FOOD_DRINK_BUFF_RELOAD, "L'interface utilisateur sera rechargée dans |cFF00005 secondes|r!", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_START, "La recherche de nourriture / boisson a commencée. Cela peut prendre quelques secondes...", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_FINISH, "Le recherche est terminée. Aucune nourriture ou boisson ont été exporté.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING, "<<1>>!\nParamètre manquant pour for |cFFFFFF/dumpfdb|r!\nUtilisez |cFFFFFFall|r - exporte la liste complète ou\n|cFFFFFFnew|r - exporte seulement la nourriture / boisson", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_NO_BUFFS, "Il n'y a pas de buff actif.", 0)

SafeAddString(SI_LIB_FOOD_DRINK_BUFF_DIALOG_MAINTEXT, "<<1>> nourritures / boissons trouvé(s).\n\nVous devez recharger l'interface pour mettre à jour le fichier savedVariables.\n\nRecharger l'interface maintenant?", 0)

--Create blacklisted buff names
local blacklistedBuffNamesFR = {
    "Invocation d'âme", "Expérience", "Bonus EXP", "Pélinal", "MillionHealth", "Ambroisie"
}
for index, blacklisteBuffName in ipairs(blacklistedBuffNamesFR) do
    SafeAddString(_G["SI_LIB_FOOD_DRINK_BUFF_BLACKLISTED_BUFFNAME_" .. tostring(index)], blacklisteBuffName, 0)
end
--Add the constant for the number of blacklisted buff names
_LIB_FOOD_DRINK_BUFF = _LIB_FOOD_DRINK_BUFF or {}
_LIB_FOOD_DRINK_BUFF.numBlacklistedBuffNames = #blacklistedBuffNamesFR
