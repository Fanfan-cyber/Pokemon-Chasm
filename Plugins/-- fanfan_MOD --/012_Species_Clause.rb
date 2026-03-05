def find_duplicate_species
  counts = Hash.new(0)
  duplicates = []

  $Trainer.party.each do |pkmn|
    counts[pkmn.species] += 1
    duplicates << pkmn.unique_id if counts[pkmn.species] > 1
  end

  duplicates
end

def find_extra_legendary_species
  find_legendary = false
  extra_legendary = []

  $Trainer.party.each do |pkmn|
    next unless pkmn.species_data.isLegendary?
    extra_legendary << pkmn.unique_id if find_legendary
    find_legendary = true
  end

  extra_legendary
end