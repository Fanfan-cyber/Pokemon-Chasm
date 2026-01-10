class PokeBattle_Battle
    #=============================================================================
    # Running from battle
    #=============================================================================
    def pbCanRun?(idxBattler)
        return false if trainerBattle? || bossBattle? # Boss battle
        battler = @battlers[idxBattler]
        return false if !@canRun && !battler.opposes?
        return true if battler.pbHasType?(:GHOST)
        battler.eachActiveAbility do |ability|
            return true if BattleHandlers.triggerRunFromBattleAbility(ability, battler)
        end   
        battler.eachActiveItem do |item|
            return true if BattleHandlers.triggerRunFromBattleItem(item, battler)
        end                       
        battler.eachEffectAllLocations(true) do |_effect, _value, data|
            return false if data.trapping?
        end
        return true
    end

    # Return values:
    # -1: Failed fleeing
    #  0: Wasn't possible to attempt fleeing, continue choosing action for the round
    #  1: Succeeded at fleeing, battle will end
    # duringBattle is true for replacing a fainted Pokémon during the End Of Round
    # phase, and false for choosing the Run command.
    def pbRun(idxBattler, duringBattle = false)
        battler = @battlers[idxBattler]
        if battler.opposes?
            return 0 if trainerBattle?
            @choices[idxBattler][0] = :Run
            @choices[idxBattler][1] = 0
            @choices[idxBattler][2] = nil
            return -1
        end
        # Fleeing from trainer battles or boss battles
        bossBattle = bossBattle?
        if trainerBattle? || bossBattle
            if @is_replayed
                pbSEPlay("Battle flee")
                if @internalBattle
                    @decision = 2
                else
                    @decision = 3
                end
                return 1
            elsif debugControl
                if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
                    @decision = 1
                    return 1
                elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
                    @decision = 2
                    return 1
                end
            elsif bossBattle
                boss_run = false
                max_level = 0
                battler.eachOpposing do |b|
                    next if b.level <= max_level
                    max_level = b.level
                end
                boss_run = true if getLevelCap + 5 >= max_level
                if boss_run
                    if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
                        @decision = 1
                        return 1
                    elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
                        @decision = 2
                        return 1
                    end
                else
                    if pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
                        @decision = 2
                        return 1
                    end
                end
            elsif pbDisplayConfirmSerious(_INTL("Would you like to forfeit the match and quit now?"))
                pbSEPlay("Battle flee")
                if @internalBattle
                    @decision = 2
                else
                    @decision = 3
                end
                return 1
            end
            return 0
        end
        # Fleeing from wild battles
        if debugControl
            pbSEPlay("Battle flee")
            pbDisplayPaused(_INTL("You got away safely!"))
            @decision = 3
            return 1
        end
        unless @canRun
            pbDisplayPaused(_INTL("You can't escape!"))
            return 0
        end

        pbSEPlay("Battle flee")
        pbDisplayPaused(_INTL("You got away safely!"))
        @decision = 3
        return 1
    end
end
