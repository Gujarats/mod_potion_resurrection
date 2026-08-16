if (!("PotionResurrection" in getroottable()))
{
	::PotionResurrection <- {}
}

// coming from ModSettings parameters:
// _setting: the setting object to register
::PotionResurrection.configureDebugLogging <- function(_settings = null)
{
	if(_settings == null)
	{
		return;
	}

	local debugLogging = _settings.addBooleanSetting("DebugLogging", false, "Debug Logging", "Write Potion of Resurrection debug lines to log.html.");
	// enable or disable at runtime based on the setting value
	debugLogging.addCallback(function( _enabled = false )
    {
        ::PotionResurrection.Mod.Debug.setFlag("default", _enabled);
    });

	// set the initial state based on the current setting value
	// enabled at startup if the setting is true, disabled if false
	if (::PotionResurrection.Mod.ModSettings.getSetting("DebugLogging").getValue())
	{
		::PotionResurrection.Mod.Debug.enable();
	}
	else
	{
		::PotionResurrection.Mod.Debug.disable();
	}
}

::PotionResurrection.registerSettings <- function()
{
	local general = ::PotionResurrection.Mod.ModSettings.addPage("General");
	local normal = ::PotionResurrection.Mod.ModSettings.addPage("Normal");
	local medium = ::PotionResurrection.Mod.ModSettings.addPage("Medium");
	local high = ::PotionResurrection.Mod.ModSettings.addPage("High");

	// debug settings
	::PotionResurrection.configureDebugLogging(general);

	general.addRangeSetting("PriceScalingPct", 0, 0, 100, 1, "Price Scaling per Level (%)", "Applied for each averaged boundary level of the active roster.");
    general.addBooleanSetting("AddPotionsToAllMarketplaces", true, "Add Potions to All Marketplaces", "When enabled, add resurrection potions to northern and southern marketplace inventories using the configured tier chances and stock values.");
    general.addBooleanSetting("RestrictHighToLargeSettlements", true, "Restrict High Potions", "Only allow High potions in settlements of size 3 or larger.");

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