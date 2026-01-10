#########################################
# Weather Abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:SANDBURST,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        score = pbBattleWeatherAbility(ability, :Sandstorm, target, battle, false, true, aiCheck)
        next score * -1 if aiCheck
    }
)

BattleHandlers::TargetAbilityOnHit.add(:INNERHEAT,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        score = pbBattleWeatherAbility(ability, :Sunshine, target, battle, false, true, aiCheck)
        next score * -1 if aiCheck
    }
)

BattleHandlers::TargetAbilityOnHit.copy(:INNERHEAT, :SUMMERSZENITH)

BattleHandlers::TargetAbilityOnHit.add(:STORMBRINGER,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        score = pbBattleWeatherAbility(ability, :Rainstorm, target, battle, false, true, aiCheck)
        next score * -1 if aiCheck
    }
)

BattleHandlers::TargetAbilityOnHit.copy(:STORMBRINGER, :LEVIATHANARIA)

BattleHandlers::TargetAbilityOnHit.add(:FROSTSCATTER,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        score = pbBattleWeatherAbility(ability, :Hail, target, battle, false, true, aiCheck)
        next score * -1 if aiCheck
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SUNEATER,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        score = pbBattleWeatherAbility(ability, :Eclipse, target, battle, false, true, aiCheck)
        next score * -1 if aiCheck
    }
)

BattleHandlers::TargetAbilityOnHit.add(:LUNARIOT,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        score = pbBattleWeatherAbility(ability, :Moonglow, target, battle, false, true, aiCheck)
        next score * -1 if aiCheck
    }
)

#########################################
# Other battle effects
#########################################
BattleHandlers::TargetAbilityOnHit.add(:GRAVITYWELL,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        if aiCheck
            next getGravityEffectScore(user, 4)
        else
            battle.pbShowAbilitySplash(target, ability)
            battle.pbAnimation(:GRAVITY, target, nil, 0)
            battle.field.applyEffect(:Gravity, applyEffectDurationModifiers(4, target))
            battle.pbHideAbilitySplash(target)
        end
    }
)

#########################################
# Stat change abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:GOOEY,
  proc { |ability, user, target, move, _battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        if aiCheck
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatDownEffectScore([:ATTACK,1,:SPEED,1], target, user, fakeStepModifier: i)
            end
            next ret
        end
        user.pbLowerMultipleStatSteps([:ATTACK,1,:SPEED,1], target, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:SICKENING,
  proc { |ability, user, target, move, _battle, aiCheck, aiNumHits|
        next unless move.specialMove?
        if aiCheck
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatDownEffectScore([:SPECIAL_ATTACK,1,:SPEED,1], target, user, fakeStepModifier: i)
            end
            next ret
        end
        user.pbLowerMultipleStatSteps([:SPECIAL_ATTACK,1,:SPEED,1], target, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:TANGLINGHAIR,
    proc { |ability, user, target, move, _battle, aiCheck, aiNumHits|
          next unless move.physicalMove?
          if aiCheck
              ret = 0
              aiNumHits.times do |i|
                  ret -= getMultiStatDownEffectScore([:SPEED,3], target, user, fakeStepModifier: i)
              end
              next ret
          end
          user.tryLowerStat(:SPEED, target, ability: ability, increment: 3)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:COTTONDOWN,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        if aiCheck
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatDownEffectScore([:SPEED,2], target, user, fakeStepModifier: i)
            end
            next ret
        else
            battle.pbShowAbilitySplash(target, ability)
            target.eachOpposing do |b|
                b.tryLowerStat(:SPEED, target, increment: 2)
            end
            target.eachAlly do |b|
                b.tryLowerStat(:SPEED, target, increment: 2)
            end
            battle.pbHideAbilitySplash(target)
        end
    }
)

BattleHandlers::TargetAbilityOnHit.add(:STAMINA,
  proc { |ability, user, target, move, _battle, aiCheck, aiNumHits|
        if aiCheck
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([:DEFENSE,1], user, target, fakeStepModifier: i, evaluateThreat: false)
            end
            next ret
        end
        target.tryRaiseStat(:DEFENSE, target, ability: ability, increment: 1)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GRIT,
    proc { |ability, user, target, move, _battle, aiCheck, aiNumHits|
        if aiCheck
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([:SPECIAL_DEFENSE,1], user, target, fakeStepModifier: i, evaluateThreat: false)
            end
            next ret
        end
        target.tryRaiseStat(:SPECIAL_DEFENSE, target, ability: ability, increment: 1)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKARMOR,
  proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        next if target.fainted?
        if aiCheck
            ret = getMultiStatDownEffectScore([:DEFENSE, 1], target, target)
            ret -= getMultiStatUpEffectScore([:SPEED, 2], target, target, evaluateThreat: false)
            next ret
        else
            battle.pbShowAbilitySplash(target, ability)
            target.tryLowerStat(:DEFENSE, target)
            target.tryRaiseStat(:SPEED, target, increment: 2)
            battle.pbHideAbilitySplash(target)
        end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:IMPETUOUS,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.specialMove?
        next if target.fainted?
        if aiCheck
            ret = getMultiStatDownEffectScore([:SPECIAL_DEFENSE, 1], target, target)
            ret -= getMultiStatUpEffectScore([:SPEED, 2], target, target, evaluateThreat: false)
            next ret
        else
            battle.pbShowAbilitySplash(target, ability)
            target.tryLowerStat(:SPECIAL_DEFENSE, target)
            target.tryRaiseStat(:SPEED, target, increment: 2)
            battle.pbHideAbilitySplash(target)
        end
    }
)

BattleHandlers::TargetAbilityOnHit.add(:STEAMPOWER,
    proc { |ability, user, target, move, _battle, aiCheck, aiNumHits|
        next unless move.calcType == :WATER
        if aiCheck
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([:SPEED,4], user, target, fakeStepModifier: i*4, evaluateThreat: false)
            end
            next ret
        end
        target.tryRaiseStat(:SPEED, target, increment: 4, ability: ability)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FORCEREVERSAL,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        if aiCheck
            expectedTypeMod = battle.battleAI.pbCalcTypeModAI(move.calcType, user, target, move)
            next 0 unless Effectiveness.resistant?(target.damageState.typeMod)
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore(ATTACKING_STATS_2, user, target, fakeStepModifier: i, evaluateThreat: false)
            end
            next ret
        else
            next unless Effectiveness.resistant?(target.damageState.typeMod)
            target.pbRaiseMultipleStatSteps(ATTACKING_STATS_2, target, ability: ability)
        end
    }
)

#########################################
# Damaging abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:IRONBARBS,
  proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        if aiCheck
            next -10 * aiNumHits if user.takesIndirectDamage?
            next 0
        end
        battle.pbShowAbilitySplash(target, ability)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            user.applyFractionalDamage(1.0 / 8.0)
        end
        battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:IRONBARBS, :ROUGHSKIN)

BattleHandlers::TargetAbilityOnHit.add(:FEEDBACK,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if user.fainted?
        next unless move.specialMove?(user)
        if aiCheck
            next -10 * aiNumHits if user.takesIndirectDamage?
            next 0
        end
        battle.pbShowAbilitySplash(target, ability)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            user.applyFractionalDamage(1.0 / 8.0)
        end
        battle.pbHideAbilitySplash(target)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:ARCCONDUCTOR,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless battle.rainy?
        if aiCheck
            next -10 * aiNumHits if user.takesIndirectDamage?
            next 0
        end
        battle.pbShowAbilitySplash(target, ability)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            user.applyFractionalDamage(1.0 / 6.0)
        end
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SPINTENSITY,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless target.steps[:SPEED] > 0
        if aiCheck
            next -5 * target.steps[:SPEED] if user.takesIndirectDamage?
            next 0
        end
        battle.pbShowAbilitySplash(target, ability)
        battle.pbDisplay(_INTL("{1} catches the full force of {2}'s Speed!", user.pbThis, target.pbThis(true)))
        oldStep = target.steps[:SPEED]
        user.applyFractionalDamage(oldStep / 8.0)
        battle.pbCommonAnimation("StatDown", target)
        target.pbResetSpecificStatSteps(:SPEED)
        target.applyFractionalDamage(oldStep / 16.0)
        battle.pbHideAbilitySplash(target)
    }
)

#########################################
# Binding abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:CONSTRICTOR,
  proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        next if target.fainted?
        next if user.effectActive?(:Trapping)
        next if user.effectActive?(:Binding)
        next if target.effectActive?(:SwitchedIn)
        trappingDuration = 3
        trappingDuration *= 2 if target.hasActiveItem?(:GRIPCLAW)
        score = -30
        score *= 2 if target.hasActiveItemAI?(:BINDINGBAND)
        score *= 2 if target.hasActiveItemAI?(:GRIPCLAW)
        next score if aiCheck
        battle.pbShowAbilitySplash(target, ability)
        battle.pbDisplay(_INTL("{1} is being constricted!", user.pbThis))
        user.applyEffect(:Binding, applyEffectDurationModifiers(trappingDuration, target))
        user.applyEffect(:TrappingAbility, :CONSTRICTOR)
        user.pointAt(:TrappingUser, target)
        battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:MAGNETTRAP,
  proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.specialMove?
        next if target.fainted?
        next if user.effectActive?(:Trapping)
        next if user.effectActive?(:Binding)
        next if target.effectActive?(:SwitchedIn)
        trappingDuration = 3
        trappingDuration *= 2 if target.hasActiveItem?(:GRIPCLAW)
        score = -30
        score *= 2 if target.hasActiveItemAI?(:BINDINGBAND)
        score *= 2 if target.hasActiveItemAI?(:GRIPCLAW)
        next score if aiCheck
        battle.pbShowAbilitySplash(target, ability)
        battle.pbDisplay(_INTL("{1} is being magnetized!", user.pbThis))
        user.applyEffect(:Binding, applyEffectDurationModifiers(trappingDuration, target))
        user.applyEffect(:TrappingAbility, :MAGNETTRAP)
        user.pointAt(:TrappingUser, target)
        battle.pbHideAbilitySplash(target)
  }
)

#########################################
# Move usage abilities
#########################################

# TODO: Make the checks here more detailed

BattleHandlers::TargetAbilityOnHit.add(:RELUCTANTBLADE,
  proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        next if target.fainted?
        next -30 * aiNumHits if aiCheck
        battle.forceUseMove(target, :LEAFAGE, user.index, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:COUNTERFLOW,
  proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.specialMove?
        next if target.fainted?
        next -30 * aiNumHits if aiCheck
        battle.forceUseMove(target, :BREACH, user.index, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WIBBLEWOBBLE,
  proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if target.fainted?
        next -40 if aiCheck
        battle.forceUseMove(target, :POWERSPLIT, user.index, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:BOUNCEBACK,
  proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless user.hp > target.hp
        next if target.fainted?
        next -20 if aiCheck
        battle.forceUseMove(target, :PAINSPLIT, user.index, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:FRIGIDREFLECTION,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.specialMove?
        next if target.fainted?
        next -60 if aiCheck
        battle.forceUseMove(target, move.id, user.index, ability: ability)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:HUGGABLE,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if target.fainted?
        next unless move.baseDamage >= 95
        if aiCheck
            score = -5
            score -= getNumbEffectScore(target, user)
            next score
        end
        battle.forceUseMove(target, :NUZZLE, user.index, ability: ability)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:LOUDSLEEPER,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
          next if target.fainted?
          next unless target.asleep?
          next -30 * aiNumHits if aiCheck
          battle.forceUseMove(target, :SNORE, user.index, ability: ability)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SNORER,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
          next if target.fainted?
          next unless target.asleep?
          next -15 * aiNumHits if aiCheck
          battle.forceUseMove(target, :SNORE, user.index, ability: ability, moveUsageEffect: :Snorer)
    }
)

#########################################
# Numb inducing abilities
#########################################
=begin
BattleHandlers::TargetAbilityOnHit.add(:STATIC,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        next if user.numbed?
        if aiCheck
            if user.effectActive?(:PhysNumbWarned) || aiNumHits > 1
                next -(getNumbEffectScore(target, user) * 0.25)
            else
                next -10
            end
        end
        if user.effectActive?(:PhysNumbWarned)
            randomStatusProcTargetAbility(ability, :NUMB, 100, user, target, move, battle, aiCheck, aiNumHits)
            user.disableEffect(:PhysNumbWarned)
        else
            battle.pbShowAbilitySplash(target, ability)
            user.applyEffect(:PhysNumbWarned)
            battle.pbHideAbilitySplash(target)
        end
    }
)
=end

def statusProcTargetAbility(status, ability, user, target, move, battle, aiCheck, aiNumHits)
    return if user.fainted?
    warned_battlers = user.battle_tracker_get(:warned)[ability]
    warned = warned_battlers.include?(target.unique_id) || target.fainted?
    if aiCheck
        if warned || aiNumHits > 1
            method_name = "get#{status.to_s.capitalize}EffectScore"
            score = send(method_name, target, user)
            return -(score * 0.25)
        else
            return -10
        end
    end
    if warned
        randomStatusProcTargetAbility(ability, status, 100, user, target, move, battle, aiCheck, aiNumHits)
    else
        battle.pbShowAbilitySplash(target, ability)
        warned_battlers << target.unique_id
        battle.pbDisplay(_INTL("{1} was warned not to attack {2} again!", user.pbThis, target.pbThis(true)))
        battle.pbHideAbilitySplash(target)
    end
end

BattleHandlers::TargetAbilityOnHit.add(:STATIC,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        next if user.numbed?
        statusProcTargetAbility(:NUMB, ability, user, target, move, battle, aiCheck, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:PETRIFYING,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.specialMove?
        next if user.numbed?
        statusProcTargetAbility(:NUMB, ability, user, target, move, battle, aiCheck, aiNumHits)
    }
)

#########################################
# Poison inducing abilities
#########################################
BattleHandlers::TargetAbilityOnHit.add(:POISONPOINT,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        next if user.poisoned?
        statusProcTargetAbility(:POISON, ability, user, target, move, battle, aiCheck, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:POISONPUNISH,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.specialMove?
        next if user.poisoned?
        statusProcTargetAbility(:POISON, ability, user, target, move, battle, aiCheck, aiNumHits)
    }
)

#########################################
# Burn inducing abilities
#########################################
BattleHandlers::TargetAbilityOnHit.add(:FLAMEBODY,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        next if user.burned?
        statusProcTargetAbility(:BURN, ability, user, target, move, battle, aiCheck, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FIERYSPIRIT,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.specialMove?
        next if user.burned?
        statusProcTargetAbility(:BURN, ability, user, target, move, battle, aiCheck, aiNumHits)
    }
)

#########################################
# Frostbite inducing abilities
#########################################
BattleHandlers::TargetAbilityOnHit.add(:CHILLEDBODY,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        next if user.frostbitten?
        statusProcTargetAbility(:FROSTBITE, ability, user, target, move, battle, aiCheck, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SUDDENCHILL,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.specialMove?
        next if user.frostbitten?
        statusProcTargetAbility(:FROSTBITE, ability, user, target, move, battle, aiCheck, aiNumHits)
    }
)

#########################################
# Leech inducing abilities
#########################################
BattleHandlers::TargetAbilityOnHit.add(:KELPLINK,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        next if user.leeched?
        statusProcTargetAbility(:LEECHED, ability, user, target, move, battle, aiCheck, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:PUNISHER,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.specialMove?
        next if user.leeched?
        statusProcTargetAbility(:LEECHED, ability, user, target, move, battle, aiCheck, aiNumHits)
    }
)

#########################################
# Waterlog inducing abilities
#########################################
BattleHandlers::TargetAbilityOnHit.add(:SOPPING,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        next if user.waterlogged?
        statusProcTargetAbility(:WATERLOG, ability, user, target, move, battle, aiCheck, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:BACKWASH,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.specialMove?
        next if user.waterlogged?
        statusProcTargetAbility(:WATERLOG, ability, user, target, move, battle, aiCheck, aiNumHits)
    }
)

#########################################
# Other punishment random triggers
#########################################
=begin
BattleHandlers::TargetAbilityOnHit.add(:CURSEDTAIL,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if user.fainted?
        next if user.effectActive?(:Curse)
        if aiCheck
            if user.effectActive?(:CurseWarned) || aiNumHits > 1
                next -30
            else
                next -10
            end
        end
        battle.pbShowAbilitySplash(target, ability)
        if user.effectActive?(:CurseWarned)
            user.applyEffect(:Curse)
            user.disableEffect(:CurseWarned)
        else
            user.applyEffect(:CurseWarned)
        end
        battle.pbHideAbilitySplash(target)
    }
)
=end

BattleHandlers::TargetAbilityOnHit.add(:CURSEDTAIL,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if user.fainted?
        next if user.effectActive?(:Curse)
        warned_battlers = user.battle_tracker_get(:warned)[ability]
        warned = warned_battlers.include?(target.unique_id) || target.fainted?
        if aiCheck
            if warned || aiNumHits > 1
                next -30
            else
                next -10
            end
        end
        battle.pbShowAbilitySplash(target, ability)
        if warned
            user.applyEffect(:Curse)
        else
            warned_battlers << target.unique_id
            battle.pbDisplay(_INTL("{1} was warned not to attack {2} again!", user.pbThis, target.pbThis(true)))
        end
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SEALINGBODY,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if user.fainted?
        next if user.effectActive?(:Disable)
        next if move.id == :STRUGGLE
        next -15 if aiCheck
        battle.pbShowAbilitySplash(target, ability)
        user.applyEffect(:Disable, 2) if user.canBeDisabled?(true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:PERISHBODY,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if target.boss?
        next if user.effectActive?(:PerishSong)
        next if target.effectActive?(:PerishSong)
        next -5 if aiCheck
        battle.pbShowAbilitySplash(target, ability)
        target.applyEffect(:PerishSong, 3)
        user.applyEffect(:PerishSong, 3)
        battle.pbHideAbilitySplash(target)
    }
)

#########################################
# Force of Nature Therian abilities
#########################################
MENDING_FEATHER_CHARM_HEALING_FRACTION = 1.0 / 8.0
BattleHandlers::TargetAbilityOnHit.add(:MENDINGFEATHERCHARM,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        if aiCheck
            next -30 * aiNumHits
        end
        target.showMyAbilitySplash(ability)
        target.pbOwnSide.incrementEffect(:FeathersDropped)
        if target.pbOwnSide.effectAtMax?(:FeathersDropped)
            battle.pbAnimation(:REFRESH, target, nil)
            target.pbOwnSide.disableEffect(:FeathersDropped)

            # Main effect
            battle.pbAnimation(:AROMATHERAPY, target, nil)
            battle.pbDisplay(_INTL("{1} heals its party members!", target.pbThis))
            party = battle.pbParty(target.index)
            previousHealthValues = []
		    previousStatusIndices = []
            party.each_with_index do |partyMember, i|
                previousHealthValues.push(partyMember.hp)
			    previousStatusIndices.push(partyMember.getStatusImageIndex)
                next unless partyMember.able?
                battler = battle.pbFindBattler(i, target)
                if battler
                    battler.applyFractionalHealing(MENDING_FEATHER_CHARM_HEALING_FRACTION, anim: false, anyAnim: false, showMessage: false)
                else
                    partyMember.healByFraction(MENDING_FEATHER_CHARM_HEALING_FRACTION)
                end
            end
            showPartyHealing(party,previousHealthValues,previousStatusIndices)

            # Attacker effect
            battle.pbAnimation(:FEATHERDANCE, target, [user])
            user.applyEffect(:FeatherForceSwitch)
        end
        target.hideMyAbilitySplash
    }
)

BattleHandlers::TargetAbilityOnHit.add(:RAGINGSCALECHARM,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        if aiCheck
            next -30 * aiNumHits
        end
        target.showMyAbilitySplash(ability)
        target.pbOwnSide.incrementEffect(:ScalesDropped)
        if target.pbOwnSide.effectAtMax?(:ScalesDropped)
            battle.pbAnimation(:REFRESH, target, nil)
            target.pbOwnSide.disableEffect(:ScalesDropped)

            # Main effect
            unless user.pbOwnSide.effectActive?(:LiveWire)
                battle.pbAnimation(:LIVEWIRE, target, nil)
                user.pbOwnSide.applyEffect(:LiveWire)
            end

            # Attacker effect
            battle.pbAnimation(:SWAGGER, target, [user])
            user.pbConfusionDamage(_INTL("{1} hurt itself in an extreme rage!",user.pbThis), false, selfHitBasePower(user.level)*2)
        end
        target.hideMyAbilitySplash
    }
)

BattleHandlers::TargetAbilityOnHit.add(:RENDINGFANGCHARM,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        if aiCheck
            next -30 * aiNumHits
        end
        target.showMyAbilitySplash(ability)
        target.pbOwnSide.incrementEffect(:FangsDropped)
        if target.pbOwnSide.effectAtMax?(:FangsDropped)
            battle.pbAnimation(:REFRESH, target, nil)
            target.pbOwnSide.disableEffect(:FangsDropped)

            # Main effect
            unless user.pbOwnSide.effectAtMax?(:Spikes)
                battle.pbAnimation(:SPIKES, target, nil)
                user.pbOwnSide.incrementEffect(:Spikes,2)
            end

            # Attacker effect
            battle.pbAnimation(:ASTONISH, target, [user])
            user.applyEffect(:FlinchNextTurn)
        end
        target.hideMyAbilitySplash
    }
)

BattleHandlers::TargetAbilityOnHit.add(:CALMINGSCUTECHARM,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        if aiCheck
            next -30 * aiNumHits
        end
        target.showMyAbilitySplash(ability)
        target.pbOwnSide.incrementEffect(:ScutesDropped)
        if target.pbOwnSide.effectAtMax?(:ScutesDropped)
            battle.pbAnimation(:REFRESH, target, nil)
            target.pbOwnSide.disableEffect(:ScutesDropped)

            # Main effect
            unless target.pbOwnSide.effectActive?(:Sanctuary)
                battle.pbAnimation(:SANCTUARY, target, nil)
                target.pbOwnSide.applyEffect(:Sanctuary, target.getScreenDuration)
            end

            # Attacker effect
            if user.canSleep?(target, true)
                battle.pbAnimation(:YAWN, target, [user])
                user.applyEffect(:Yawn, 2)
            end
        end
        target.hideMyAbilitySplash
    }
)

#########################################
# Other abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:INNARDSOUT,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if user.dummy
        if aiCheck
            if user.takesIndirectDamage?
                next -50 / aiNumHits
            else
                next 0
            end
        end
        next unless target.fainted?
        battle.pbShowAbilitySplash(target, ability)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            oldHP = user.hp
            damageTaken = target.damageState.hpLost
            damageTaken /= 4 if target.boss?
            user.damageState.displayedDamage = damageTaken
            battle.scene.pbDamageAnimation(user)
            user.pbReduceHP(damageTaken, false)
            user.pbHealthLossChecks(oldHP)
        end
        battle.pbHideAbilitySplash(target)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:MUMMY,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if user.fainted?
        next if user.immutableAbility?
        next if user.hasAbility?(ability)
        next -10 if aiCheck
        user.replaceAbility(ability, user.opposes?(target))
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:INFECTED,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if user.fainted?
        next if user.immutableAbility?
        next if user.hasAbility?(ability)
        next unless user.canChangeType?
        next -15 if aiCheck
        user.replaceAbility(ability, user.opposes?(target), target)
        user.applyEffect(:Type3,:GRASS) unless user.pbHasType?(:GRASS)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:WANDERINGSPIRIT,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if user.fainted?
        next if user.immutableAbility?
        next -5 if aiCheck
        showSplashes = user.opposes?(target)
        oldUserAbil = user.abilities
        oldTargetAbil = target.abilities
        replacementMsg = _INTL("{1} swapped Abilities with its target!", user.pbThis)
        target.replaceAbility(oldUserAbil, showSplashes, user, replacementMsg: replacementMsg)
        user.replaceAbility(oldTargetAbil, showSplashes, target, replacementMsg: replacementMsg)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:THUNDERSTRUCK,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        if aiCheck
            next target.pbHasAttackingType?(:ELECTRIC) ? -40 : 0
        else
            next if target.fainted? || target.effectActive?(:EnergyCharge)
            target.showMyAbilitySplash(ability)
            battle.pbAnimation(:CHARGE, target, nil)
            target.applyEffect(:EnergyCharge)
            target.hideMyAbilitySplash
        end
    }
)

BattleHandlers::TargetAbilityOnHit.add(:GULPMISSILE,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if target.form == 0
        next unless target.species == :CRAMORANT
        gulpform = target.form
        if aiCheck
            score = 0
            score -= 20 if user.takesIndirectDamage?
            if gulpform == 1
                score -= getMultiStatDownEffectScore(DEFENDING_STATS_1, target, user)
            elsif gulpform == 2
                score -= getNumbEffectScore(target, user)
            end
            next score
        else
            battle.pbShowAbilitySplash(target, ability)
            target.form = 0
            battle.scene.pbChangePokemon(target, target.pokemon)
            battle.scene.pbDamageAnimation(user)
            user.applyFractionalDamage(1.0 / 4.0) if user.takesIndirectDamage?(true)
            if gulpform == 1
                user.pbLowerMultipleStatSteps(DEFENDING_STATS_1, target, ability: ability)
            elsif gulpform == 2
                msg = nil
                user.applyNumb(target, msg)
            end
            battle.pbHideAbilitySplash(target)
        end
    }
)

BattleHandlers::TargetAbilityOnHit.copy(:GULPMISSILE, :SWALLOWMISSILE)

BattleHandlers::TargetAbilityOnHit.add(:ILLUSION,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next 10 if aiCheck
        # NOTE: This intentionally doesn't show the ability splash.
        next unless target.illusion?
        target.disableEffect(:Illusion)
        battle.scene.pbChangePokemon(target, target.pokemon)
        battle.pbSetSeen(target)
    }
)

BattleHandlers::TargetAbilityOnHit.copy(:ILLUSION,:INCOGNITO)

BattleHandlers::TargetAbilityOnHit.add(:COREPROVENANCE,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.physicalMove?
        next if target.pbOwnSide.effectAtMax?(:ErodedRock)
        if aiCheck
            next (target.aboveHalfHealth? ? -10 : 0) * aiNumHits
        end
        target.showMyAbilitySplash(ability)
        target.pbOwnSide.incrementEffect(:ErodedRock)
        target.hideMyAbilitySplash
    }
)

BattleHandlers::TargetAbilityOnHit.add(:QUILLERINSTINCT,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if target.pbOpposingSide.effectAtMax?(:Spikes)
        if aiCheck
            layerSlots = GameData::BattleEffect.get(:Spikes).maximum - target.pbOpposingSide.countEffect(:Spikes)
            aiNumHits = [aiNumHits,layerSlots].min
            next -getHazardSettingEffectScore(target, user) * aiNumHits
        end
        battle.pbShowAbilitySplash(target, ability)
        target.pbOpposingSide.incrementEffect(:Spikes)
        battle.pbAnimation(:SPIKES, target, nil)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:PERENNIALPAYLOAD,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless move.function.include?("UserFaintsExplosive")
        next unless target.fainted?
        next unless target.damageState.hpLost >= target.totalhp / 2.0
        next -10 if aiCheck
        target.apply_PerennialPayload
    }
)

# Only does stuff for the AI
BattleHandlers::TargetAbilityOnHit.add(:MULTISCALE,
    proc { |ability, user, target, move, _battle, aiCheck, aiNumHits|
        next unless aiCheck
        next unless target.fullHealth?
        next 20 # Value for breaking multiscale
    }
)

# Only does stuff for the AI
BattleHandlers::TargetAbilityOnHit.copy(:MULTISCALE,:DOMINEERING,:SHADOWSHIELD)

BattleHandlers::TargetAbilityOnHit.add(:COLORCOLLECTOR,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if target.fainted?
        next -10 if aiCheck
        
        type = move.calcType

        next if target.pbHasType?(type)
        if target.effectActive?(:ColorCollector)
            target.effects[:ColorCollector].push(type)
        else
            target.applyEffect(:ColorCollector,[type])  
        end

        typeName = GameData::Type.get(type).name
        target.showMyAbilitySplash(ability)
        battle.pbDisplay(_INTL("{1} collected the {2} type!", target.pbThis, typeName))
        battle.scene.pbRefresh
        target.hideMyAbilitySplash
  }
)

BattleHandlers::TargetAbilityOnHit.add(:TANGLINGVINES,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if target.fainted?
        next -10 * aiNumHits if aiCheck
        target.showMyAbilitySplash(ability)
        user.tryLowerStat(:SPEED, target, increment: 1)
        user.pointAt(:TanglingVines, target)
        target.hideMyAbilitySplash
    }
)

BattleHandlers::TargetAbilityOnHit.add(:OVERCHARGE,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next unless target.fainted?
        if aiCheck
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatDownEffectScore([:SPECIAL_ATTACK, 2, :SPEED, 2], target, user, fakeStepModifier: i)
            end
            next ret
        end
        user.pbLowerMultipleStatSteps([:SPECIAL_ATTACK, 2, :SPEED, 2], target, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:ADRENALINERUSH,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if target.fainted?
        next -10 if aiCheck
        target.applyEffect(:MoveNext)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:JOYOUSSORROW,
    proc { |ability, user, target, move, battle, aiCheck, aiNumHits|
        next if target.fainted?
        next -10 if aiCheck
        battle.forceUseMove(target, :WISH, target.index, ability: ability)
  }
)