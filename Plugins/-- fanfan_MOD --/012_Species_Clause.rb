def find_duplicate_species
  counts = Hash.new(0)
  duplicates = []
  
  $Trainer.party.each do |pkmn|
    counts[pkmn.species] += 1
    duplicates << pkmn.unique_id if counts[pkmn.species] > 1
  end
  
  duplicates
end