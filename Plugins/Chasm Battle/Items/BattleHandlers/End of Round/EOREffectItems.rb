STICKY_BARB_DAMAGE_FRACTION = 0.125 # 1/8

BattleHandlers::EOREffectItem.add(:STICKYBARB,
  proc { |item, battler, battle|
      next unless battler.takesIndirectDamage?
      battle.pbDisplay(_INTL("{1} is hurt by its {2}!", battler.pbThis, getItemName(item)))
      battler.applyFractionalDamage(STICKY_BARB_DAMAGE_FRACTION)
      battler.aiLearnsItem(item)
  }
)

BattleHandlers::EOREffectItem.add(:POISONORB,
  proc { |item, battler, battle|
	  next unless battler.canPoison?(battler, false)
    battler.applyPoison(nil,
  	  _INTL("{1} was poisoned by the {2}! {3}!", battler.pbThis, getItemName(item), getPoisonExplanation))
    battler.aiLearnsItem(item)
  }
)

BattleHandlers::EOREffectItem.add(:FROSTORB,
  proc { |item, battler, battle|
	  next unless battler.canFrostbite?(battler, false)
    battler.applyFrostbite(nil,
  	  _INTL("{1} was frostbitten by the {2}! {3}!", battler.pbThis, getItemName(item), getFrostbiteExplanation))
    battler.aiLearnsItem(item)
  }
)

BattleHandlers::EOREffectItem.add(:FLAMEORB,
  proc { |item, battler, battle|
	  next unless battler.canBurn?(battler, false)
    battler.applyBurn(nil,
  	  _INTL("{1} was burned by the {2}! {3}!", battler.pbThis, getItemName(item), getBurnExplanation))
    battler.aiLearnsItem(item)
  }
)

BattleHandlers::EOREffectItem.add(:EMPTYSTONE,
  proc { |item, battler, battle|
    anyPPDrained = false
    battler.eachMove do |m|
      next if m.pp <= 0
      battler.pbSetPP(m, m.pp - 1)
      anyPPDrained = true
    end
    battle.pbDisplay(_INTL("{1}'s PP was drained by its {2}!", battler.pbThis, getItemName(item))) if anyPPDrained
  }
)