this.resurrection_potion_normal_item <- this.inherit("scripts/items/misc/resurrection_potion_item", {
    m = {},

    function create()
    {
        this.resurrection_potion_item.create();
        this.m.ID = "misc.resurrection_potion_normal";
        this.m.Name = "Potion of Resurrection - Normal";
        this.m.Description = "A black draught that anchors a mercenary to life until it has defeated one eligible battlefield death.";
        this.m.Tier = "normal";
        this.m.Icon = "consumables/resurrection_potion_normal.png";
        this.m.Value = ::PotionResurrection.getScaledPrice(this.m.Tier);
    }
});
