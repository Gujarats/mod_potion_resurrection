::PotionResurrection.clamp <- function( _value, _minimum, _maximum )
{
    return ::Math.max(_minimum, ::Math.min(_maximum, _value));
};

::PotionResurrection.debugLog <- function( _message )
{
    ::PotionResurrection.Mod.Debug.printLog("[PotionResurrection] " + _message);
};

::PotionResurrection.ResurrectionFadeDuration <- 250;
::PotionResurrection.ResurrectionHiddenDuration <- 600;
::PotionResurrection.ResurrectionRiseDuration <- 850;
::PotionResurrection.ResurrectionAnimationSerial <- 0;
::PotionResurrection.ActiveResurrectionSequences <- {};

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

::PotionResurrection.addCosmeticCorpseDetail <- function( _details, _actor, _tile, _brush, _flip, _color = null, _saturation = null )
{
    if (_brush == null || _brush == "")
    {
        return;
    }

    try
    {
        ::PotionResurrection.debugLog("addCosmeticCorpseDetail started for " + _actor.getName() + "; brush=" + _brush + ", flip=" + _flip.tostring());
        local detail = _tile.spawnDetail(
            _brush,
            ::Const.Tactical.DetailFlag.SpecialOverlay,
            _flip,
            false,
            ::Const.Combat.HumanCorpseOffset
        );
        if (detail == null)
        {
            return;
        }

        if (_color != null)
        {
            detail.Color = _color;
        }
        if (_saturation != null)
        {
            detail.Saturation = _saturation;
        }
        detail.Scale = 0.9;
        detail.Alpha = 0;
        detail.setBrightness(0.9);
        _details.push(detail);
    }
    catch (error) {
        ::PotionResurrection.debugLog("addCosmeticCorpseDetail failed for " + _actor.getName() + ": " + error);
    }
};

// These details intentionally use SpecialOverlay instead of Corpse. They are
// visual-only and must never affect tile corpse state, casualties, or AI.
::PotionResurrection.spawnCosmeticCorpse <- function( _actor, _tile )
{
    local details = [];
    if (_actor == null || _tile == null)
    {
        return details;
    }

    try
    {
        local flip = ::Math.rand(0, 1) == 1;
        local body = _actor.getSprite("body");
        local head = _actor.getSprite("head");
        local appearance = _actor.getItems().getAppearance();
        local skinColor = head != null ? head.Color : null;
        local skinSaturation = head != null ? head.Saturation : null;

        if (body != null && body.HasBrush)
        {
            ::PotionResurrection.addCosmeticCorpseDetail(details, _actor, _tile, body.getBrush().Name + "_dead", flip, skinColor, skinSaturation);
        }
        if (appearance.CorpseArmor != "")
        {
            ::PotionResurrection.addCosmeticCorpseDetail(details, _actor, _tile, appearance.CorpseArmor, flip);
        }
        if (head != null && head.HasBrush && !appearance.HideCorpseHead)
        {
            ::PotionResurrection.addCosmeticCorpseDetail(details, _actor, _tile, head.getBrush().Name + "_dead", flip, head.Color, head.Saturation);
        }
    }
    catch (error)
    {
        ::PotionResurrection.Mod.Debug.printLog("[PotionResurrection] Cosmetic corpse setup failed for " + _actor.getName() + ": " + error);
    }

    return details;
};

::PotionResurrection.showCosmeticCorpse <- function( _data )
{
    if (!("CosmeticCorpseDetails" in _data))
    {
        return;
    }

    foreach (detail in _data.CosmeticCorpseDetails)
    {
        if (detail == null)
        {
            continue;
        }

        try
        {
            detail.Alpha = 255;
            detail.fadeOutAndHide(::PotionResurrection.ResurrectionHiddenDuration);
        }
        catch (error)
        {
            // A failed overlay animation must not stop the resurrection itself.
            detail.Alpha = 0;
        }
    }
};

::PotionResurrection.playResurrectionAnimation <- function( _actor, _source = null )
{
    if (_actor == null || !_actor.isAlive() || !_actor.isPlacedOnMap())
    {
        return;
    }

    try
    {
        _actor.riseFromGround(0.75);
        ::PotionResurrection.debugLog("Native resurrection animation started for " + _actor.getName());
    }
    catch (error)
    {
        ::PotionResurrection.Mod.Debug.printLog("[PotionResurrection] Resurrection animation failed for " + _actor.getName() + ": " + error);
        return;
    }

    try
    {
        local tile = _actor.getTile();
        if (tile == null || !tile.IsVisibleForPlayer)
        {
            return;
        }

        if ("RaiseUndeadParticles" in ::Const.Tactical)
        {
            foreach (particle in ::Const.Tactical.RaiseUndeadParticles)
            {
                ::Tactical.spawnParticleEffect(
                    true,
                    particle.Brushes,
                    tile,
                    particle.Delay,
                    particle.Quantity,
                    particle.LifeTimeQuantity,
                    particle.SpawnRate,
                    particle.Stages
                );
            }
        }

        ::Tactical.spawnIconEffect(
            "status_effect_151",
            tile,
            ::Const.Tactical.Settings.SkillIconOffsetX,
            ::Const.Tactical.Settings.SkillIconOffsetY,
            ::Const.Tactical.Settings.SkillIconScale,
            ::Const.Tactical.Settings.SkillIconFadeInDuration,
            ::Const.Tactical.Settings.SkillIconStayDuration,
            ::Const.Tactical.Settings.SkillIconFadeOutDuration,
            ::Const.Tactical.Settings.SkillIconMovement
        );
        if (_source != null && _source.isAlive())
        {
            ::Tactical.getCamera().quake(_source, _actor, 4.0, 0.25, 0.3);
        }
    }
    catch (error)
    {
        ::PotionResurrection.Mod.Debug.printLog("[PotionResurrection] Resurrection secondary visuals failed for " + _actor.getName() + ": " + error);
    }
};

::PotionResurrection.isResurrectionSequenceCurrent <- function( _data )
{
    if (_data == null || _data.Actor == null || ::Tactical.State == null || ::Tactical.State != _data.TacticalState)
    {
        return false;
    }

    local actor = _data.Actor;
    if (!("PotionResurrectionAnimationToken" in actor.m)
        || actor.m.PotionResurrectionAnimationToken != _data.Token
        || !actor.isAlive()
        || !actor.isPlacedOnMap())
    {
        return false;
    }

    local tile = actor.getTile();
    return tile != null && tile.SquareCoords.X == _data.TileX && tile.SquareCoords.Y == _data.TileY;
};

::PotionResurrection.recoverResurrectionSequence <- function( _data, _reason )
{
    if (_data == null)
    {
        return;
    }

    local key = _data.Token.tostring();
    if (key in ::PotionResurrection.ActiveResurrectionSequences)
    {
        ::PotionResurrection.ActiveResurrectionSequences.rawdelete(key);
    }

    if (_data.Actor == null)
    {
        return;
    }

    local actor = _data.Actor;
    try
    {
        if (("PotionResurrectionAnimationToken" in actor.m) && actor.m.PotionResurrectionAnimationToken == _data.Token)
        {
            actor.setAlpha(255);
            actor.m.IsRaising = false;
            actor.m.IsSinking = false;
            actor.m.IsAttackable = true;
            actor.setRenderCallbackEnabled(false);
            ::PotionResurrection.debugLog("Resurrection sequence recovered for " + actor.getName() + "; reason=" + _reason);
        }
    }
    catch (error)
    {
        ::PotionResurrection.Mod.Debug.printLog("[PotionResurrection] Resurrection recovery failed: " + error);
    }
};

::PotionResurrection.finishResurrectionSequence <- function( _data )
{
    try
    {
        if (!::PotionResurrection.isResurrectionSequenceCurrent(_data))
        {
            ::PotionResurrection.recoverResurrectionSequence(_data, "stale completion callback");
            return;
        }

        local actor = _data.Actor;
        actor.setAlpha(255);
        actor.m.IsRaising = false;
        actor.m.IsSinking = false;
        actor.m.IsAttackable = true;
        actor.setRenderCallbackEnabled(false);
        local key = _data.Token.tostring();
        if (key in ::PotionResurrection.ActiveResurrectionSequences)
        {
            ::PotionResurrection.ActiveResurrectionSequences.rawdelete(key);
        }
        ::PotionResurrection.debugLog("Resurrection sequence completed for " + actor.getName());
    }
    catch (error)
    {
        ::PotionResurrection.recoverResurrectionSequence(_data, "completion error: " + error);
    }
};

::PotionResurrection.onResurrectionHiddenIntervalFinished <- function( _data )
{
    try
    {
        if (!::PotionResurrection.isResurrectionSequenceCurrent(_data))
        {
            ::PotionResurrection.recoverResurrectionSequence(_data, "stale rise callback");
            return;
        }

        local actor = _data.Actor;
        if (_data.ArmorRestorePct != null)
        {
            ::PotionResurrection.restoreArmorSlot(actor, ::Const.ItemSlot.Body, _data.ArmorRestorePct);
            ::PotionResurrection.restoreArmorSlot(actor, ::Const.ItemSlot.Head, _data.ArmorRestorePct);
            actor.getItems().updateAppearance();
        }
        actor.setAlpha(0);
        ::PotionResurrection.playResurrectionAnimation(actor, _data.Source);
        ::PotionResurrection.debugLog("Armor restored and resurrection rise started for " + actor.getName());
        ::Time.scheduleEvent(::TimeUnit.Virtual, ::PotionResurrection.ResurrectionRiseDuration, ::PotionResurrection.finishResurrectionSequence, _data);
    }
    catch (error)
    {
        ::PotionResurrection.recoverResurrectionSequence(_data, "rise error: " + error);
    }
};

::PotionResurrection.onResurrectionFadeFinished <- function( _data )
{
    try
    {
        if (!::PotionResurrection.isResurrectionSequenceCurrent(_data))
        {
            ::PotionResurrection.recoverResurrectionSequence(_data, "stale cosmetic corpse callback");
            return;
        }

        local actor = _data.Actor;
        ::PotionResurrection.showCosmeticCorpse(_data);
        actor.spawnBloodEffect(actor.getTile(), 0.75);
        ::Time.scheduleEvent(::TimeUnit.Virtual, ::PotionResurrection.ResurrectionHiddenDuration, ::PotionResurrection.onResurrectionHiddenIntervalFinished, _data);
        ::PotionResurrection.debugLog("Cosmetic corpse shown for " + actor.getName() + "; hiddenDuration=" + ::PotionResurrection.ResurrectionHiddenDuration.tostring());
    }
    catch (error)
    {
        ::PotionResurrection.recoverResurrectionSequence(_data, "cosmetic corpse error: " + error);
    }
};

::PotionResurrection.startResurrectionSequence <- function( _actor, _source = null, _armorRestorePct = null )
{
    if (_actor == null || !_actor.isAlive() || !_actor.isPlacedOnMap() || ::Tactical.State == null)
    {
        return;
    }

    local tile = _actor.getTile();
    if (tile == null)
    {
        return;
    }

    ::PotionResurrection.ResurrectionAnimationSerial++;
    if (!("PotionResurrectionAnimationToken" in _actor.m))
    {
        _actor.m.PotionResurrectionAnimationToken <- 0;
    }
    _actor.m.PotionResurrectionAnimationToken = ::PotionResurrection.ResurrectionAnimationSerial;

    local data = {
        Actor = _actor,
        Source = _source,
        Token = _actor.m.PotionResurrectionAnimationToken,
        TacticalState = ::Tactical.State,
        TileX = tile.SquareCoords.X,
        TileY = tile.SquareCoords.Y,
        ArmorRestorePct = _armorRestorePct,
        CosmeticCorpseDetails = ::PotionResurrection.spawnCosmeticCorpse(_actor, tile)
    };
    ::PotionResurrection.ActiveResurrectionSequences[data.Token.tostring()] <- data;

    try
    {
        _actor.m.IsAttackable = false;
        _actor.fadeOut(::PotionResurrection.ResurrectionFadeDuration);
        ::PotionResurrection.debugLog("Simulated death fade started for " + _actor.getName());
        ::Time.scheduleEvent(::TimeUnit.Virtual, ::PotionResurrection.ResurrectionFadeDuration, ::PotionResurrection.onResurrectionFadeFinished, data);
        ::PotionResurrection.debugLog("Cosmetic corpse scheduled for " + _actor.getName());
    }
    catch (error)
    {
        ::PotionResurrection.recoverResurrectionSequence(data, "start error: " + error);
    }
};

::PotionResurrection.restore <- function( _actor, _effect, _source = null )
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
        _actor.getSkills().removeByID("effects.resurrection_potion");
        _actor.getSkills().update();
        _actor.setDirty(true);
        _actor.setMoraleState(::Const.MoraleState.Steady);

        ::Tactical.EventLog.logEx(::Const.UI.getColorizedEntityName(_actor) + " is restored by a " + tier.Name + " Potion of Resurrection!");
        ::PotionResurrection.startResurrectionSequence(_actor, _source, armorPct);
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
            && ::PotionResurrection.restore(this, effect, _killer))
        {
            return;
        }

        return __original(_killer, _skill, _fatalityType, _silent);
    }
});

::PotionResurrection.HooksMod.hook("scripts/states/tactical_state", function(q)
{
    q.onBattleEnded = @(__original) function()
    {
        local active = [];
        foreach (data in ::PotionResurrection.ActiveResurrectionSequences)
        {
            active.push(data);
        }
        foreach (data in active)
        {
            ::PotionResurrection.recoverResurrectionSequence(data, "battle ended");
        }

        return __original();
    }
});
