PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_EXTRA_ITEMS,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("forge a blade\nfrom gold/\npluck out its\nsilhouette and/\nwield the\nshadow too!"),
            _INTL("Enemy Pokémon all have an extra item. \nYour Pokémon's items don't have any effects for 3 turns!")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)

PokeBattle_Battle::BattlerEnterCurseEffect.add(:CURSE_EXTRA_ITEMS,
    proc { |_curse_policy, battler, _battle|
        next if battler.opposes?
        battler.applyEffect(:Stressed, 3)
    }
)