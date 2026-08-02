if (!("Compatibility" in ::PotionResurrection))
{
    ::PotionResurrection.Compatibility <- {};
}

::PotionResurrection.Compatibility.Legends <- {
    function registerHooks( _mod )
    {
        _mod.hook("scripts/entity/world/settlements/buildings/building", function(q)
        {
            q.fillStash = @(__original) function( _list, _stash, _priceMult, _allowDamagedEquipment = false )
            {
                local result = __original(_list, _stash, _priceMult, _allowDamagedEquipment);
                local buildingID = this.getID();

                if (buildingID == "building.marketplace")
                {
                    ::PotionResurrection.addMarketStock(this, _stash, false);
                    ::PotionResurrection.debugLog("[Legends] added resurrection potion stock to marketplace");
                }
                else if (buildingID == "building.alchemist")
                {
                    ::PotionResurrection.addMarketStock(this, _stash, true);
                    ::PotionResurrection.debugLog("[Legends] added resurrection potion stock to alchemist");
                }

                return result;
            };
        });
    }
};
