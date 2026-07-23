::PotionResurrection.isHighTierSettlement <- function( _settlement )
{
    if (_settlement == null)
    {
        return false;
    }

    if (!::PotionResurrection.conf("RestrictHighToLargeSettlements"))
    {
        return true;
    }

    return _settlement.getSize() >= 3;
};

::PotionResurrection.addTierToAlchemist <- function( _building, _stash, _tierKey, _script )
{
    local tier = ::PotionResurrection.Tiers[_tierKey];
    local chance = ::PotionResurrection.clamp(::PotionResurrection.conf(tier.SpawnChanceSetting), 0, 100);
    local stock = ::PotionResurrection.clamp(::PotionResurrection.conf(tier.StockSetting), 0, 10);

    ::PotionResurrection.debugLog("Adding " + _tierKey + " tier to alchemist: chance=" + chance + ", stock=" + stock);
    if (chance <= 0 || stock <= 0 || ::Math.rand(1, 100) > chance)
    {
        ::PotionResurrection.debugLog("Chance for" + _tierKey + " tier not added to alchemist due to chance or stock.");
        return;
    }

    for (local i = 0; i < stock; ++i)
    {
        local item = ::new("scripts/items/" + _script);
        item.setPriceMult(_building.getPriceMult());
        _stash.add(item);
    }
    ::PotionResurrection.debugLog("Successfully added " + _tierKey + " tier to alchemist.");
};

::PotionResurrection.HooksMod.hook("scripts/entity/world/settlements/buildings/alchemist_building", function(q)
{
    q.onAfterFillStash = @(__original) function( _stash )
    {
        __original(_stash);

        ::PotionResurrection.addTierToAlchemist(
            this,
            _stash,
            "normal",
            "misc/resurrection_potion_normal_item"
        );
        ::PotionResurrection.addTierToAlchemist(
            this,
            _stash,
            "medium",
            "misc/resurrection_potion_medium_item"
        );

        if (::PotionResurrection.isHighTierSettlement(this.getSettlement()))
        {
            ::PotionResurrection.addTierToAlchemist(
                this,
                _stash,
                "high",
                "misc/resurrection_potion_high_item"
            );
        }

        _stash.sort();
    }
});

::PotionResurrection.HooksMod.hook("scripts/entity/world/settlements/buildings/marketplace_building", function(q)
{
    q.onAfterFillStash = @(__original) function( _stash )
    {
        __original(_stash);

        if (!::PotionResurrection.conf("AddPotionsToAllMarketplaces"))
        {
            ::PotionResurrection.debugLog("AddPotionsToAllMarketplaces is disabled, skipping marketplace potion addition.");
            return;
        }

        ::PotionResurrection.addTierToAlchemist(
            this,
            _stash,
            "normal",
            "misc/resurrection_potion_normal_item"
        );
        ::PotionResurrection.addTierToAlchemist(
            this,
            _stash,
            "medium",
            "misc/resurrection_potion_medium_item"
        );

        if (::PotionResurrection.isHighTierSettlement(this.getSettlement()))
        {
            ::PotionResurrection.addTierToAlchemist(
                this,
                _stash,
                "high",
                "misc/resurrection_potion_high_item"
            );
        }

        _stash.sort();
    }
});
