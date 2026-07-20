::PotionResurrectionSpawnerAddon <- ::Hooks.register(
    "mod_potion_resurrection_item_spawner_addon",
    "1.0.0",
    "Potion of Resurrection - Item Spawner Addon"
);

::PotionResurrectionSpawnerAddon.require([
    "mod_item_spawner",
    "mod_potion_resurrection"
]);

::PotionResurrectionSpawnerAddon.queue([
    ">mod_item_spawner",
    ">mod_potion_resurrection"
], function()
{
    local originalQueryItemUIData = ::ModItemSpawner.queryItemUIData;
    ::ModItemSpawner.queryItemUIData = function()
    {
        originalQueryItemUIData();

        local definitions = [
            {
                ID = "misc.resurrection_potion_normal",
                Script = "scripts/items/misc/resurrection_potion_normal_item"
            },
            {
                ID = "misc.resurrection_potion_medium",
                Script = "scripts/items/misc/resurrection_potion_medium_item"
            },
            {
                ID = "misc.resurrection_potion_high",
                Script = "scripts/items/misc/resurrection_potion_high_item"
            }
        ];

        foreach (definition in definitions)
        {
            local exists = false;
            foreach (entry in ::ModItemSpawner.Items[::ModItemSpawner.ItemFilter.All])
            {
                if (entry.ID == definition.ID)
                {
                    exists = true;
                    break;
                }
            }

            if (exists)
            {
                continue;
            }

            local item = ::new(definition.Script);
            ::ModItemSpawner.Stash.add(item);
            local data = {
                Index = null,
                ID = item.getID(),
                Name = item.getName(),
                Description = item.getDescription(),
                ShowAmount = item.isAmountShown(),
                Amount = item.getAmountString(),
                AmountColor = item.getAmountColor(),
                ImagePath = "ui/items/" + item.getIcon(),
                LayerImagePath = "",
                ImageOverlayPath = [""],
                CanChangeName = false,
                CanChangeAmount = false,
                CanChangeStats = false,
                ClassName = item.ClassNameHash,
                Script = definition.Script,
                Owner = ::ModItemSpawner.Stash.getID(),
                Attribute = null
            };

            ::ModItemSpawner.Items[::ModItemSpawner.ItemFilter.All].push(data);
            ::ModItemSpawner.Items[::ModItemSpawner.ItemFilter.Usable].push(data);
        }

        ::ModItemSpawner.Stash.sort();
    };
});
