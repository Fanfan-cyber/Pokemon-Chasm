module EffectFlags
  NONE          = 0
  TRAPPING      = 1 << 0
  BINDING       = 1 << 1
  HEALING       = 1 << 2
  STAT_MODIFY   = 1 << 3
  DAMAGE_REDUCE = 1 << 4
  SECRET_FREAK  = 1 << 5
  LEECH_SEED    = 1 << 6
  NORMAL        = 1 << 7
  ABILITY       = 1 << 8
  ITEM          = 1 << 9
end

module EffectTriggers
  ON_BEGIN_TURN            = :on_begin_turn
  ON_END_TURN              = :on_end_turn
  ON_SWITCH_IN             = :on_switch_in
  ON_SWITCH_OUT            = :on_switch_out
  ON_DAMAGE_CALC           = :on_damage_calc
  ON_PREVENT_SWITCH        = :on_prevent_switch
  ON_STAT_CALC             = :on_stat_calc
  ON_HP_CHANGE             = :on_hp_change
  ON_STATUS_APPLY          = :on_status_apply
  ON_ABILITY_CHANGE        = :on_ability_change
  ON_EFFECT_ADDED          = :on_effect_added
  ON_ANOTHER_EFFECT_ADDED  = :on_another_effect_added
end

module EffectPriority
  BASE_STATS   = 100
  ABILITY      = 200
  ITEM         = 300
  FIELD_EFFECT = 400
  MOVEMENT     = 500
  FINAL_CHECK  = 600
end