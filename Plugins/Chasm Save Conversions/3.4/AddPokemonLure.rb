SaveData.register_conversion(:pokemon_lure_3_4_0) do
    game_version '3.4.0'
    display_title 'Adding the Pokemon Lure 3.4.0'
    to_all do |save_data|
        globalSwitches = save_data[:switches]
        globalVariables = save_data[:variables]
        selfSwitches = save_data[:self_switches]
        itemBag = save_data[:bag]

        if selfSwitches[[32,14,'C']] # Completed Lost Growlithe quest
            itemBag.pbStoreItem(:POKEMONLURE, 1, false)
        end
    end
end