TeamData = Struct.new(:rule, :name, :team, :unique_id, :curses, :tags) do
  def initialize(rule: "1v1", name: "", team: [], unique_id: "", curses: [], tags: [])
    super(rule, name, team, unique_id, curses, tags)
  end
end

module BattleLoader
  BATTLE_LOADER_PATH = "Team Data"
  @@battle_loader    = []
  @@coded_teams      = []
  @@all_pkmn         = []
  @@all_coded_pkmn   = []
  @@refresh          = true

  def self.load_data
    return unless @@refresh
    Dir.mkdir(BATTLE_LOADER_PATH) rescue nil
    @@battle_loader.clear
    @@all_pkmn.clear

    # teams from text
    teams_data = Dir.glob("#{BATTLE_LOADER_PATH}/*.txt")
    teams_data.each do |team_info|
      encrypted_data = File.read(team_info)
      team_data = process_encrypted_data(encrypted_data) # [rule, name, team, unique_id, curse, tag]
      team = TeamData.new(rule: team_data[0], name: team_data[1], team: team_data[2], unique_id: team_data[3], curses: team_data[4] || [], tags: team_data[5] || [])
      [:text, :removable].each { |tag| team.tags << tag }
      @@battle_loader.push(team)
      @@all_pkmn.concat(team.team.flatten)
    end
    @@battle_loader.sort_by!(&:rule) # sort by rule

    # teams that hard-coded
    if @@coded_teams.empty? # only load once
      TEAM_DATA.each do |tags, teams_data|
        teams_data.each do |team_key, team_info| # the form of team_key is rule_name_unique_id, unused for now
          team_data = process_encrypted_data(team_info) # [rule, name, team, unique_id, curse, tag]
          team = TeamData.new(rule: team_data[0], name: team_data[1], team: team_data[2], unique_id: team_data[3], curses: team_data[4] || [], tags: team_data[5] || [])
          tags.each { |tag| team.tags << tag }
          @@coded_teams.push(team)
          @@all_coded_pkmn.concat(team.team.flatten)
        end
      end
    end
    @@battle_loader.concat(@@coded_teams)
    @@all_pkmn.concat(@@all_coded_pkmn)

    @@refresh = false
    PokemonDataBase.create_mass
  end

  def self.process_encrypted_data(encrypted_str)
    Marshal.restore(Zlib::Inflate.inflate(encrypted_str.unpack("m")[0]))
  end

  def self.export_data(rule, name = "", team = nil, curses = [], tags = [])
    name = $Trainer.name if name.empty?
    unique_id = generate_unique_id
    team_data = [rule, name, (team || $Trainer.party), unique_id, curses, tags]
    encrypted_data = [Zlib::Deflate.deflate(Marshal.dump(team_data))].pack("m")
    File.open("#{BATTLE_LOADER_PATH}/#{rule}_#{name}_#{unique_id}.txt", "wb") do |file|
      file.write(encrypted_data)
    end
    @@refresh = true
    load_data
  end

  def self.delete_data(unique_id, show_message = true)
    teams_data = Dir.glob("#{BATTLE_LOADER_PATH}/*.txt")
    deleted = false
    teams_data.each do |team_data|
      next unless team_data.include?(unique_id)
      File.delete(team_data)
      deleted = true
      break
    end
    if show_message
      if deleted
        pbMessage(_INTL("Team {1} has been deleted!", unique_id))
        $Trainer.battle_loader_teams.delete(unique_id)
      else
        pbMessage(_INTL("The team can't be deleted!"))
      end
    end
    @@refresh = true
    load_data
  end

  def self.export_trainer_data(battle)
    return if TA.get(:battle_loader)
    return if battle.is_replayed
    return unless battle.trainerBattle?
    if pbConfirmMessageSerious(_INTL("Do you want to add the opposing team to the Battle Loader?"))
      load_data
      curse = battle.curses
      rule = nil

      # record teams
      length = battle.opponent.length
      if length == 1
        rules = ["1v1", "2v2", "1v2", "2v1"]
        ret = pbMessage(_INTL("Which battle rule do you want to use?"), rules, 0)
        rule = rules[ret]
        team = battle.pbParty(1)
      else
        team = battle.opponent.map(&:party) # [party1, party2, party3]
      end
      team.flatten.each { |pkmn| pkmn.heal }

      # name team
      rule = rule || "#{length}v#{length}"
      if pbConfirmMessage(_INTL("Would you like to give it a name?"))
        name = pbEnterText(_INTL("What name?"), 0, 30)
        if name.empty?
          export_data(rule, battle.opponent.sample.name, team, curse)
        else
          export_data(rule, name, team, curse)
        end
      else
        export_data(rule, battle.opponent.sample.name, team, curse)
      end
      pbMessage(_INTL("The team has been registered!"))
    end
  end

  def self.delete_team
    load_data
    if @@battle_loader.empty?
      pbMessage(_INTL("There aren't any teams in the Battle Loader!"))
    else
      teams = @@battle_loader.select { |team| team.tags.include?(:removable) }
      teams_names = teams.map { |team| "#{team.rule} #{team.name}" }
      index = pbMessage(_INTL("Which team do you want to delete?"), teams_names, -1)
      if index >= 0 && pbConfirmMessage(_INTL("Do you really want to delete it?"))
        unique_id = teams[index].unique_id
        delete_data(unique_id)
      end
    end
  end

  def self.export_player_team
    load_data
    rules = ["1v1", "2v2", "1v2", "2v1"]
    ret = pbMessage(_INTL("Which battle rule do you want?"), rules, -1)
    if ret >= 0
      name = ""
      if pbConfirmMessage(_INTL("Would you like to give it a name?"))
        name = pbEnterText(_INTL("What name?"), 0, 30)
      end
      add_curses = []
      if pbConfirmMessage(_INTL("Would you like to give it a Curse Effect?"))
        curses_names = get_curses.map(&:to_s)
        curse_index = pbMessage(_INTL("Which Curse Effect do you want?"), curses_names, -1)
        add_curses << get_curses[curse_index] if curse_index >= 0
      end
      if pbConfirmMessage(_INTL("Would you like to give it a Custom Effect?"))
        curses_names = get_custom_effect.keys.map(&:to_s)
        curse_index = pbMessage(_INTL("Which Custom Effect do you want?"), curses_names, -1)
        add_curses << get_custom_effect[curse_index] if curse_index >= 0
      end
      export_data(rules[ret], name, nil, add_curses)
      pbMessage(_INTL("Your team has been exported!"))
    end
  end

  def self.copy_team
    teams_names = @@battle_loader.map { |team| "#{team.rule} #{team.name}" }
    index = pbMessage(_INTL("Which team do you want to copy?"), teams_names, -1)
    if index >= 0
      team_data = @@battle_loader[index]
      team = team_data.team
      TA.set(:team, team)
      check_legality
      $Trainer.party = team.flatten.map { |pkmn| pkmn.clone_pkmn(true, true) }
      pbMessage(_INTL("Copied the party of {1}.", team_data.name))
    end
  end

  def self.battle_choose_from_list(teams, force_rule = false, record = true)
    teams_names = teams.map { |team| "#{team.rule} #{team.name}" << ($Trainer.battle_loader_teams.include?(team.unique_id) ? " V" : " ") }
    index = pbMessage(_INTL("Which team do you want to challenge?"), teams_names, -1)
    if index >= 0
      team = teams[index]
      battle_with_team(team, force_rule, record)
    end
  end

  def self.battle_with_team(team_or_party, force_rule = false, record = false)
    if team_or_party.is_a?(Array)
      team_data = ["1v1", "", team_or_party, ""]
      team = TeamData.new(rule: team_data[0], name: team_data[1], team: team_data[2], unique_id: team_data[3], curses: team_data[4] || [], tags: team_data[5] || [])
    else
      team = team_or_party
    end
    if team.team.pure? && force_rule
      rules = ["1v1", "2v2", "1v2", "2v1"]
      ret = pbMessage(_INTL("Which battle rule do you want to use?"), rules, -1)
      if ret >= 0
        start_battle(team, rules[ret], record)
      else
        start_battle(team, nil, record)
      end
    else
      start_battle(team, nil, record)
    end
  end

  def self.battle
    load_data
    if @@battle_loader.empty?
      pbMessage(_INTL("There aren't any teams in the Battle Loader!"))
    else
      battle_mode = [_INTL("All Teams"), _INTL("Random Team"), _INTL("Random Pokémon Team"), _INTL("Former Champion Team"), _INTL("Mirror Team"), _INTL("Achievement Challenge"), _INTL("Cancel")]
      battle_mode.insert(6, _INTL("Copy Team")) if $DEBUG
      loop do
        mode_chosen = pbMessage(_INTL("What do you want to do?"), battle_mode, -1)
        case mode_chosen
        when -1, 7 # Cancel
          break
        when 6 # Copy Team
          break unless $DEBUG
          copy_team
        when 5 # Achievement Challenge
          unless $Trainer&.checkBadge(8) || $DEBUG
            pbMessage(_INTL("You can't take the Achievement Challenge, because you don't have 8 badges!"))
            break
          end
          challenge_mode = [_INTL("Type"), _INTL("Tribe"), _INTL("Cancel")]
          loop do
            challenge_chosen = pbMessage(_INTL("Which do you want to challenge?"), challenge_mode, -1)
            case challenge_chosen
            when -1, 2
              break
            when 0 # Type
              teams = @@battle_loader.select { |team| team.tags.include?(:type) }
            when 1 # Tribe
              teams = @@battle_loader.select { |team| team.tags.include?(:tribe) }
            end
            battle_choose_from_list(teams, false, true)
          end
        when 4 # Mirror Team
          battle_with_team($Trainer.party, true, false)
        when 3 # Former Champion Team
          unless $Trainer&.checkBadge(6) || $DEBUG
            pbMessage(_INTL("You can't challenge Former Champion Team, because you don't have 6 badges!"))
            break
          end
          teams = @@battle_loader.select { |team| team.tags.include?(:group) }
          battle_choose_from_list(teams, false, true)
        when 2 # Random Pokémon Team
          PokemonDataBase.create_mass
          battle_with_team(get_all_pkmn.sample(6), true, false)
          PokemonDataBase.create_mass
        when 1 # Random Team
          battle_with_team(@@battle_loader.sample, true, false)
        when 0 # All Teams
          teams = @@battle_loader.select { |team| team.tags.include?(:text) }
          battle_choose_from_list(teams, true, true)
        end
      end
    end
  end

  def self.open_battle_loader
    unless $Trainer.has_pokemon?
      pbMessage(_INTL("You can't start a battle now because you don't have any Pokémon!"))
      return
    end
    choice = [_INTL("Battle"), _INTL("Export Team"), _INTL("Delete Team"), _INTL("Check Stats"), _INTL("Check Recorded Teams"), _INTL("Cancel")]
    loop do
      choose = pbMessage(_INTL("What do you want to do?"), choice, -1)
      case choose
      when -1, 5 # Cancel
        break
      when 4 # Check Recorded Teams
        GymLeaderRematch.check_recorded_teams
      when 3 # Check Stats
        pbMessage(_INTL("Your Victory count is {1}!\nYour Defeat count is {2}!", TA.get(:battle_victory, 0), TA.get(:battle_defeat, 0)))
      when 2 # Delete Team
        delete_team
      when 1 # Export Team
        export_player_team
      when 0 # Battle
        battle
      end
    end
  end

  def self.get_custom_effect
    { :CUSTOM_INFINITE_SCREEN => _INTL("The Screen Effects will never end during this battle!"), }
  end

  def self.export_team # Screen Capture
    load_data
    export_data("1v1")
    pbMessage(_INTL("Your team has been exported!"))
  end

  def self.get_all_teams
    load_data
    @@battle_loader
  end

  def self.get_all_pkmn
    load_data
    @@all_pkmn
  end

  def self.each_pokemon
    TA.get(:team).flatten.each do |pokemon|
      yield pokemon, _INTL("the Battle Loader")
    end
  end

  def self.check_legality
    method_object = method(:each_pokemon)
    removeIllegalElementsFromAllPokemon(nil, method_object)
  end

  INVALID_CURSE = %i[CURSE_DELEVELED CURSE_BOOSTED_ELECTRIC CURSE_FIGHT_EXTENDED CURSE_NO_MERCY CURSE_SUPER_ITEMS
                     CURSE_NO_MERCY_2 CURSE_AVATAR_GUARD CURSE_EXTRA_TYPES CURSE_SAND_ABILITIES CURSE_EXTRA_MOVES
                     CURSE_EXTRA_ITEMS CURSE_NO_MERCY_3 CURSE_NO_MERCY_4]

  @@available_curses = []
  def self.get_curses
    if @@available_curses.empty?
      GameData::Policy::DATA.each_key do |policy|
        next if INVALID_CURSE.include?(policy)
        next unless policy.to_s.start_with?("CURSE_")
        @@available_curses.push(policy)
      end
    end
    @@available_curses
  end

  def self.get_random_curse
    get_curses.sample
  end

  def self.get_random_trainer_data
    TA.set(:name,  [BOY_NAMES, GIRL_NAMES].sample.sample)
    TA.set(:name1, [BOY_NAMES, GIRL_NAMES].sample.sample)
    TA.set(:name2, [BOY_NAMES, GIRL_NAMES].sample.sample)
    TA.set(:name3, [BOY_NAMES, GIRL_NAMES].sample.sample)
    trainer = GameData::Trainer.values.sample
    return trainer
  end

  def self.start_battle(team, force_rule = nil, record = true)
    INVALID_CURSE.each { |curse| team.curses.delete(curse) }
    team.curses << get_random_curse if team.curses.empty? && team.tags.include?(:random_curse)
    TA.set(:battle_loader, true)
    TA.set(:curses, team.curses)
    TA.set(:team, team.team)
    check_legality
    begin
      if team.team.pure?
        TA.set(:single, true)
        setBattleRule(force_rule || team.rule)
        trainer = get_random_trainer_data
        #pbTrainerBattle(:LEADER_Lambert, "Lambert", nil, false, 0, true)
        win = pbTrainerBattle(trainer.trainer_type, trainer.real_name, nil, false, 0, true)
      elsif team.team.size == 2
        TA.set(:double, true)
        trainer1 = get_random_trainer_data
        trainer2 = get_random_trainer_data
        TA.set(:team1, team.team[0])
        TA.set(:team2, team.team[1])
        win = pbDoubleTrainerBattle(trainer1.trainer_type, trainer1.real_name, 0, nil, trainer2.trainer_type, trainer2.real_name, 0, nil, true)
      elsif team.team.size == 3
        TA.set(:triple, true)
        TA.set(:team1, team.team[0])
        TA.set(:team2, team.team[1])
        TA.set(:team3, team.team[2])
        trainer1 = get_random_trainer_data
        trainer2 = get_random_trainer_data
        trainer3 = get_random_trainer_data
        win = pbTripleTrainerBattle(trainer1.trainer_type, trainer1.real_name, 0, nil, trainer2.trainer_type, trainer2.real_name, 0, nil, trainer3.trainer_type, trainer3.real_name, 0, nil, true)
      end

      if win
        TA.increase(:battle_victory)
        battle_loader_teams = $Trainer.battle_loader_teams
        battle_loader_teams << team.unique_id if record && !team.unique_id.empty? && !battle_loader_teams.include?(team.unique_id)
      else
        TA.increase(:battle_defeat)
      end
    rescue
      start_battle(team, force_rule)
    ensure
      TA.set(:battle_loader, false)
      TA.set(:single, false)
      TA.set(:double, false)
      TA.set(:triple, false)
      TA.set(:team, nil)
      TA.set(:team1, nil)
      TA.set(:team2, nil)
      TA.set(:team3, nil)
    end
  end
end