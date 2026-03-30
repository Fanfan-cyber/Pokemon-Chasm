PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_TRAUMATIZING,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("Lowered Stat Steps of your Pokémon will last the whole battle!")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)