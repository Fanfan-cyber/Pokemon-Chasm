class Trapping < NormalEffect
  def self.flag; return EffectFlags::TRAPPING; end

  def effect_triggers
    [EffectTriggers::ON_PREVENT_SWITCH]
  end

  def prevent_switch?; return true; end
end

class Binding < Trapping
  def self.flag; return EffectFlags::BINDING; end

  def initialize(battler, source, duration)
    super
    @damage_per_turn = battler.totalhp / 8
  end

  def triggers
    [EffectTriggers::ON_END_TURN, EffectTriggers::ON_PREVENT_SWITCH]
  end

  def on_end_turn
    @battler.pbReduceHP(@damage_per_turn, true)
  end
end

class SecretFreak < AbilityEffect
  def self.flag; return EffectFlags::DAMAGE_REDUCE | EffectFlags::STAT_MODIFY; end

  def triggers
    [EffectTriggers::ON_DAMAGE_CALC, EffectTriggers::ON_END_TURN]
  end

  def on_damage_calc(user, target, move, damage)
    if target.trapped? && damage > 0
      @battle.pbDisplay(_INTL("{1}的怪癖免疫了束缚伤害！", @battler.pbThis))
      return 0
    end
    return damage
  end

  def on_end_turn
    if @battler.trapped? && @battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, @battler)
      @battler.pbRaiseStatStage(:SPECIAL_ATTACK, 1, @battler)
    end
  end
end