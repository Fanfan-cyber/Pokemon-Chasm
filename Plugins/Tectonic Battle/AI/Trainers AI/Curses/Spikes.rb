PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_SPIKES,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("Gored Upon the Horns of the Dilemma - Boredom or the Path of Thorns?"),
            #_INTL("Your side gains spikes each turn, except if removed that turn."),
            _INTL("Your side gains spikes each turn. Opposing Switch Healing effect boosts by 50%."),
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)

=begin
PokeBattle_Battle::EndOfTurnCurseEffect.add(:CURSE_SPIKES,
    proc { |curse_policy, battle|
        if battle.sides[0].effectActive?(:SpikesRemovedThisTurn)
            battle.pbDisplay(_INTL("You were spared from spikes this turn!"))
        else
            battle.sides[0].incrementEffect(:Spikes)
        end
    }
)
=end

PokeBattle_Battle::BeginningOfTurnCurseEffect.add(:CURSE_SPIKES,
    proc { |curse_policy, battle|
        battle.sides[0].incrementEffect(:Spikes)
    }
)