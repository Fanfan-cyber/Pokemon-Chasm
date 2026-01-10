module BattleLoader
  BATTLE_LOADER_PATH = "Team Data"
  @@battle_loader    = []
  @@coded_teams      = []
  @@refresh          = true

  def self.load_data
    return unless @@refresh
    Dir.mkdir(BATTLE_LOADER_PATH) rescue nil
    @@battle_loader.clear
    teams = Dir.glob("#{BATTLE_LOADER_PATH}/*.txt")
    teams.each do |info|
      encrypted_data = File.read(info)
      team_info = process_encrypted_data(encrypted_data)
      team_info[4] = [] unless team_info[4]
      @@battle_loader.push(team_info) # [rule, name, team, unique_id, curse]
    end
    @@battle_loader.sort_by!(&:first)
    if @@coded_teams.empty?
      TEAM_DATA.each do |type, teams|
        teams.each do |team_data, encrypted_data|
          team_info = process_encrypted_data(encrypted_data)
          team_info[4] = [] unless team_info[4]
          team_info[5] = team_data[1] # [rule, name, team, unique_id, curse, deletability], true means undeletable inique_id is a string
          team_info[6] = type # [rule, name, team, unique_id, curse, deletability , tag]
          @@coded_teams.push(team_info)
        end
      end
    end
    @@battle_loader.concat(@@coded_teams)
    check_legality
    @@refresh = false
    PokemonDataBase.create_mass
  end

  def self.process_encrypted_data(encrypted_str)
    Marshal.restore(Zlib::Inflate.inflate(encrypted_str.unpack("m")[0]))
  end

  def self.add_data(rule, name = "", team = nil, curse = [])
    name = $Trainer.name if name.empty?
    unique_id = generate_unique_id
    new_team = [rule, name, (team || $Trainer.party), unique_id, curse]
    encrypted_data = [Zlib::Deflate.deflate(Marshal.dump(new_team))].pack("m")
    File.open("#{BATTLE_LOADER_PATH}/#{rule}_#{name}_#{unique_id}.txt", "wb") do |file|
      file.write(encrypted_data)
    end
    @@refresh = true
    load_data
  end

  def self.delete_data(unique_id, show_message = true)
    teams = Dir.glob("#{BATTLE_LOADER_PATH}/*.txt")
    deleted = false
    teams.each do |info|
      next unless info.include?(unique_id)
      File.delete(info)
      deleted = true
      break
    end
    if show_message
      if deleted
        pbMessage(_INTL("Team {1} has been deleted!", unique_id))
      else
        pbMessage(_INTL("The team can't be deleted!"))
      end
    end
    @@refresh = true
    load_data
  end

  def self.add_trainer_data(battle)
    return if TA.get(:battle_loader)
    return if battle.is_replayed
    return unless battle.trainerBattle?
    length = battle.opponent.length
    return if length >= 3
    if pbConfirmMessageSerious(_INTL("Do you want to add the opposing team to the Battle Loader?"))
      load_data
      curse = battle.curses
      rules = ["1v1", "2v2", "1v2", "2v1"]
      ret = pbMessage(_INTL("Which battle rule do you want to use?"), rules, 0)
      if ret >= 0
        if length == 1
          team = battle.pbParty(1)
        else
          team = []
          battle.opponent.each_with_index do |trainer, index|
            if index == 0
              team.concat(trainer.party)
            else
              team.insert(1, trainer.party[0]) 
              team.concat(trainer.party.drop_first)
            end
          end
        end
        team.each { |pkmn| pkmn.heal }
        if pbConfirmMessage(_INTL("Would you like to give it a name?"))
          name = pbEnterText(_INTL("What name?"), 0, 30)
          if name.empty?
            add_data(rules[ret], battle.opponent.sample.name, team, curse)
          else
            add_data(rules[ret], name, team, curse)
          end
        else
          if length > 1
            names = battle.opponent.map(&:name)
            choose = pbMessage(_INTL("Which default name do you want to use?"), names, -1)
            if choose >= 0
              add_data(rules[ret], battle.opponent[choose].name, team, curse)
            else
              add_data(rules[ret], battle.opponent.sample.name, team, curse)
            end
          else
            add_data(rules[ret], battle.opponent[0].name, team, curse)
          end
        end
        pbMessage(_INTL("The team has been registered!"))
      end
    end
  end

  def self.open_battle_loader
    unless $Trainer.has_pokemon?
      pbMessage(_INTL("You can't start a battle now because you don't have any Pokémon!"))
      return
    end
    loop do
      choice = [_INTL("Battle"), _INTL("Export Team"), _INTL("Delete Team"), _INTL("Check Stats"), _INTL("Check Recorded Teams"), _INTL("Cancel")]
      choose = pbMessage(_INTL("What do you want to do?"), choice, -1)
      case choose
      when -1, 5 # Cancel
        break
      when 4
        GymLeaderRematch.check_recorded_teams
      when 3 # Check Stats
        pbMessage(_INTL("Your Victory count is {1}!\nYour Defeat count is {2}!", TA.get(:battle_victory, 0), TA.get(:battle_defeat, 0)))
      when 0 # Battle
        load_data
        if @@battle_loader.empty?
          pbMessage(_INTL("There aren't any teams in the Battle Loader!"))
        else
          loop do
            battle_mode = [_INTL("All Teams"), _INTL("Random Team"), _INTL("Random Pokémon Team"), _INTL("Former Champion Team"), _INTL("Mirror Team"), _INTL("Achievement Challenge"), _INTL("Cancel")]
            battle_mode.insert(6, _INTL("Copy Team")) if $DEBUG
            mode_chosen = pbMessage(_INTL("What do you want to do?"), battle_mode, -1)
            case mode_chosen
            when -1, 7 # Cancel
              break
            when 6 # Copy Team
              break unless $DEBUG
              names = @@battle_loader.map { |team_info| "#{team_info[0]} #{team_info[1]}" }
              index = pbMessage(_INTL("Which team do you want to copy?"), names, -1)
              if index >= 0
                team_data = @@battle_loader[index]
                $Trainer.party = team_data[2].map { |pkmn| pkmn.clone_pkmn(true, true) }
                pbMessage(_INTL("Copied the party of {1}.", team_data[1]))
              end
            when 5 # Achievement Challenge
              unless $Trainer&.checkBadge(8) || $DEBUG
                pbMessage(_INTL("You can't take the Achievement Challenge, because you don't have 8 badges!"))
                break
              end
              loop do
                challenge_chosen = pbMessage(_INTL("Which do you want to challenge?"), [_INTL("Type"), _INTL("Tribe"), _INTL("Cancel")], -1)
                case challenge_chosen
                when -1, 2
                  break
                when 0 # Type
                  teams = @@battle_loader.select { |team| team[6] == :Type }
                when 1 # Tribe
                  teams = @@battle_loader.select { |team| team[6] == :Tribe }
                end
                names = teams.map { |team_info| "#{team_info[0]} #{team_info[1]}" << ($Trainer.battle_loader_teams.include?(team_info[3]) ? " V" : " ") }
                index = pbMessage(_INTL("Which team do you want to challenge?"), names, -1)
                if index >= 0
                  rule      = teams[index][0]
                  team      = teams[index][2]
                  curse     = teams[index][4]
                  unique_id = teams[index][3]
                  INVALID_CURSE.each { |c| curse.delete(c) }
                  curse << get_random_curse if curse.empty?
                  #rules = ["1v1", "2v2", "1v2", "2v1"]
                  #rules.reject! {|other_rule| other_rule == rule }
                  #ret = pbMessage(_INTL("Do you want to use other battle rules?"), rules, -1)
                  #if ret >= 0
                    #start_battle(rules[ret], team, curse, unique_id)
                  #else
                    start_battle(rule, team, curse, unique_id)
                  #end
                end
              end
            when 4 # Mirror Team
              rules = ["1v1", "2v2", "1v2", "2v1"]
              ret = pbMessage(_INTL("Which battle rule do you want to use?"), rules, -1)
              if ret >= 0
                start_battle(rules[ret], $Trainer.party,)
              else
                #start_battle(rules[0], team, curse)
              end
            when 3 # Former Champion Team
              if $Trainer&.checkBadge(8) || $DEBUG
                teams = @@battle_loader.select { |team| team[6] == :FormerChampion }
                names = teams.map { |team_info| "#{team_info[0]} #{team_info[1]}" << ($Trainer.battle_loader_teams.include?(team_info[3]) ? " V" : " ") }
                index = pbMessage(_INTL("Which team do you want to challenge?"), names, -1)
                if index >= 0
                  rule      = teams[index][0]
                  team      = teams[index][2]
                  curse     = teams[index][4]
                  unique_id = teams[index][3]
                  INVALID_CURSE.each { |c| curse.delete(c) }
                  curse << get_random_curse if curse.empty?
                  #rules = ["1v1", "2v2", "1v2", "2v1"]
                  #rules.reject! {|other_rule| other_rule == rule }
                  #ret = pbMessage(_INTL("Do you want to use other battle rules?"), rules, -1)
                  #if ret >= 0
                    #start_battle(rules[ret], team, curse, unique_id)
                  #else
                    start_battle(rule, team, curse, unique_id)
                  #end
                end
              else
                pbMessage(_INTL("You can't challenge Former Champion Team, because you don't have 8 badges!"))
                break
              end
            when 0 # All Teams
              teams = @@battle_loader.select { |team| team[6].nil? }
              names = teams.map { |team_info| "#{team_info[0]} #{team_info[1]}" }
              index = pbMessage(_INTL("Which team do you want to challenge?"), names, -1)
              if index >= 0
                rule  = teams[index][0]
                team  = teams[index][2]
                curse = teams[index][4]
                rules = ["1v1", "2v2", "1v2", "2v1"]
                rules.reject! {|other_rule| other_rule == rule }
                ret = pbMessage(_INTL("Do you want to use other battle rules?"), rules, -1)
                if ret >= 0
                  start_battle(rules[ret], team, curse)
                else
                  start_battle(rule, team, curse)
                end
              end
            when 1 # Random Team
              random_chosen = @@battle_loader.sample
              team  = random_chosen[2]
              curse = random_chosen[4]
              rules = ["1v1", "2v2", "1v2", "2v1"]
              ret = pbMessage(_INTL("Which battle rule do you want to use?"), rules, -1)
              if ret >= 0
                start_battle(rules[ret], team, curse)
              else
                #start_battle(rules[0], team, curse)
              end
            when 2 # Random Pokémon Team
              PokemonDataBase.create_mass
              team = get_random_pkmn_team
              rules = ["1v1", "2v2", "1v2", "2v1"]
              ret = pbMessage(_INTL("Which battle rule do you want to use?"), rules, -1)
              if ret >= 0
                start_battle(rules[ret], team)
              else
                #start_battle(rules[0], team)
              end
              PokemonDataBase.create_mass
            end
          end
        end
      when 1 # Export Team
        load_data
        rules = ["1v1", "2v2", "1v2", "2v1"]
        ret = pbMessage(_INTL("Which battle rule do you want?"), rules, -1)
        if ret >= 0
          name = ""
          if pbConfirmMessage(_INTL("Would you like to give it a name?"))
            name = pbEnterText(_INTL("What name?"), 0, 30)
          end
          curse = []
          if pbConfirmMessage(_INTL("Would you like to give it a Curse Effect?"))
            curses = []
            GameData::Policy::DATA.each_key do |policy|
              next if INVALID_CURSE.include?(policy)
              policy = policy.to_s
              next unless policy.start_with?("CURSE_")
              curses.push(policy)
            end
            curse_index = pbMessage(_INTL("Which Curse Effect do you want?"), curses, -1)
            curse << curses[curse_index].to_sym if curse_index >= 0
          end
          if pbConfirmMessage(_INTL("Would you like to give it a Custom Effect?"))
            curses = []
            get_custom_effect.each_key do |policy|
              policy = policy.to_s
              curses.push(policy)
            end
            curse_index = pbMessage(_INTL("Which Custom Effect do you want?"), curses, -1)
            curse << curses[curse_index].to_sym if curse_index >= 0
          end
          add_data(rules[ret], name, nil, curse)
          pbMessage(_INTL("Your team has been exported!"))
        end
      when 2 # Delete Team
        load_data
        if @@battle_loader.empty?
          pbMessage(_INTL("There aren't any teams in the Battle Loader!"))
        else
          teams = @@battle_loader.select { |team| team[5].nil? }
          names = teams.map { |team_info| "#{team_info[0]} #{team_info[1]}" }
          index = pbMessage(_INTL("Which team do you want to delete?"), names, -1)
          if index >= 0 && pbConfirmMessage(_INTL("Do you really want to delete it?"))
            unique_id = teams[index][3]
            delete_data(unique_id)
          end
        end
      end
    end
  end

  def self.get_custom_effect
    { :CUSTOM_INFINITE_SCREEN => _INTL("The Screen Effects will never end during this battle!"), }
  end

  def self.export_team
    load_data
    add_data("1v1")
    pbMessage(_INTL("Your team has been exported!"))
  end

  def self.get_all_teams
    load_data
    @@battle_loader.map { |team_data| team_data[2] }
  end

  def self.get_all_pkmn
    get_all_teams.flatten
  end

  def self.each_pokemon
    @@battle_loader.each do |team_info|
      team_info[2].each do |pokemon|
        yield pokemon, _INTL("the Battle Loader")
      end
    end
  end

  def self.check_legality
    method_object = method(:each_pokemon)
    removeIllegalElementsFromAllPokemon(nil, method_object)
  end

  def self.get_random_pkmn_team
    battle_loader_data = @@battle_loader.map { |team_data| team_data[2] }
    pkmn_data_base = PokemonDataBase.get_pkmn_data_base
    battle_loader_data.concat(pkmn_data_base).flatten!.sample(6)
  end

  INVALID_CURSE = %i[CURSE_DELEVELED CURSE_BOOSTED_ELECTRIC CURSE_DULLED CURSE_FIGHT_EXTENDED CURSE_NO_MERCY
                     CURSE_SUPER_ITEMS CURSE_NO_MERCY_2 CURSE_AVATAR_GUARD CURSE_EXTRA_TYPES CURSE_SAND_ABILITIES
                     CURSE_EXTRA_ITEMS CURSE_NO_MERCY_3 CURSE_NO_MERCY_4]

  def self.get_random_curse
    curses = []
    GameData::Policy::DATA.each_key do |policy|
      next if INVALID_CURSE.include?(policy)
      next unless policy.to_s.start_with?("CURSE_")
      curses.push(policy)
    end
    curses.sample
  end

  def self.start_battle(rule, team, curse = [], unique_id = nil)
    INVALID_CURSE.each { |c| curse.delete(c) }
    setBattleRule(rule)
    TA.set(:battle_loader, true)
    TA.set(:team, team)
    TA.set(:curse, curse)
    trainer = GameData::Trainer.values.sample
    trainer_type = trainer.trainer_type
    trainer_type_data = GameData::TrainerType.get(trainer_type)
    if trainer_type_data.male?
      TA.set(:name, BOY_NAMES.sample)
    elsif trainer_type_data.female?
      TA.set(:name, GIRL_NAMES.sample)
    else
      TA.set(:name, _INTL("Unknown"))
    end
    begin
      #pbTrainerBattle(:LEADER_Lambert, "Lambert", nil, false, 0, true)
      results = pbTrainerBattle(trainer_type, trainer.real_name, nil, false, 0, true)
      if results
        TA.increase(:battle_victory)
        if unique_id
          battle_loader_teams = $Trainer.battle_loader_teams
          battle_loader_teams << unique_id unless battle_loader_teams.include?(unique_id)
        end
      else
        TA.increase(:battle_defeat)
      end
    rescue
      start_battle(rule, team, curse, unique_id)
    ensure
      TA.set(:battle_loader, false) 
    end
  end
end

module PokemonDataBase
  PKMN_DATA_AMOUNT  = 30
  LOWEST_PKMN_BST   = 400
  LOWEST_MOVE_POWER = 65

  @@pkmn_data = []

  def self.create_pkmn
    species_list = GameData::Species.keys.shuffle
    species_list.each do |species|
      species_data = GameData::Species.get(species)
      next if species_data.isTest?
      next if species_data.base_stat_total < LOWEST_PKMN_BST
      pkmn = Pokemon.new(species_data.id, 1)
      learn_random_moves(pkmn, species_data)
      pkmn.calc_stats
      @@pkmn_data << pkmn
      return pkmn
    end
  end

  def self.learn_random_moves(pkmn, species_data = nil)
    pkmn.forget_all_moves
    species_data = GameData::Species.get(pkmn.species) unless species_data
    legal_moves = species_data.learnable_moves.shuffle
    legal_moves.each do |move|
      move_data = GameData::Move.get(move)
      next if move_data.base_damage < LOWEST_MOVE_POWER
      pkmn.learn_move(move_data)
      break if pkmn.moves.size == Pokemon::MAX_MOVES
    end
    legal_moves.each do |move|
      break if pkmn.moves.size == Pokemon::MAX_MOVES
      move_data = GameData::Move.get(move)
      pkmn.learn_move(move_data)
    end
  end

  def self.create_mass
    PKMN_DATA_AMOUNT.times { create_pkmn }
  end

  def self.get_pkmn_data_base
    @@pkmn_data
  end
end