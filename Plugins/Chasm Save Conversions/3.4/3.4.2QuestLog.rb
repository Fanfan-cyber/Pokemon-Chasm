SaveData.register_conversion(:quest_log_3_4_2) do
  game_version '3.4.2'
  display_title 'Fixing some uncompletable quests from 3.4'
  to_all do |save_data|
      globalSwitches = save_data[:switches]
      globalVariables = save_data[:variables]
      selfSwitches = save_data[:self_switches]
      itemBag = save_data[:bag]

      questLog = save_data[:global_metadata].quests

      questLog.completeQuest(:QUEST_LEGEND_CONDENSED) if selfSwitches[[351,11,'B']] # "Received Necrozma from Lainie"
  end
end
