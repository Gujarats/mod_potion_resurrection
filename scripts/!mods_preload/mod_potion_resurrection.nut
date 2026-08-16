::PotionResurrection <- {
    ID = "mod_potion_resurrection",
    Version = "1.1.2",
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
::PotionResurrection.HooksMod.queue(">mod_msu", ">mod_legends", function()
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
    ::PotionResurrection.registerSettings();

    ::include("scripts/mods/potion_resurrection_service");
    ::include("scripts/mods/potion_resurrection_market");
    ::include("scripts/mods/compatibility/legends_market_patch");

    if (::Hooks.hasMod("mod_legends"))
    {
        ::PotionResurrection.Compatibility.Legends.registerHooks(::PotionResurrection.HooksMod);
    }
    else
    {
        ::PotionResurrection.registerVanillaMarketHooks();
    }
});
