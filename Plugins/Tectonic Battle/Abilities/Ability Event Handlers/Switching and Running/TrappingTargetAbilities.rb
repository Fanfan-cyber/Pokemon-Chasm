BattleHandlers::TrappingTargetAbility.add(:ARENATRAP,
    proc { |ability, switcher, _bearer, _battle|
        next true unless switcher.airborne?
    }
)

BattleHandlers::TrappingTargetAbility.add(:SHADOWTAG,
  proc { |ability, switcher, _bearer, _battle|
      next true unless switcher.hasActiveAbility?([:MAGICALGIRL, :SHADOWTAG])
  }
)

BattleHandlers::TrappingTargetAbility.add(:MAGICALGIRL,
  proc { |ability, switcher, bearer, _battle|
      if bearer.form != 0 && !switcher.hasActiveAbility?([:MAGICALGIRL, :SHADOWTAG]) && !switcher.pbHasType?(:GHOST)
          next true
      end
  }
)

BattleHandlers::TrappingTargetAbility.add(:CLINGY,
  proc { |ability, switcher, _bearer, _battle|
      next true if switcher.pbHasAnyStatus?
  }
)

BattleHandlers::TrappingTargetAbility.add(:FROSTPITALITY,
  proc { |ability, switcher, _bearer, battle|
      next true if battle.icy?
  }
)

BattleHandlers::TrappingTargetAbility.add(:TRACTORBEAM,
  proc { |ability, switcher, _bearer, battle|
      next true if battle.eclipsed?
  }
)

BattleHandlers::TrappingTargetAbility.add(:NOHOPE,
  proc { |ability, switcher,  _bearer, _battle|
      next true if switcher.belowHalfHealth?
  }
)