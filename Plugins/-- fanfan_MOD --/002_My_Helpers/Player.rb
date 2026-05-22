class Player
  attr_reader :ta

  def check_ta
    @ta ||= TA::TA_Vars.new
  end

  def get_ta(var, default = nil)
    check_ta.get(var, default)
  end

  def set_ta(var, value)
    check_ta.set(var, value)
  end

  def increase_ta(var, increment = 1)
    check_ta.increase(var, increment)
  end

  def is_player
    @is_player ||= true
  end

  def set_max_money
    @money = Settings::MAX_MONEY
  end

  def gift_code
    @gift_code ||= { :pkmn => [], :item => [] }
  end

  def debug_code
    @debug_code ||= []
  end

  def team_switcher
    @team_switcher ||= []
  end

  def ability_recorder
    @ability_recorder ||= []
  end

  def battle_loader_teams
    @battle_loader_teams ||= []
  end

  def species_selected_abilities
    @species_selected_abilities ||= {}
  end

  def record_selected_abilities(species, form, abilities)
    species_selected_abilities[[species, form]] = abilities
  end

  def set_species_abilities(species, form)
    spec_abils = SPECIES_ABILITY_DATA[[species, form]]
    unchangeable = false
    if spec_abils
      selectable_abils = spec_abils[:changeable]
      unchangeable = true if selectable_abils.length <= 2
    else
      unchangeable = true
    end
    if unchangeable
      pbMessage(_INTL("The Pokémon's species abilities can't be changed!"))
      return
    end

    pbMessage(_INTL("You can change a Pokémon's species abilities here!"))

    pairs = []
    selectable_abils.each_with_index do |item1, i|
      selectable_abils.each_with_index do |item2, j|
        pairs << [item1, item2] if j > i
      end
    end
    named_pairs = pairs.map do |pair|
      name1 = GameData::Ability.get(pair[0]).name
      name2 = GameData::Ability.get(pair[1]).name
      "#{name1}, #{name2}"
    end

    choose = pbMessage(_INTL("Which do you want to choose?"), named_pairs, -1)
    return if choose == -1
    if $Trainer.money < 5000
      pbMessage(_INTL("You don't have enough money to change the Pokémon's species abilities!"))
      return
    end
    if pbConfirmMessage(_INTL("It costs $5000, are you sure?"))
      $Trainer.money -= 5000
      pbMessage(_INTL("The Pokémon's species abilities changed!"))
      abilities = pairs[choose]
      record_selected_abilities(species, form, abilities)
    end
  end
end