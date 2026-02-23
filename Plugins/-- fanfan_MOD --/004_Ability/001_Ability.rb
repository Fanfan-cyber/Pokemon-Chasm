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
      unless Object.const_defined?(class_name)
        Object.const_set(class_name, Class.new(AbilityFactory))
      end
      tracked_abilities[ability_id] = Object.const_get(class_name).new(ability_id, self, @battle)
    end
  end

  def trigger_tracked_ability(method_name, ability_id, *args)
    ability = tracked_abilities[ability_id]
    return unless ability&.respond_to?(method_name)
    return ability.public_send(method_name, *args)
  end

  def reset_tracked_abilities_switch_counter
    tracked_abilities.each { |_ability_id, ability| ability&.reset_switch_counter }
  end
end

class AbilityFactory
  attr_reader :ability, :battler, :battle
  attr_reader :on_switch_in_trigger_max_per_battle, :on_switch_in_trigger_max_per_switch, :on_switch_in_trigger_times_battle, :on_switch_in_trigger_times_switch
  attr_reader :on_switch_in_extra_trigger_times

  def initialize(ability, battler, battle)
    @ability                             = ability
    @battler                             = battler
    @battle                              = battle
    @on_switch_in_trigger_max_per_battle = -1
    @on_switch_in_trigger_max_per_switch = -1
    @on_switch_in_trigger_times_battle   = 0
    @on_switch_in_trigger_times_switch   = 0
    @on_switch_in_extra_trigger_times    = 0
  end

  def ==(other)
    if other.is_a?(AbilityFactory)
      @ability == other.ability
    else
      @ability == other
    end
  end

  def reset_switch_counter
    @on_switch_in_trigger_times_switch = 0
  end

  def on_switch_in_triggered_max?
    return true if @on_switch_in_trigger_max_per_battle >= 0 && @on_switch_in_trigger_times_battle >= @on_switch_in_trigger_max_per_battle
    return true if @on_switch_in_trigger_max_per_switch >= 0 && @on_switch_in_trigger_times_switch >= @on_switch_in_trigger_max_per_switch
    return false
  end

  def on_switch_in_trigger_times_update
    @on_switch_in_trigger_times_battle += 1
    @on_switch_in_trigger_times_switch += 1
  end

  def on_switch_in_blocked?(aiCheck = false); return false; end

  def on_switch_in_extra_trigger_times(aiCheck = false); @on_switch_in_extra_trigger_times; end

  def on_switch_in(aiCheck = false)
    return false if on_switch_in_blocked?(aiCheck)

    success       = false
    total_ret     = 0
    trigger_times = 1 + on_switch_in_extra_trigger_times(aiCheck)

    trigger_times.times do
      next if on_switch_in_triggered_max?
      ret1 = BattleHandlers::AbilityOnSwitchIn.trigger(@ability, @battler, @battle, aiCheck)
      ret2 = on_switch_in_effect(aiCheck)
      if aiCheck
        total_ret += ret1 if ret1.is_a?(Numeric)
        total_ret += ret2 if ret2.is_a?(Numeric)
      elsif ret2
        on_switch_in_trigger_times_update
        success = true
      end
    end

    return total_ret if aiCheck
    return success
  end

  def on_switch_in_effect(aiCheck = false); return false; end
end

class AbilityFactory_EXAMPLE < AbilityFactory
  def initialize(ability, battler, battle)
    super
    @on_switch_in_trigger_max_per_battle = 1
    @on_switch_in_trigger_max_per_switch = 1
    @on_switch_in_extra_trigger_times    = 1
  end

  def on_switch_in_effect(aiCheck = false)
    return 0 if aiCheck
    @battle.pbShowAbilitySplash(@battler, @ability)
    @battle.pbAnimation(:GREYMIST, @battler, nil, 0)
    @battle.field.applyEffect(:GreyMist, applyEffectDurationModifiers(3, @battler))
    @battle.pbHideAbilitySplash(@battler)
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