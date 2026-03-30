BattleHandlers::CertainSwitchingUserItem.add(:SHEDSHELL,
    proc { |item, switcher, _battle, trappingProc|
        if trappingProc
            battle.pbDisplay(_INTL("{1} can slip free with its {2}!", switcher.pbThis, item.name))
        end
        next true
    }
)
