BattleHandlers::MoveBlockingAbility.add(:ROYALMAJESTY,
  proc { |_ability, bearer, user, targets, move, battle, aiCheck|
      priority = battle.getMovePriority(move, user, targets, aiCheck)
      next false unless priority && priority > 0
      next false unless bearer.opposes?(user)
      # Check all targets and return true if any are on the ability bearer's side
      ret = false
      targets.each do |b|
          next if b.opposes?(bearer)
          ret = true
          break
      end
      next ret
  }
)

BattleHandlers::MoveBlockingAbility.add(:IMPERIOUS,
  proc { |ability, bearer, user, targets, move, battle, aiCheck|
        priority = battle.getMovePriority(move, user, targets, aiCheck)
        next false unless priority && priority > 0
        next false unless bearer.opposes?(user)
        next true
  }
)

BattleHandlers::MoveBlockingAbility.copy(:IMPERIOUS, :ATTENDANTSGRACE)

BattleHandlers::MoveBlockingAbility.add(:DESICCATE,
    proc { |_ability, _bearer, _user, _targets, move, battle, _aiCheck|
        next move.calcTypes.intersect?(%i[GRASS WATER]) && battle.sandy?
    }
)

BattleHandlers::MoveBlockingAbility.add(:DECONTAMINATION,
    proc { |_ability, _bearer, _user, _targets, move, battle, _aiCheck|
        next move.calcTypes.intersect?(%i[BUG POISON]) && battle.moonGlowing?
    }
)

BattleHandlers::MoveBlockingAbility.add(:ABSOLUTEDEFENSE,
    proc { |ability, bearer, user, _targets, move, _battle, aiCheck|
        next move.pbTarget(user).num_targets > 1 && bearer.opposes?(user)
    }
)
