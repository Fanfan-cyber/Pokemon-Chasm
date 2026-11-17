BattleHandlers::DamageCalcUserAbility.add(:ARCTICARIETTE,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
      if aiCheck
          mults[:attack_multiplier] *= 13 / 10.0 if move.soundMove? || backfire
      elsif move.powerBoost || backfire
          mults[:attack_multiplier] *= 13 / 10.0
          user.aiLearnsAbility(ability) unless aiCheck
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GALVANIZE,
  proc { |ability, user, _target, move, mults, _baseDmg, types, aiCheck, backfire|
      if aiCheck
          mults[:attack_multiplier] *= 13 / 10.0 if types.first == :ELECTRIC || backfire
      elsif move.powerBoost || backfire
          mults[:attack_multiplier] *= 13 / 10.0
          user.aiLearnsAbility(ability) unless aiCheck
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:NORMALIZE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      #if aiCheck
          #mults[:attack_multiplier] *= 3 / 2.0 if types.first == :NORMAL || backfire
      #elsif move.powerBoost || backfire
          mults[:attack_multiplier] *= 3 / 2.0
          #user.aiLearnsAbility(ability) unless aiCheck
      #end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ANALYTIC,
  proc { |ability, user, target, _move, mults, _baseDmg, _types, aiCheck, backfire|
      if aiCheck
          mults[:attack_multiplier] *= 13 / 10.0 if target.pbSpeed < user.pbSpeed || backfire
      elsif (target.battle.choices[target.index][0] != :UseMove &&
            target.battle.choices[target.index][0] != :Shift) ||
            target.movedThisRound? || backfire
          mults[:attack_multiplier] *= 13 / 10.0
          user.aiLearnsAbility(ability) unless aiCheck
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DEFEATIST,
  proc { |ability, user, _target, _move, mults, _baseDmg, _types, aiCheck, backfire|
    if !user.belowHalfHealth? || backfire
      mults[:attack_multiplier] *= 1 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PERFECTIONIST,
  proc { |ability, user, target, _move, mults, _baseDmg, _types, aiCheck, backfire|
    unless target.damageState.critical || backfire # TODO: Ai check
      mults[:final_damage_multiplier] *= 1 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MEGALAUNCHER,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.pulseMove? || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:MEGALAUNCHER, :PRIMEVALMEGALAUNCHER, :MANIFESTATION)

BattleHandlers::DamageCalcUserAbility.add(:EMANATION,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.pulseMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:LETEMHAVEIT,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.pulseMove? || backfire
      mults[:attack_multiplier] *= 5 / 4.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FICKLEUNION,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.pulseMove? || backfire
      mults[:attack_multiplier] *= 3 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ULTRABUSTER,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.pulseMove? || move.punchingMove? || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FADINGFURY,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.lightMove? || move.kickingMove? || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

=begin
BattleHandlers::DamageCalcUserAbility.add(:REFRACTIVE,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.lightMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)
=end

BattleHandlers::DamageCalcUserAbility.add(:RECKLESS,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.recoilMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:LINEBACKER,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.recoilMove? || backfire
      mults[:attack_multiplier] *= 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HOOLIGAN,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.recoilMove? || move.soundMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STONEMANE,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.recoilMove? || backfire
      mults[:attack_multiplier] *= 6 / 5.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BITEY,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.bitingMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STRONGJAW,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.bitingMove? || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SHEERFORCE,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.randomEffect? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TECHNICIAN,
  proc { |ability, user, target, move, mults, baseDmg, _types, aiCheck, backfire|
      if user.index != target.index && move && move.id != :STRUGGLE && baseDmg <= 60 || backfire
          mults[:attack_multiplier] *= 3 / 2.0
          user.aiLearnsAbility(ability) unless aiCheck
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:IRONFIST,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.punchingMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:IRONFIST, :MYSTICFIST)

BattleHandlers::DamageCalcUserAbility.add(:KNUCKLEDUSTER,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.punchingMove? || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

=begin
BattleHandlers::DamageCalcUserAbility.add(:SHIFTINGFIST,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.punchingMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)
=end

BattleHandlers::DamageCalcUserAbility.add(:BRISK,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.windMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GALEFORCE,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.windMove? || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:LOUD,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.soundMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:LOUD, :TUNEDOUT, :LEADSINGER)

BattleHandlers::DamageCalcUserAbility.add(:EARSPLITTING,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.soundMove? || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SWORDPLAY,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.sliceMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:SWORDPLAY, :RAZORSEDGE, :BLADEBRAINED)

BattleHandlers::DamageCalcUserAbility.add(:SHARPNESS,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.sliceMove? || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:IRONHEEL,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.kickingMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:IRONHEEL, :HEAVYDUTYHOOVES)

BattleHandlers::DamageCalcUserAbility.add(:BEAMING,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.lightMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RADIATE,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.lightMove? || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WELLROUNDED,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.tagged? || backfire
      mults[:attack_multiplier] *= 6 / 5.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BADOMEN,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.foretoldMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SEER,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.foretoldMove? || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:CREEPINGHORROR,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.foretoldMove? || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GORGING,
  proc { |ability, user, _target, move, mults, _baseDmg, _types, aiCheck, backfire|
    if move.healingMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:EXPERTISE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if Effectiveness.super_effective?(typeModToCheck(user.battle, types, user, target, move, aiCheck)) || backfire
      mults[:final_damage_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:EXPERTISE, :NEUROFORCE)

BattleHandlers::DamageCalcUserAbility.add(:TINTEDLENS,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if Effectiveness.resistant?(typeModToCheck(user.battle, types, user, target, move, aiCheck)) || backfire
      mults[:final_damage_multiplier] *= 2
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SNIPER,
  proc { |ability, user, target, _move, mults, _baseDmg, _types, aiCheck, backfire|
    if target.damageState.critical || backfire # TODO: Ai check
      mults[:final_damage_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STAKEOUT,
  proc { |ability, user, target, _move, mults, _baseDmg, _types, aiCheck, backfire|
    if target.effectActive?(:SwitchedIn) || backfire
      mults[:attack_multiplier] *= 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:SNIPER, :PROBEWEAKNESS)

BattleHandlers::DamageCalcUserAbility.add(:LIMINAL,
  proc { |ability, user, target, _move, mults, _baseDmg, _types, aiCheck, backfire|
    if target.effectActive?(:SwitchedIn) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:LIMINAL, :AFTERIMAGE)

BattleHandlers::DamageCalcUserAbility.add(:BIRDOFPREY,
  proc { |ability, user, target, _move, mults, _baseDmg, _types, aiCheck, backfire|
    if target.effectActive?(:SwitchedIn) || target.belowHalfHealth? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:QUARRELSOME,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if user.firstTurn? || backfire
      mults[:attack_multiplier] *= 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEELWORKER,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      if types.include?(:STEEL) || backfire
          mults[:attack_multiplier] *= 3 / 2.0
          user.aiLearnsAbility(ability) unless aiCheck
      end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:STEELWORKER, :STEELYSHELL, :PULVERIZE, :SUPERALLOY, :STEELYSPIRIT)

BattleHandlers::DamageCalcUserAbility.add(:PALEOLITHIC,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:ROCK) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SURFSUP,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:WATER) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ERUDITE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:PSYCHIC) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MULTITASKER,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:PSYCHIC) || backfire
      mults[:attack_multiplier] *= 27 / 20.0 # 1.35
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:EVENHANDED,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:FIGHTING) || backfire
      mults[:attack_multiplier] *= 27 / 20.0 # 1.35
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PECKINGORDER,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:FLYING) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TUNNELMAKER,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:GROUND) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SUBZERO,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:ICE) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SCALDINGSMOKE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:POISON) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:SCALDINGSMOKE, :TOXICATTITUDE)

BattleHandlers::DamageCalcUserAbility.add(:VERDANT,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:GRASS) || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:UNCANNYCOLD,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:ICE) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WATERBUBBLE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:WATER) || backfire
      mults[:attack_multiplier] *= 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SHOCKSTYLE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:FIGHTING) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HUSTLE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DRAGONSMAW,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:DRAGON) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TRANSISTOR,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:ELECTRIC) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MIDNIGHTSUN,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if user.battle.sunny? && types.include?(:DARK) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DARKENEDSKIES,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if user.battle.sandy? && types.include?(:DARK) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RAINPRISM,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if user.battle.rainy? && types.include?(:FAIRY) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WORLDQUAKE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if user.battle.eclipsed? && types.include?(:GROUND) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TIDALFORCE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if user.battle.moonGlowing? && types.include?(:WATER) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TAIGATREKKER,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if user.battle.icy? && types.include?(:GRASS) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:VARIETY,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if user.lastMoveUsed != move.id && !user.lastMoveFailed || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PHASESHIFT,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if !user.lastMoveUsedTypes.empty? && types.first != user.lastMoveUsedTypes.first || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ARMORPIERCING,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if  target.steps[:DEFENSE] > 0 ||
        target.steps[:SPECIAL_DEFENSE] > 0 ||
        target.protectedByScreen? || backfire
      mults[:attack_multiplier] *= 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TERRITORIAL,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if target.battle.pbWeather != :None || backfire
      mults[:attack_multiplier] *= 6 / 5.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SOULREAD,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      if target.lastMoveUsedOffType? || backfire
          mults[:attack_multiplier] *= 2.0
          user.aiLearnsAbility(ability) unless aiCheck
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DOUBLECHECK,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if target.tookDamage || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DRAGONSLAYER,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if target.pbHasType?(:DRAGON) || backfire
      mults[:attack_multiplier] *= 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SPACEINTERLOPER,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      mults[:attack_multiplier] *= 1 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TIMEINTERLOPER,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      mults[:attack_multiplier] *= 3.0 / 4.0
      user.aiLearnsAbility(ability) unless aiCheck
  }
)

=begin
BattleHandlers::DamageCalcUserAbility.add(:MARINEMENACE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if move.function == "TwoTurnAttackInvulnerableUnderwater" || backfire # Dive, # Depth Charge
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:EXCAVATOR,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if move.function == "TwoTurnAttackInvulnerableUnderground" || backfire # Dig, Undermine
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEEPFLYING,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if move.function == "TwoTurnAttackInvulnerableInSky" || backfire # Fly, Divebomb
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)
=end

BattleHandlers::DamageCalcUserAbility.add(:GRIPSTRENGTH,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if move.function == "BindTarget3" || backfire # 3-turn DOT trapping moves
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

UNCONVENTIONAL_MOVE_CODES = %w[
    AttacksWithTargetsStats
    AttacksWithDefense
    AttacksWithSpDef
    DoesPhysicalDamage
    DoesSpecialDamage
    TargetsAttackDefends
    TargetsSpAtkDefends
].freeze

BattleHandlers::DamageCalcUserAbility.add(:UNCONVENTIONAL,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if UNCONVENTIONAL_MOVE_CODES.include?(move.function) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RATTLEEM,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if target.effectActive?(:FlinchImmunity) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:AURORAPRISM,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.none? { |type| user.pbHasType?(type) } || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLEXIBLE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.none? { |type| user.pbHasType?(type) } || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FIRSTSTRIKE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      priority = user.battle.choices[user.index][4] || move.priority || nil
      if priority > 0 || backfire
        mults[:attack_multiplier] *= 13 / 10.0
        user.aiLearnsAbility(ability) unless aiCheck
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HARDFALL,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if target.pbHeight > user.pbHeight || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SCATHINGSYZYGY,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if user.battle.eclipsed? || backfire
      mults[:attack_multiplier] *= 5 / 4.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BALLLIGHTNING,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      damageMult = 1.0
      if user.pbSpeed > target.pbSpeed || backfire
        speedMult = user.pbSpeed / target.pbSpeed.to_f
        speedMult = 2.0 if speedMult > 2.0
        damageMult += speedMult / 4.0
      end
      mults[:attack_multiplier] *= damageMult
      user.aiLearnsAbility(ability) unless aiCheck
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PREEMINENCE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      if user.pbSpeed > target.pbSpeed || backfire
        mults[:attack_multiplier] *= 13 / 10.0
        user.aiLearnsAbility(ability) unless aiCheck
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:LATEBLOOMER,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if user.pbSpeed < target.pbSpeed || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:VANDAL,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if target.hasAnyItem? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TEAMPLAYER,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      allyCount = 0
      user.eachAlly do |_b|
          allyCount += 1
      end
      mults[:attack_multiplier] *= (1 + (0.25 * allyCount))
      user.aiLearnsAbility(ability) unless aiCheck
  }
)

BattleHandlers::DamageCalcUserAbility.add(:CLEANFREAK,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      mults[:attack_multiplier] *= 3 / 2.0 if user.pbHasAnyStatus? || backfire
      user.aiLearnsAbility(ability) unless aiCheck
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PUFFUP,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      mults[:attack_multiplier] *= 1 + (0.25 * user.countEffect(:Stockpile))
      user.aiLearnsAbility(ability) unless aiCheck
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WREAKHAVOC,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if move.rampagingMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SLINKY,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if move.is_a?(PokeBattle_Move_TwoTurnAttackInvulnerable) || backfire
      mults[:attack_multiplier] *= 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PHANTASMAL,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if move.is_a?(PokeBattle_Move_TwoTurnAttackInvulnerable) || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TERRORIZE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    mults[:attack_multiplier] *= 9 / 10.0
    user.aiLearnsAbility(ability) unless aiCheck
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PITFIGHTER,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if target.trapped? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HIVEMIND,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if types.include?(:BUG) || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RELUCTANTWARRIOR,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if user.belowHalfHealth? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
	    user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)
	  
BattleHandlers::DamageCalcUserAbility.add(:TANGLINGVINES,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if target.pointsAt?(:TanglingVines, user) || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ACTIONSTAR,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
      next unless user.effectActive?(:ActionStar)
      next unless move.damagingMove?
      next unless types.include?(:NORMAL)
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SLUMBERFORCE,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if target.asleep? || backfire
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BREAKTHROUGH,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    mults[:attack_multiplier] *= 6 / 5.0
    user.aiLearnsAbility(ability) unless aiCheck
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:BREAKTHROUGH, :PRIMEVALBREAKTHROUGH, :JUGGERNAUT, :STRAIGHTAHEAD)

BattleHandlers::DamageCalcUserAbility.add(:INSCRUTABLEORDERS,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    mults[:attack_multiplier] *= 13 / 10.0
    user.aiLearnsAbility(ability) unless aiCheck
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HAPHAZARD,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    if move.accuracy < 100 || move.multiHitMove? || backfire
      mults[:attack_multiplier] *= 13 / 10.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FUELHUNGRY,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck, backfire|
    mults[:attack_multiplier] *= 3 / 2.0
    user.aiLearnsAbility(ability) unless aiCheck
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BARRENBLOOD,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck|
    if user.battle.sandy?
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DEBRISFIELD,
  proc { |ability, user, target, move, mults, _baseDmg, types, aiCheck|
    if user.battle.sandy? && type == :ROCK
      mults[:attack_multiplier] *= 3 / 2.0
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)