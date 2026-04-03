SaveData.register_conversion(:technique_booster_3_4_0) do
    game_version '3.4.0'
    display_title 'Adding technique booster 3.4.0'
    to_all do |save_data|
        globalSwitches = save_data[:switches]
        globalVariables = save_data[:variables]
        selfSwitches = save_data[:self_switches]
        itemBag = save_data[:bag]
    
        itemBag.pbStoreItem(:TECHNIQUEBOOSTER, 1, false) if selfSwitches[[5,1,'A']] # defeated avatar of genesect
    end
end