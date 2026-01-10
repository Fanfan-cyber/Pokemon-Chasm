# Boosted Sun
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_SUN,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("The battle begins with sunshine. The effects of sunshine are doubled.")
        )

        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Sunshine)
        next curses_array
    }
)

PokeBattle_Battle::EndOfTurnCurseEffect.add(:CURSE_BOOSTED_SUN,
    proc { |curse_policy, battle|
        battle.pbStartWeather(nil, :Sunshine) unless battle.sunny? || battle.primevalWeatherPresent?
    }
)

# Boosted Rain
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_RAIN,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("The battle begins with rainstorm. The effects of rainstorm are doubled.")
        )
        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Rainstorm)
        next curses_array
    }
)

PokeBattle_Battle::EndOfTurnCurseEffect.add(:CURSE_BOOSTED_RAIN,
    proc { |curse_policy, battle|
        battle.pbStartWeather(nil, :Rainstorm) unless battle.rainy? || battle.primevalWeatherPresent?
    }
)

# BOOSTED HAIL
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_HAIL,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("The battle begins with hail. The effects of hail are doubled.")
        )
        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Hail)
        next curses_array
    }
)

PokeBattle_Battle::EndOfTurnCurseEffect.add(:CURSE_BOOSTED_HAIL,
    proc { |curse_policy, battle|
        battle.pbStartWeather(nil, :Hail) unless battle.icy? || battle.primevalWeatherPresent?
    }
)

# BOOSTED SAND
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_SAND,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("A Sky Scoured of Star and Sun"),
            _INTL("The battle begins with sandstorm. The effects of sandstorm are doubled.")
        )
        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Sandstorm)
        next curses_array
    }
)

PokeBattle_Battle::EndOfTurnCurseEffect.add(:CURSE_BOOSTED_SAND,
    proc { |curse_policy, battle|
        battle.pbStartWeather(nil, :Sandstorm) unless battle.sandy? || battle.primevalWeatherPresent?
    }
)

# BOOSTED ECLIPSE
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_ECLIPSE,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("The battle begins with eclipse. The effects of eclipse are doubled.")
        )
        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Eclipse)
        next curses_array
    }
)

PokeBattle_Battle::EndOfTurnCurseEffect.add(:CURSE_BOOSTED_ECLIPSE,
    proc { |curse_policy, battle|
        battle.pbStartWeather(nil, :Eclipse) unless battle.eclipsed? || battle.primevalWeatherPresent?
    }
)

# BOOSTED MOONGLOW
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_MOONGLOW,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("The battle begins with moonglow. The effects of moonglow are doubled.")
        )
        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Moonglow)
        next curses_array
    }
)

PokeBattle_Battle::EndOfTurnCurseEffect.add(:CURSE_BOOSTED_MOONGLOW,
    proc { |curse_policy, battle|
        battle.pbStartWeather(nil, :Moonglow) unless battle.moonGlowing? || battle.primevalWeatherPresent?
    }
)