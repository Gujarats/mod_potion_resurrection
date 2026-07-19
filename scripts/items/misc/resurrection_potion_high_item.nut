this.resurrection_potion_high_item <- this.inherit("scripts/items/misc/resurrection_potion_item", {
    m = {},

    function create()
    {
        this.resurrection_potion_item.create();
        this.m.ID = "misc.resurrection_potion_high";
        this.m.Name = "Potion of Resurrection - High";
        this.m.Description = "A red draught that anchors a mercenary to life until it has defeated one eligible battlefield death.";
        this.m.Tier = "high";
        this.m.Icon = "consumables/resurrection_potion_high.png";
        this.m.Value = ::PotionResurrection.getScaledPrice(this.m.Tier);
    }
});
