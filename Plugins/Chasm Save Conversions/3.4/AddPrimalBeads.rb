SaveData.register_conversion(:primal_beads_3_4_0) do
    game_version '3.4.0'
    display_title 'Adding Primal Beads 3.4.0'
    to_all do |save_data|
        globalSwitches = save_data[:switches]
        globalVariables = save_data[:variables]
        selfSwitches = save_data[:self_switches]
        itemBag = save_data[:bag]
    
        itemBag.pbStoreItem(:PRIMALBEAD, 1, false) if selfSwitches[[258,17,'C']] # defeated whitebloom yezera
        itemBag.pbStoreItem(:PRIMALBEAD, 1, false) if selfSwitches[[215,3,'A']] # defeated rayquaza avatar
    end
end