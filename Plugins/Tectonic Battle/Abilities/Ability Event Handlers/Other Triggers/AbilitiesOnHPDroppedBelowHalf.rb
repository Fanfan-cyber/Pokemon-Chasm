BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:EMERGENCYEXIT,
    proc { |ability, battler, battle|
        next false if battler.fainted?
        next false if battle.pbAllFainted?(battler.idxOpposingSide)
        next battle.triggeredSwitchOut(battler.index, ability: ability)
    }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.copy(:EMERGENCYEXIT, :WIMPOUT)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:ANCESTRALSUMMONS,
    proc { |ability, battler, battle|
        next false if battler.fainted?
        next false if battle.pbAllFainted?(battler.idxOpposingSide)
        next battle.triggeredSwitchOut(battler.index, ability: ability, effect: true)
    }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:BERSERK,
  proc { |ability, battler, _battle|
      battler.pbRaiseMultipleStatSteps(ATTACKING_STATS_2, battler, ability: ability)
      next false
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:ADRENALINERUSH,
  proc { |ability, battler, _battle|
      battler.tryRaiseStat(:SPEED, battler, increment: 4, ability: ability)
      next false
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:BOULDERNEST,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      if battler.pbOpposingSide.effectActive?(:StealthRock)
          battle.pbDisplay(_INTL("But there were already pointed stones floating around {1}!",
                battler.pbOpposingTeam(true)))
      else
          battle.pbAnimation(:STEALTHROCK, battler, nil)
          battler.pbOpposingSide.applyEffect(:StealthRock)
      end
      battle.pbHideAbilitySplash(battler)
      next false
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:REAWAKENEDPOWER,
  proc { |ability, battler, _battle|
      battler.pbMaximizeStatStep(:SPECIAL_ATTACK, battler, self, ability: ability)
      next false
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:PRIMEVALDISGUISE,
    proc { |ability, battler, battle|
        next unless battler.illusion?
        battle.pbShowAbilitySplash(battler,ability)
        battler.disableEffect(:Illusion)
        battle.scene.pbChangePokemon(battler, battler.pokemon)
        battle.pbSetSeen(battler)
        battle.pbHideAbilitySplash(battler)
        next false
    }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:BATTLEHARDENED,
  proc { |ability, battler, _battle|
      battler.pbRaiseMultipleStatSteps([:DEFENSE, 3, :SPECIAL_DEFENSE, 3], battler, ability: ability)
      next false
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:WIRECUTTER,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      if battler.pbOpposingSide.effectActive?(:LiveWire)
          battle.pbDisplay(_INTL("But a live wire already sits near {1}!",
                battler.pbOpposingTeam(true)))
      else
          battler.pbOpposingSide.applyEffect(:LiveWire)
      end
      battle.pbHideAbilitySplash(battler)
      next false
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:VOIDWARRANTY,
  proc { |ability, battler, battle, endOfBattle|
      next if battler.fainted?
      next unless battler.species == :ROTOM
      
      formChoices = []
      choiceNames = []

      formIndex = -1
      loop do
        formIndex += 1
        data = GameData::Species.get_species_form(:ROTOM,formIndex)
        break if data.nil? || data.form != formIndex
        next if formIndex == battler.form
        formChoices.push(formIndex)
        choiceNames.push(data.form_name)
        echoln("Adding form #{formIndex}")
      end

      next unless formChoices.length > 0
      
      battle.pbShowAbilitySplash(battler, ability)
      if battle.autoTesting
        choiceIndex = rand(formChoices.length)
      elsif !battler.pbOwnedByPlayer? # Trainer AI
        choiceIndex = 0
      else
        choiceIndex = battle.scene.pbShowCommands(_INTL("Which form should {1} take?",battler.name),choiceNames,0)
      end
      battler.pbChangeForm(formChoices[choiceIndex], _INTL("{1} takes on a new machine!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:CASHFLOW,
  proc { |ability, battler, battle|
      next if battler.fainted?
      next unless battler.pbOwnSide.effectActive?(:PayDay)
      next unless battler.canHeal?(true)
      maxCoinsCanHealFrom = battler.maxOverhealingPossible * CASHOUT_HEALING_DIVISOR
      coinsToConsume = [battler.pbOwnSide.countEffect(:PayDay), maxCoinsCanHealFrom].min
      healingAmt = coinsToConsume / CASHOUT_HEALING_DIVISOR
      battle.pbShowAbilitySplash(battler, ability)
      healingMessage = _INTL("{1} gobbles up the scattered coins!", battler.pbThis)
      battler.pbRecoverHP(healingAmt, true, true, true, healingMessage, canOverheal: true)
      battler.pbOwnSide.effects[:PayDay] -= coinsToConsume
      battle.pbHideAbilitySplash(battler)
      next false
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:BLOODOFMALICE,
  proc { |ability, battler, battle|
      next if battler.fainted?
      next unless battler.canHeal?
      next if battler.battle_tracker_get(:blood_of_malice)

=begin
      target_foe = nil
      battler.eachOpposing do |b|
        next if b.hp <= battler.hp 
        target_foe = b if target_foe.nil? || b.hp > target_foe.hp
      end
      next if target_foe.nil?

      battler_hp = battler.hp
      foe_hp = target_foe.hp
      battler.hp = [foe_hp, battler.totalhp].min
      target_foe.hp = [battler_hp, target_foe.totalhp].min
=end

      target_foe = nil
      foe_hp_ratio = nil
      battler_hp_ratio = battler.hp.to_f / battler.totalhp
      battler.eachOpposing do |b|
        current_foe_ratio = b.hp.to_f / b.totalhp
        next if current_foe_ratio  <= battler_hp_ratio
        if foe_hp_ratio.nil? || current_foe_ratio  > foe_hp_ratio
          target_foe = b 
          foe_hp_ratio = current_foe_ratio 
        end
      end
      next if target_foe.nil?
      battler.battle_tracker_set(:blood_of_malice, true)

      battler.hp = (battler.totalhp * foe_hp_ratio).ceil
      target_foe.hp = (target_foe.totalhp * battler_hp_ratio).ceil

      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} swapped HP with {2}!", battler.pbThis, target_foe.pbThis(true)))
      battle.pbAnimation(:TRANSFORM, battler, target_foe)
      battler.refreshDataBox
      target_foe.refreshDataBox
      battle.pbHideAbilitySplash(battler)
      target_foe.pbItemHPHealCheck
      next false
  }
)