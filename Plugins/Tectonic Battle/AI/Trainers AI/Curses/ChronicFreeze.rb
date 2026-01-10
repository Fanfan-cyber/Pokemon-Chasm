PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_NO_MOVING_CYCLICAL,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("Move, call, step, stop.\nRend, rive, dare, halt.\nClaw, cull, dive, hold.\nFend, flee, fail, fall."),
            #_INTL("The battle begins with hail. Your Pokémon cannot use moves on every 4th turn.")
            _INTL("The battle begins with hail, the hail protects foes. Your Pokémon becomes an Ice Sculpture on every 4th turn.")
        )
        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Hail)
        next curses_array
    }
)

PokeBattle_Battle::BeginningOfTurnCurseEffect.add(:CURSE_NO_MOVING_CYCLICAL,
    proc { |curse_policy, battle|
        if battle.turnCount % 4 == 0
            battle.eachSameSideBattler do |b|
                battle.pbAnimation(:SHEERCOLD, b, b)
                b.applyEffect(:IceSculpture)
                #b.applyFrostbite if b.canFrostbite?(nil, false)
                b.applyFrostbite unless b.frostbitten?
            end
            battle.sides[0].applyEffect(:IceSculptureTurns, 4)
        elsif battle.turnCount % 4 == 3
            battle.pbDisplay(_INTL("The freeze will arrive next turn."))
        end
    }
)

PokeBattle_Battle::EndOfTurnCurseEffect.add(:CURSE_NO_MOVING_CYCLICAL,
    proc { |curse_policy, battle|
        battle.pbStartWeather(nil, :Hail) unless battle.icy? || battle.primevalWeatherPresent?
    }
)