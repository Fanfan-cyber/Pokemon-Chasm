class PokeBattle_Battler
  def tracked_abilities
    @tracked_abilities ||= battle_tracker_get(:abilities)
  end

  def ability_tracked?(ability_id)
    tracked_abilities.key?(ability_id)
  end

  def track_all_abilities
    abils = abilities
    @tracked_abilities = nil
    tracked_abilities.keep_if { |ability_id, _ability| abils.include?(ability_id) }
    abils.each do |ability_id|
      next if ability_tracked?(ability_id)
      class_name = "AbilityFactory_#{ability_id}"
      if Object.const_defined?(class_name)
        tracked_abilities[ability_id] = Object.const_get(class_name).new(ability_id)
      else
        tracked_abilities[ability_id] = nil
      end
    end
  end

  def trigger_tracked_ability(method_name, ability_id, *args)
    ability = tracked_abilities[ability_id]
    return unless ability && ability.respond_to?(method_name)
    ability.public_send(method_name, ability_id, *args)
  end

  def reset_tracked_abilities_switch_counter
    tracked_abilities.each { |_ability_id, ability| ability&.reset_switch_counter }
  end
end

class AbilityFactory
  attr_reader :id
  attr_reader :on_switch_in_trigger_max_per_battle, :on_switch_in_trigger_max_per_switch, :on_switch_in_trigger_times_battle, :on_switch_in_trigger_times_switch

  def initialize(id)
    @id                                  = id
    @on_switch_in_trigger_max_per_battle = -1
    @on_switch_in_trigger_max_per_switch = -1
    @on_switch_in_trigger_times_battle   = 0
    @on_switch_in_trigger_times_switch   = 0
  end

  def ==(other)
    if other.is_a?(AbilityFactory)
      @id == other.id
    else
      @id == other
    end
  end

  def reset_switch_counter
    @on_switch_in_trigger_times_switch = 0
  end

  def can_trigger_on_switch_in?
    return false if @on_switch_in_trigger_max_per_battle >= 0 && @on_switch_in_trigger_times_battle >= @on_switch_in_trigger_max_per_battle
    return false if @on_switch_in_trigger_max_per_switch >= 0 && @on_switch_in_trigger_times_switch >= @on_switch_in_trigger_max_per_switch
    return true
  end

  def update_on_switch_in_trigger_times
    @on_switch_in_trigger_times_battle += 1
    @on_switch_in_trigger_times_switch += 1
  end

  def on_switch_in(ability, battler, battle, aiCheck = false)
    return false unless can_trigger_on_switch_in?
    ret = on_switch_in_effect(ability, battler, battle, aiCheck)
    if aiCheck
      return ret
    elsif ret
      update_on_switch_in_trigger_times
      return true
    end
    return false
  end
=begin
def on_switch_in(ability, battler, battle, aiCheck = false)
  # 首先检查特性是否被禁用
  return false unless can_ability_trigger?(ability, battler, battle, aiCheck)
  
  success = false
  total_ret = 0
  
  # 基础触发1次 + 额外触发次数
  trigger_times = 1 + extra_trigger_times(ability, battler, battle, aiCheck)
  
  trigger_times.times do
    # 每次触发前都检查条件
    next unless can_trigger_on_switch_in?
    
    # 统一调用效果方法
    ret = on_switch_in_effect(ability, battler, battle, aiCheck)
    
    if aiCheck
      # AI检查模式下，累积返回值
      total_ret += ret if ret.is_a?(Numeric)
    else
      # 实际战斗模式下，执行触发并记录成功状态
      if ret
        update_on_switch_in_trigger_times
        success = true
      end
    end
  end
  
  if aiCheck
    return total_ret
  else
    return success
  end
end

# 前置检查：特性是否能够触发
def can_ability_trigger?(ability, battler, battle, aiCheck = false)
  # 这里实现你的判断逻辑
  # 例如：检查特性是否被封印、沉默或其他状态影响
  # 返回true表示可以触发，返回false表示完全禁用
  return true  # 默认返回true，允许触发
end

# 额外触发次数的方法
def extra_trigger_times(ability, battler, battle, aiCheck = false)
  # 这里实现你的判断逻辑，返回额外的触发次数
  return 0  # 默认返回0，只触发基础的一次
end
=end
  def on_switch_in_effect(ability, battler, battle, aiCheck = false); return false; end
end

class AbilityFactory_EXAMPLE < AbilityFactory
  def initialize(id)
    super
    @on_switch_in_trigger_max_per_battle = 1
    @on_switch_in_trigger_max_per_switch = 1
  end

  def on_switch_in_effect(ability, battler, battle, aiCheck = false)
    return 0 if aiCheck
    battle.pbShowAbilitySplash(battler, ability)
    battle.pbAnimation(:GREYMIST, battler, nil, 0)
    battle.field.applyEffect(:GreyMist, applyEffectDurationModifiers(3, battler))
    battle.pbHideAbilitySplash(battler)
    return true
  end
end

class AbilitySystem
  attr_reader :id, :score, :flags, :ability_handler

  @@ability_cache = {}

  def initialize(id)
    @id              = id
    @score           = 0
    @flags           = []
    @ability_handler = {}
  end

  def self.clear_cache # didn't apply this
    @@ability_cache.clear
  end

  def self.get_ability(id)
    class_name = "AbilitySystem_#{id}"
    return unless Object.const_defined?(class_name)
    @@ability_cache[id] ||= Object.const_get(class_name).new(id)
  end

  def self.get(id, attr)
    ability = get_ability(id)
    return unless ability
    ability.instance_variable_get("@#{attr}")
  end

  def self.get_score(id)
    get_ability(id)&.score || 0
  end

  def self.get_flags(id)
    get_ability(id)&.flags || []
  end

  def self.apply_effect(handler, id, *args)
    get_ability(id)&.ability_handler&.[](handler)&.call(handler, id, *args)
  end

  def self.apply_effect_backfire(handler, id, mults, battle)
    ability = get_ability(id)
    return unless ability
    ability_class = ability.class
    return unless ability_class.const_defined?(:OFF_MULT)
    off_mult = ability_class.const_get(:OFF_MULT)
    calc_mults(off_mult, handler, mults, battle)
  end

  def self.calc_mults(off_mult, handler, mults, battle = nil, reverse = false) # didn't use battle/reverse yet
    return unless off_mult
    handler_mult = off_mult[handler]
    return if !handler_mult || handler_mult.empty?
    if reverse
      handler_mult.each { |mult, value| mults[mult] /= value }
    else
      handler_mult.each { |mult, value| mults[mult] *= value }
    end
  end
end

=begin
class AbilitySystem_ILLUSION < AbilitySystem
  OFF_MULT = { :DamageCalcUserAbility => { :base_damage_multiplier => 1.2, }, }

  DamageCalcUserAbility =
    proc { |handler, _ability, battle, user, _target, _move, mults, _baseDmg, _type, _aiCheck|
      AbilitySystem.calc_mults(OFF_MULT, handler, mults, battle) if user.illusion?
    }

  def initialize(id)
    super
    @ability_handler[:DamageCalcUserAbility] = DamageCalcUserAbility
  end
end
=end

class AbilitySystem_SWIFTSTOMPS < AbilitySystem
  HIT_CYCLE = 3

  GuaranteedCriticalUserAbility =
    proc { |_handler, _ability, move, user, _target, _battle, aiCheck|
      hits = user.battle_tracker_get(:hits_in_progress_kicking)
      hits += 1 if aiCheck
      next true if move.kickingMove? && hits % HIT_CYCLE == 0
    }

  def initialize(id)
    super
    @ability_handler[:GuaranteedCriticalUserAbility] = GuaranteedCriticalUserAbility
  end
end

class AbilitySystem_EXAMPLE < AbilitySystem
  OFF_MULT = { :DamageCalcUserAbility => { :attack_multiplier => 1.3, :base_damage_multiplier => 1.2, }, }

  DamageCalcUserAbility =
    proc { |handler, _ability, battle, _user, _target, _move, mults, _baseDmg, _type, _aiCheck|
      AbilitySystem.calc_mults(OFF_MULT, handler, mults, battle)
    }

  GuaranteedCriticalUserAbility =
    proc { |_handler, _ability, move, user, _target, _battle, aiCheck|
      hits = user.battle_tracker_get(:hits_in_progress_kicking)
      hits += 1 if aiCheck
      next true if move.kickingMove? && hits % 3 == 0
    }

  def initialize(id)
    super
    @ability_handler[:DamageCalcUserAbility]         = DamageCalcUserAbility
    @ability_handler[:GuaranteedCriticalUserAbility] = GuaranteedCriticalUserAbility
  end
end