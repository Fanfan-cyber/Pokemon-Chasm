def moveLearningScreen(pkmn,moves,addFirstMove=false)
	return [] if !pkmn || pkmn.egg?

	if !teamEditingAllowed?()
		showNoTeamEditingMessage()
		return
	end

	moves.sort! { |move_a, move_b|
		moveDataA = GameData::Move.get(move_a)
		moveDataB = GameData::Move.get(move_b)

		if moveDataA.base_damage == moveDataB.base_damage
			next GameData::Type.get(moveDataA.type).id_number <=> GameData::Type.get(moveDataB.type).id_number
		else
			next moveDataB.base_damage <=> moveDataA.base_damage
		end
	}
	
	retval = true
	pbFadeOutIn {
	  scene = MoveLearner_Scene.new
	  screen = MoveLearnerScreen.new(scene)
	  retval = screen.pbStartScreen(pkmn,moves,addFirstMove)
	}
	return retval
end

def eachPokemonInPartyOrStorage()
	$Trainer.party.each do |pkmn|
		yield pkmn
	end

	for i in 0...Settings::NUM_STORAGE_BOXES
		for j in 0...$PokemonStorage.maxPokemon(i)
			pkmn = $PokemonStorage[i, j]
			yield pkmn if pkmn
		end
	end
end