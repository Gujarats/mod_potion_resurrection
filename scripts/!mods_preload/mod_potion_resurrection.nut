::PotionResurrection <- {
    ID = "mod_potion_resurrection",
    Version = "1.0.3",
    Name = "Potion of Resurrection",
    Tiers = {
        normal = {
            Name = "Normal",
            HealthSetting = "NormalHealthPct",
            ArmorSetting = "NormalArmorPct",
            BasePriceSetting = "NormalBasePrice",
            SpawnChanceSetting = "NormalSpawnChance",
            StockSetting = "NormalStock"
        },
        medium = {
            Name = "Medium",
            HealthSetting = "MediumHealthPct",
            ArmorSetting = "MediumArmorPct",
            BasePriceSetting = "MediumBasePrice",
            SpawnChanceSetting = "MediumSpawnChance",
            StockSetting = "MediumStock"
        },
        high = {
            Name = "High",
            HealthSetting = "HighHealthPct",
            ArmorSetting = "HighArmorPct",
            BasePriceSetting = "HighBasePrice",
            SpawnChanceSetting = "HighSpawnChance",
            StockSetting = "HighStock"
        }
    }
};

::PotionResurrection.HooksMod <- ::Hooks.register(
    ::PotionResurrection.ID,
    ::PotionResurrection.Version,
    ::PotionResurrection.Name
);
::PotionResurrection.HooksMod.require("mod_msu >= 1.9.0");

::PotionResurrection.HooksMod.queue(">mod_msu", function()
{
    ::PotionResurrection.Mod <- ::MSU.Class.Mod(
        ::PotionResurrection.ID,
        ::PotionResurrection.Version,
        ::PotionResurrection.Name
    );

    ::PotionResurrection.conf <- function(_key)
    {
        return ::PotionResurrection.Mod.ModSettings.getSetting(_key).getValue();
    };

    local general = ::PotionResurrection.Mod.ModSettings.addPage("General");
    local debugLogSetting = general.addBooleanSetting("EnableDebugLogging", true, "Enable Debug Logging", "Write potion consumption, battle activation, death interception, eligibility, and restoration details to the Battle Brothers log.");
    debugLogSetting.addCallback(function(_data = null)
    {
        ::PotionResurrection.Mod.Debug.setFlag("default", this.getValue());
    });
    ::PotionResurrection.Mod.Debug.setFlag("default", debugLogSetting.getValue());
    general.addRangeSetting("PriceScalingPct", 5, 0, 100, 1, "Price Scaling per Level (%)", "Applied for each averaged boundary level of the active roster.");
    general.addBooleanSetting("RestrictHighToLargeSettlements", true, "Restrict High Potions", "Only allow High potions in settlements of size 3 or larger.");

    local normal = ::PotionResurrection.Mod.ModSettings.addPage("Normal");
    normal.addRangeSetting("NormalHealthPct", 50, 1, 100, 1, "Health Restored (%)", "Maximum hitpoints restored when resurrection triggers.");
    normal.addRangeSetting("NormalArmorPct", 25, 0, 100, 1, "Armor Restored (%)", "Maximum head and body armor condition restored.");
    normal.addRangeSetting("NormalBasePrice", 750, 0, 50000, 50, "Base Price", "Price before party-level and vanilla shop modifiers.");
    normal.addRangeSetting("NormalSpawnChance", 100, 0, 100, 1, "Spawn Chance (%)", "Chance to add this tier during an alchemist refresh.");
    normal.addRangeSetting("NormalStock", 2, 0, 10, 1, "Stock", "Copies added after a successful availability roll.");

    local medium = ::PotionResurrection.Mod.ModSettings.addPage("Medium");
    medium.addRangeSetting("MediumHealthPct", 80, 1, 100, 1, "Health Restored (%)", "Maximum hitpoints restored when resurrection triggers.");
    medium.addRangeSetting("MediumArmorPct", 50, 0, 100, 1, "Armor Restored (%)", "Maximum head and body armor condition restored.");
    medium.addRangeSetting("MediumBasePrice", 750, 0, 50000, 50, "Base Price", "Price before party-level and vanilla shop modifiers.");
    medium.addRangeSetting("MediumSpawnChance", 20, 0, 100, 1, "Spawn Chance (%)", "Chance to add this tier during an alchemist refresh.");
    medium.addRangeSetting("MediumStock", 1, 0, 10, 1, "Stock", "Copies added after a successful availability roll.");

    local high = ::PotionResurrection.Mod.ModSettings.addPage("High");
    high.addRangeSetting("HighHealthPct", 100, 1, 100, 1, "Health Restored (%)", "Maximum hitpoints restored when resurrection triggers.");
    high.addRangeSetting("HighArmorPct", 100, 0, 100, 1, "Armor Restored (%)", "Maximum head and body armor condition restored.");
    high.addRangeSetting("HighBasePrice", 750, 0, 50000, 50, "Base Price", "Price before party-level and vanilla shop modifiers.");
    high.addRangeSetting("HighSpawnChance", 5, 0, 100, 1, "Spawn Chance (%)", "Chance to add this tier during an alchemist refresh.");
    high.addRangeSetting("HighStock", 1, 0, 10, 1, "Stock", "Copies added after a successful availability roll.");

    ::include("scripts/mods/potion_resurrection_service");
    ::include("scripts/mods/potion_resurrection_market");
    ::PotionResurrection.debugLog("Mod initialized; player.kill hook and market hook registered");
});
