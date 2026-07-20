this.resurrection_potion_effect <- this.inherit("scripts/skills/skill", {
    m = {
        Tier = "normal",
        IsTriggering = false
    },

    function create()
    {
        this.m.ID = "effects.resurrection_potion";
        this.m.Name = "Resurrection Draught";
        this.m.Description = "A resurrection potion courses through this character. It will prevent one eligible battlefield death, then be expended.";
        this.m.Icon = "skills/status_effect_73.png";
        this.m.IconMini = "status_effect_73_mini";
        this.m.Type = this.Const.SkillType.StatusEffect;
        this.m.IsActive = false;
        this.m.IsRemovedAfterBattle = false;
    }

    function setTier( _tier )
    {
        this.m.Tier = _tier in ::PotionResurrection.Tiers ? _tier : "normal";
    }

    function getTier()
    {
        return this.m.Tier;
    }

    function isTriggering()
    {
        return this.m.IsTriggering;
    }

    function setTriggering( _value )
    {
        this.m.IsTriggering = _value;
    }

    function getTooltip()
    {
        local tier = ::PotionResurrection.Tiers[this.m.Tier];
        local health = ::PotionResurrection.conf(tier.HealthSetting);
        local armor = ::PotionResurrection.conf(tier.ArmorSetting);
        return [
            {
                id = 1,
                type = "title",
                text = tier.Name + " Resurrection Draught"
            },
            {
                id = 2,
                type = "description",
                text = "Permanently prevents one eligible battlefield death, restoring " + health + "% health and " + armor + "% head and body armor. Kraken devouring and scripted deaths are excluded. Drinking another resurrection potion replaces this effect."
            }
        ];
    }

    function onCombatStarted()
    {
        local actor = this.getContainer().getActor();
        ::PotionResurrection.debugLog("Effect active at combat start for " + actor.getName() + "; tier=" + this.m.Tier);
    }

    function onSerialize( _out )
    {
        this.skill.onSerialize(_out);
        _out.writeString(this.m.Tier);
    }

    function onDeserialize( _in )
    {
        this.skill.onDeserialize(_in);
        this.setTier(_in.readString());
        this.m.IsTriggering = false;
    }
});
