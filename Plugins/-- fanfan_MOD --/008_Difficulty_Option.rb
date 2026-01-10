Events.onTrainerPartyLoad += proc { |_sender, e| # Used for Battle Loader
  next unless TA.get(:battle_loader)
  trainer = e[0]
  next unless trainer
  trainer.name = TA.get(:name)
  trainer.policies.clear
  trainer.policies.concat(TA.get(:curse))
  trainer.party.clear
  TA.get(:team).each { |pkmn| trainer.party << pkmn.clone_pkmn }
}

Events.onTrainerPartyLoad += proc { |_sender, e| # Used for Pokemon Copying
  next if TA.get(:battle_loader)
  next if TA.get(:nocopymon)
  trainer = e[0]
  next unless trainer
  next if trainer.trainer_type == :ABSOL
  party = trainer.party
  length = party.length
  next if length >= $Trainer.party.length
  if length < 6 || TA.get(:copywhatever)
    #copied_pkmn = $Trainer.party_random_pkmn(false, true, false, TA.get(:copied_mon, []))
    copied_pkmn = $Trainer.least_copied_pokemon
    next unless copied_pkmn
    copied_pkmn.copied_level = copied_pkmn.level
    party << copied_pkmn
  end
  party.shuffle! if trainer.trainer_type.to_s.include?("LEADER_Lambert")
}

Events.onTrainerPartyLoad += proc { |_sender, e| # Used for Level Sacling
  trainer = e[0]
  next unless trainer
  higher_level = [$Trainer.party_highest_level, trainer.party_highest_level].max
  punish_level = TA.get(:kill_count, 0) - Settings::KILL_PUNNISHMENT
  trainer.party.each do |pkmn|
    if pkmn.copied_level
      pkmn.level = pkmn.copied_level - 1
    else
      pkmn.level = higher_level # level
      pkmn.level += 1 if pkmn.level < MAX_LEVEL_CAP && rand(100) < 30 
    end
    if punish_level > 0
      punish_increment = [punish_level, MAX_LEVEL_CAP - pkmn.level].min
      pkmn.level += punish_increment
    end
    loop do
      species_data = pkmn.species_data # evo
      possible_evolutions = species_data.get_evolutions(true)
      break if possible_evolutions.empty?
      valid_evolutions = []
      possible_evolutions.each do |evo|
        evo_species = evo[0]
        evo_species_data = GameData::Species.get(evo_species)
        valid_evolutions << evo if evo_species_data.available_by?(pkmn.level)
      end
      break if valid_evolutions.empty?
      evo_species = valid_evolutions.sample[0]
      pkmn.species = evo_species
    end
    pkmn.calc_stats
    pkmn.heal
  end
}

Events.onTrainerPartyLoad += proc { |_sender, e| # Used for setting default items for opposing Pokemon
  trainer = e[0]
  next unless trainer
  trainer.party.each do |pkmn|
    next if pkmn.hasItem?
    pkmn.items.concat(Settings::DEFAULT_ITEMS)
  end
}

Events.onTrainerPartyLoad += proc { |_sender, e| # Used for Custom Ability Mode
  next unless TA.get(:customabil)
  trainer = e[0]
  next unless trainer
  trainer.party.each do |pkmn|
    next if pkmn.has_main_ability?
    #pkmn.ability = TA.choose_random_ability(pkmn)
    possible_abil = TA.choose_random_ability_from_player(pkmn)
    pkmn.ability = possible_abil if possible_abil
  end
}