module PokemonDataBase
  PKMN_DATA_AMOUNT  = 30
  LOWEST_PKMN_BST   = 400
  LOWEST_MOVE_POWER = 65

  @@pkmn_data = []

  def self.get_pkmn_data_base
    @@pkmn_data
  end

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
end