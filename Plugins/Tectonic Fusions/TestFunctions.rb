def giveTestFusion() # will crash the game when battle start, don't use it
  fused_species = GameData::FusedSpecies.new(:BULBASAUR, :SQUIRTLE)
  mon = Pokemon.new(fused_species.id, 50)
  mon.ability_index = 0
  pbAddToPartySilent(mon)
end