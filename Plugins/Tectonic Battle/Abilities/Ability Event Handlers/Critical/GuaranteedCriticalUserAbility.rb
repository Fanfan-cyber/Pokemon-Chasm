BattleHandlers::GuaranteedCriticalUserAbility.add(:MERCILESS,
    proc { |ability, _user, target, _battle, move, _aiCheck|
        next true if target.poisoned?
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:HARSH,
    proc { |ability, _user, target, _battle, move, _aiCheck|
        next true if target.burned?
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:COLDBLOODED,
    proc { |ability, _user, target, _battle, move, _aiCheck|
        next true if target.frostbitten?
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:SEVERE,
    proc { |ability, _user, target, _battle, move, _aiCheck|
        next true if target.numbed?
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:WALLNINJA,
    proc { |ability, user, _target, _battle, move, _aiCheck|
        next true if user.battle.roomActive? && (move.canRandomCrit? || user.effects[:RaisedCritChance] > 0)
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:BREAKINGWAVE,
    proc { |ability, user, _target, _battle, move, _aiCheck|
        next true if user.firstTurn?
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:PERFECTLUCK,
    proc { |ability, _user, target, _battle, move, _aiCheck|
        next true
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:STERN,
    proc { |ability, _user, target, _battle, move, _aiCheck|
        next true if target.waterlogged?
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:STAYOFEXECUTION,
    proc { |ability, _user, target, _battle, move, _aiCheck|
        next true if move.sliceMove?
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:SWIFTSTOMPS,
    proc { |ability, user, _target, _battle, move, aiCheck|
      hits = user.battle_tracker_get(:hits_in_progress_kicking)
      hits += 1 if aiCheck
      next true if move.kickingMove? && hits % 3 == 0
  }
)

############################################
# Ability Code for cut or unused abilities
############################################

BattleHandlers::GuaranteedCriticalUserAbility.add(:LURING,
    proc { |ability, _user, target, _battle, move, _aiCheck|
        next true if target.dizzy?
    }
)