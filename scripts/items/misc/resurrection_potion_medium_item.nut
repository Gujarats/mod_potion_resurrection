this.resurrection_potion_medium_item <- this.inherit("scripts/items/misc/resurrection_potion_item", {
    m = {},

    function create()
    {
        this.resurrection_potion_item.create();
        this.m.ID = "misc.resurrection_potion_medium";
        this.m.Name = "Potion of Resurrection - Medium";
        this.m.Description = "A blue resurrection potion that anchors a mercenary to life until it has defeated one eligible battlefield death.";
        this.m.Tier = "medium";
        this.m.Icon = "consumables/resurrection_potion_medium.png";
        this.m.Value = ::PotionResurrection.getScaledPrice(this.m.Tier);
    }
});
