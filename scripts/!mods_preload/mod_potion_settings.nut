if (!("PotionResurrection" in getroottable()))
{
	::PotionResurrection <- {}
}

::PotionResurrection.configureDebugLogging <- function()
{
	if ("GuzBluezDebugLogController" in getroottable()
		&& "registerTarget" in ::GuzBluezDebugLogController)
	{
		::GuzBluezDebugLogController.registerTarget(::PotionResurrection.ID, ::PotionResurrection.Mod);
		return;
	}

	::PotionResurrection.Mod.Debug.setFlag("default", ::PotionResurrection.Mod.ModSettings.getSetting("DebugLogging").getValue());
}

::PotionResurrection.registerSettings <- function()
{
	local general = ::PotionResurrection.Mod.ModSettings.addPage("General");
	local normal = ::PotionResurrection.Mod.ModSettings.addPage("Normal");
	local medium = ::PotionResurrection.Mod.ModSettings.addPage("Rare");
	local high = ::PotionResurrection.Mod.ModSettings.addPage("Legendary");

	local debugLogging = general.addBooleanSetting("DebugLogging", false, "Debug Logging", "Write Potion of Resurrection debug lines to log.html.");
	debugLogging.addCallback(function()
	{
		::PotionResurrection.configureDebugLogging();
	});

	general.addRangeSetting("PriceScalingPct", 0, 0, 100, 1, "Price Scaling per Level (%)", "Applied for each averaged boundary level of the active roster.");
    general.addBooleanSetting("AddPotionsToAllMarketplaces", true, "Add Potions to All Marketplaces", "When enabled, add resurrection potions to northern and southern marketplace inventories using the configured tier chances and stock values.");
    general.addBooleanSetting("RestrictHighToLargeSettlements", true, "Restrict Legendary Potions", "Only allow Legendary potions in settlements of size 3 or larger.");

    normal.addRangeSetting("NormalHealthPct", 50, 1, 100, 1, "Health Restored (%)", "Maximum hitpoints restored when resurrection triggers.");
    normal.addRangeSetting("NormalArmorPct", 25, 0, 100, 1, "Armor Restored (%)", "Maximum head and body armor condition restored.");
    normal.addRangeSetting("NormalBasePrice", 200, 0, 50000, 50, "Base Price", "Price before party-level and vanilla shop modifiers.");
    normal.addRangeSetting("NormalSpawnChance", 100, 0, 100, 1, "Spawn Chance (%)", "Chance to add this tier during an alchemist refresh.");
    normal.addRangeSetting("NormalStock", 2, 0, 10, 1, "Stock", "Copies added after a successful availability roll.");

    medium.addRangeSetting("MediumHealthPct", 80, 1, 100, 1, "Health Restored (%)", "Maximum hitpoints restored when resurrection triggers.");
    medium.addRangeSetting("MediumArmorPct", 50, 0, 100, 1, "Armor Restored (%)", "Maximum head and body armor condition restored.");
    medium.addRangeSetting("MediumBasePrice", 600, 0, 50000, 50, "Base Price", "Price before party-level and vanilla shop modifiers.");
    medium.addRangeSetting("MediumSpawnChance", 20, 0, 100, 1, "Spawn Chance (%)", "Chance to add this tier during an alchemist refresh.");
    medium.addRangeSetting("MediumStock", 1, 0, 10, 1, "Stock", "Copies added after a successful availability roll.");

    high.addRangeSetting("HighHealthPct", 100, 1, 100, 1, "Health Restored (%)", "Maximum hitpoints restored when resurrection triggers.");
    high.addRangeSetting("HighArmorPct", 100, 0, 100, 1, "Armor Restored (%)", "Maximum head and body armor condition restored.");
    high.addRangeSetting("HighBasePrice", 1800, 0, 50000, 50, "Base Price", "Price before party-level and vanilla shop modifiers.");
    high.addRangeSetting("HighSpawnChance", 5, 0, 100, 1, "Spawn Chance (%)", "Chance to add this tier during an alchemist refresh.");
    high.addRangeSetting("HighStock", 1, 0, 10, 1, "Stock", "Copies added after a successful availability roll.");

}
