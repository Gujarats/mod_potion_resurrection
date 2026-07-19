this.resurrection_potion_item <- this.inherit("scripts/items/item", {
    m = {
        Tier = "normal"
    },

    function create()
    {
        this.item.create();
        this.m.SlotType = this.Const.ItemSlot.None;
        this.m.ItemType = this.Const.Items.ItemType.Usable;
        this.m.IsDroppedAsLoot = true;
        this.m.IsAllowedInBag = false;
        this.m.IsUsable = true;
        this.m.IconLarge = "";
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
                text = this.getName()
            },
            {
                id = 2,
                type = "description",
                text = this.getDescription()
            },
            {
                id = 66,
                type = "text",
                text = this.getValueString()
            },
            {
                id = 3,
                type = "image",
                image = this.getIcon()
            },
            {
                id = 11,
                type = "text",
                icon = "ui/icons/health.png",
                text = "Restores [color=" + this.Const.UI.Color.PositiveValue + "]" + health + "%[/color] health and [color=" + this.Const.UI.Color.PositiveValue + "]" + armor + "%[/color] head and body armor when triggered"
            },
            {
                id = 65,
                type = "text",
                text = "Right-click or drag onto the currently selected character to drink. This item is consumed in the process, and its effect remains until triggered."
            },
            {
                id = 66,
                type = "hint",
                icon = "ui/tooltips/warning.png",
                text = "Drinking another resurrection potion replaces the existing resurrection effect."
            }
        ];
    }

    function playInventorySound( _eventType )
    {
        this.Sound.play("sounds/bottle_01.wav", this.Const.Sound.Volume.Inventory);
    }

    function onUse( _actor, _item = null )
    {
        if (_actor == null)
        {
            return false;
        }

        local effect = this.new("scripts/skills/effects/resurrection_potion_effect");
        effect.setTier(this.m.Tier);
        _actor.getSkills().removeByID("effects.resurrection_potion");
        _actor.getSkills().add(effect);
        this.Sound.play("sounds/combat/drink_0" + this.Math.rand(1, 3) + ".wav", this.Const.Sound.Volume.Inventory);
        this.Const.Tactical.Common.checkDrugEffect(_actor);
        return true;
    }
});
