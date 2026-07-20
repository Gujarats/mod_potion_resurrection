::PotionResurrection.clamp <- function( _value, _minimum, _maximum )
{
    return ::Math.max(_minimum, ::Math.min(_maximum, _value));
};

::PotionResurrection.debugLog <- function( _message )
{
    ::PotionResurrection.Mod.Debug.printLog("[PotionResurrection] " + _message);
};

::PotionResurrection.getBoundaryAverageLevel <- function()
{
    if (!("World" in getroottable()) || ::World.getPlayerRoster() == null)
    {
        return 0.0;
    }

    local minimum = null;
    local maximum = null;
    foreach (bro in ::World.getPlayerRoster().getAll())
    {
        if (bro == null || bro.isGuest())
        {
            continue;
        }

        local level = bro.getLevel();
        minimum = minimum == null ? level : ::Math.min(minimum, level);
        maximum = maximum == null ? level : ::Math.max(maximum, level);
    }

    return minimum == null ? 0.0 : (minimum + maximum) / 2.0;
};

::PotionResurrection.getScaledPrice <- function( _tier )
{
    local key = _tier in ::PotionResurrection.Tiers ? _tier : "normal";
    local tier = ::PotionResurrection.Tiers[key];
    local basePrice = ::PotionResurrection.clamp(::PotionResurrection.conf(tier.BasePriceSetting), 0, 50000);
    local scaling = ::PotionResurrection.clamp(::PotionResurrection.conf("PriceScalingPct"), 0, 100);
    return ::Math.round(basePrice * (1.0 + ::PotionResurrection.getBoundaryAverageLevel() * scaling / 100.0));
};

::PotionResurrection.canTrigger <- function( _actor, _killer, _skill, _fatalityType )
{
    if (_actor == null)
    {
        ::PotionResurrection.debugLog("Resurrection eligibility rejected: actor is null");
        return false;
    }

    if (!_actor.isPlayerControlled())
    {
        ::PotionResurrection.debugLog("Resurrection eligibility rejected for " + _actor.getName() + ": actor is not player controlled");
        return false;
    }

    if (!_actor.isAlive())
    {
        ::PotionResurrection.debugLog("Resurrection eligibility rejected for " + _actor.getName() + ": actor is already marked dead");
        return false;
    }

    if (!_actor.isPlacedOnMap())
    {
        ::PotionResurrection.debugLog("Resurrection eligibility rejected for " + _actor.getName() + ": actor is not placed on the tactical map");
        return false;
    }

    if (::Tactical.State == null)
    {
        ::PotionResurrection.debugLog("Resurrection eligibility rejected for " + _actor.getName() + ": tactical state is null");
        return false;
    }

    if (::Tactical.State.isScenarioMode())
    {
        ::PotionResurrection.debugLog("Resurrection eligibility rejected for " + _actor.getName() + ": scenario mode");
        return false;
    }

    if (::Tactical.State.isAutoRetreat())
    {
        ::PotionResurrection.debugLog("Resurrection eligibility rejected for " + _actor.getName() + ": auto retreat");
        return false;
    }

    if (_fatalityType == ::Const.FatalityType.Kraken || _fatalityType == ::Const.FatalityType.Devoured)
    {
        ::PotionResurrection.debugLog("Resurrection eligibility rejected for " + _actor.getName() + ": excluded fatality type " + _fatalityType.tostring());
        return false;
    }

    if (_killer == null && _skill == null)
    {
        ::PotionResurrection.debugLog("Resurrection eligibility rejected for " + _actor.getName() + ": killer and skill are both null (scripted/cleanup death)");
        return false;
    }

    local effect = _actor.getSkills().getSkillByID("effects.resurrection_potion");
    if (effect == null)
    {
        ::PotionResurrection.debugLog("Resurrection eligibility rejected for " + _actor.getName() + ": effect not found");
        return false;
    }

    if (effect.isTriggering())
    {
        ::PotionResurrection.debugLog("Resurrection eligibility rejected for " + _actor.getName() + ": effect is already triggering");
        return false;
    }

    ::PotionResurrection.debugLog("Resurrection eligibility accepted for " + _actor.getName() + "; fatality type=" + _fatalityType.tostring());
    return true;
};

::PotionResurrection.restoreArmorSlot <- function( _actor, _slot, _pct )
{
    local item = _actor.getItems().getItemAtSlot(_slot);
    if (item == null || item.getConditionMax() <= 0)
    {
        return;
    }

    local condition = ::Math.ceil(item.getConditionMax() * _pct / 100.0);
    item.setCondition(::PotionResurrection.clamp(condition, 0, item.getConditionMax()));
};

::PotionResurrection.restore <- function( _actor, _effect )
{
    local tierKey = _effect.getTier();
    local tier = ::PotionResurrection.Tiers[tierKey];
    _effect.setTriggering(true);
    ::PotionResurrection.debugLog("Resurrection restoration started for " + _actor.getName() + "; tier=" + tierKey);

    try
    {
        local healthPct = ::PotionResurrection.clamp(::PotionResurrection.conf(tier.HealthSetting), 1, 100);
        local armorPct = ::PotionResurrection.clamp(::PotionResurrection.conf(tier.ArmorSetting), 0, 100);
        local hitpoints = ::Math.ceil(_actor.getHitpointsMax() * healthPct / 100.0);

        _actor.m.IsAlive = true;
        _actor.m.IsDying = false;
        _actor.setHitpoints(::PotionResurrection.clamp(hitpoints, 1, _actor.getHitpointsMax()));
        ::PotionResurrection.restoreArmorSlot(_actor, ::Const.ItemSlot.Body, armorPct);
        ::PotionResurrection.restoreArmorSlot(_actor, ::Const.ItemSlot.Head, armorPct);
        _actor.getItems().updateAppearance();
        _actor.getSkills().removeByID("effects.resurrection_potion");
        _actor.getSkills().update();
        _actor.setDirty(true);

        ::Tactical.EventLog.logEx(::Const.UI.getColorizedEntityName(_actor) + " is restored by a " + tier.Name + " Potion of Resurrection!");
        ::Sound.play("sounds/combat/drink_01.wav", ::Const.Sound.Volume.Tactical, _actor.getPos());
        ::PotionResurrection.debugLog("Resurrection restoration succeeded for " + _actor.getName() + "; hitpoints=" + _actor.getHitpoints().tostring());
        return true;
    }
    catch (error)
    {
        _effect.setTriggering(false);
        ::logError("Potion of Resurrection failed for " + _actor.getName() + ": " + error);
        return false;
    }
};

::PotionResurrection.HooksMod.hook("scripts/entity/tactical/player", function(q)
{
    q.kill = @(__original) function(_killer = null, _skill = null, _fatalityType = ::Const.FatalityType.None, _silent = false)
    {
        local effect = this.getSkills().getSkillByID("effects.resurrection_potion");
        ::PotionResurrection.debugLog("player.kill intercepted for " + this.getName() + "; effectPresent=" + (effect != null).tostring() + "; fatalityType=" + _fatalityType.tostring());
        if (effect != null
            && ::PotionResurrection.canTrigger(this, _killer, _skill, _fatalityType)
            && ::PotionResurrection.restore(this, effect))
        {
            return;
        }

        return __original(_killer, _skill, _fatalityType, _silent);
    }
});
