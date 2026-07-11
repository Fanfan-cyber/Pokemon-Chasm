class PokeBattle_Battler
attr_reader :effects_objects, :effect_containers, :active_effect_flags, :stat_cache_dirty

  def pbInitialize(*args)
    @effects_objects = []

    @effect_containers = {}
    EffectTriggers.constants.each do |trigger_sym|
      @effect_containers[EffectTriggers.const_get(trigger_sym)] = []
    end

    @active_effect_flags = EffectFlags::NONE

    @stat_cache_dirty = true
  end

  def add_effect(effect_instance)
    return if effect_instance.nil?

    @effects_objects << effect_instance

    effect_instance.triggers.each do |trigger|
      container = @effect_containers[trigger]
      if container && !container.include?(effect_instance)
        container << effect_instance
        container.sort_by! { |eff| eff.priority }
      end
    end

    @active_effect_flags |= effect_instance.flag

    @stat_cache_dirty = true

    each_effect(EffectTriggers::ON_EFFECT_ADDED).each do |existing_effect|
      existing_effect.on_effect_added if existing_effect == effect_instance
    end

    each_effect(EffectTriggers::ON_ANOTHER_EFFECT_ADDED).each do |existing_effect|
      existing_effect.on_another_effect_added(effect_instance) unless existing_effect == effect_instance
    end
  end

  def remove_effect(effect_instance)
    return if effect_instance.nil?
    @effects_objects.delete(effect_instance)
    @effect_containers.each_value { |container| container.delete(effect_instance) }
    recalc_effect_flags
    @stat_cache_dirty = true
  end

  def recalc_effect_flags
    flags = EffectFlags::NONE
    @effect_containers.each_value do |container|
      container.each do |eff|
        flags |= eff.flag
      end
    end
    @active_effect_flags = flags
  end

  def clear_effects
    @effect_containers.each_value(&:clear)
    @active_effect_flags = EffectFlags::NONE
    @stat_cache_dirty = true
  end

  def each_effect(trigger)
    container = @effect_containers[trigger]
    return if container.nil? || container.empty?
    container.each do |effect|
      yield effect if effect.active?
    end
  end

  def has_effect?(effect_class)
    @effect_containers.values.flatten.any? { |eff| eff.is_a?(effect_class) }
  end

  def process_end_turn_effects
    expired_effects = []
    each_effect(EffectTriggers::ON_END_TURN).each do |effect|
      effect.on_end_turn
      effect.tick
      expired_effects << effect if effect.expired?
    end
    expired_effects.each { |effect| remove_effect(effect) }
  end

  def trapped_by_effects?
    return false unless (@active_effect_flags & EffectFlags::TRAPPING) == 0
    return each_effect(EffectTriggers::ON_PREVENT_SWITCH).any?(&:prevent_switch?)
  end

  def modify_damage(user, target, move, damage)
    @effect_containers.each do |effect|
      damage = effect.on_damage_calc(user, target, move, damage)
    end
    return damage
  end

  def apply_knock_off_effect
    ability_effects = @effect_containers.values.flatten.select { |eff| eff.is_a?(AbilityEffect) }
    ability_effects.each { |eff| remove_effect(eff) }
    @battle.pbDisplay("特性失效了！")
  end
end