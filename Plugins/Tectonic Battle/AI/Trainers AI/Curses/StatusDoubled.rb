PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_STATUS_DOUBLED,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("Pyres raised\nHere we meet\nSpirits razed\nReduced to meat"),
            _INTL("When enemy Pokémon faint, your Pokémon will be punished!\nFoes ignore the Status Clause!")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)

PokeBattle_Battle::BattlerFaintedCurseEffect.add(:CURSE_STATUS_DOUBLED,
    proc { |_curse_policy, battler, battle|
        next unless battler.opposes?
        statuses = []
        statuses << :POISON if battler.pbHasType?(:POISON)
        statuses << :BURN if battler.pbHasType?(:FIRE)

        statuses << :NUMB if battler.pbHasType?(:ELECTRIC)
        statuses << :FROSTBITE if battler.pbHasType?(:ICE)
        statuses << :WATERLOG if battler.pbHasType?(:WATER)

        next if statuses.empty?
        battler.eachOpposing do |b|
            can_statuses = []
            statuses.each do |s|
                can_statuses << s if b.pbCanInflictStatus?(s, nil, false)
            end
            next if can_statuses.empty?
            battle.pbDisplay(_INTL("{1} will be punished!", b.pbThis))
            b.pbInflictStatus(can_statuses.sample)
        end
    }
)