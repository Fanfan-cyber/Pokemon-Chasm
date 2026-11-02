SaveData.register_conversion(:poke_xray_upgrade) do
  game_version '3.5.0'
  display_title 'Upgrading the Poke X-Ray if needed'
  to_all do |save_data|
      globalSwitches = save_data[:switches]
      globalVariables = save_data[:variables]
      selfSwitches = save_data[:self_switches]
      itemBag = save_data[:bag]

      # If talked to Helena in LuxTech Main
      save_data[:bag].pbChangeItem(:POKEXRAY,:POKEXRAY2) if selfSwitches[[78,26,'B']]
  end
end