class PokeBattle_Battler
  def tracked_abilities
    @tracked_abilities ||= battle_tracker_get(:abilities)
  end

  def ability_tracked?(abil_id)
    tracked_abilities.key?(abil_id)
  end

  def track_all_abilities
    @tracked_abilities = nil
    tracked_abilities.keep_if { |abil_id, _ability| @ability_ids.include?(abil_id) }
    @ability_ids.each do |abil_id|
      next if ability_tracked?(abil_id)
      klass_name = "AbilitySystem_#{abil_id}"
      unless Object.const_defined?(klass_name)
        Object.const_set(klass_name, Class.new(AbilitySystem))
      end
      tracked_abilities[abil_id] = Object.const_get(klass_name).new(abil_id, @battle) # can't pass self here
    end
  end

  def trigger_tracked_ability(method_name, abil_id, *args) # pass self here, args[0]
    abil = tracked_abilities[abil_id]
    return unless abil&.respond_to?(method_name)
    return abil.public_send(method_name, *args)
  end

  def reset_tracked_abilities_switch_counter
    tracked_abilities.each { |_ability_id, abil| abil&.reset_switch_counter }
  end
end

class AbilitySystem
  def self.def_trigger(*triggers)
    triggers.each do |trigger|
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
      attr_reader :#{trigger}_trigger_max_per_battle, :#{trigger}_trigger_max_per_switch, :#{trigger}_trigger_times_battle, :#{trigger}_trigger_times_switch

        def #{trigger}_triggered_max?
          return true if @#{trigger}_trigger_max_per_battle >= 0 && 
                         @#{trigger}_trigger_times_battle >= @#{trigger}_trigger_max_per_battle
          return true if @#{trigger}_trigger_max_per_switch >= 0 && 
                         @#{trigger}_trigger_times_switch >= @#{trigger}_trigger_max_per_switch
          return false
        end

        def #{trigger}_trigger_times_update
          @#{trigger}_trigger_times_battle += 1
          @#{trigger}_trigger_times_switch += 1
        end

        def #{trigger}_reset_counter
          @#{trigger}_trigger_times_battle = 0
          @#{trigger}_trigger_times_switch = 0
        end

        def #{trigger}_reset_battle_counter
          @#{trigger}_trigger_times_battle = 0
        end

        def #{trigger}_reset_switch_counter
          @#{trigger}_trigger_times_switch = 0
        end

        def #{trigger}_set_limit(battle_limit: -1, switch_limit: -1)
          @#{trigger}_trigger_max_per_battle = battle_limit
          @#{trigger}_trigger_max_per_switch = switch_limit
        end

        def #{trigger}_set_battle_limit(battle_limit = -1)
          @#{trigger}_trigger_max_per_battle = battle_limit
        end
        
        def #{trigger}_set_switch_limit(switch_limit = -1)
          @#{trigger}_trigger_max_per_switch = switch_limit
        end
      RUBY
    end
  end

  attr_reader :ability, :battle
  def_trigger :on_switch_in

  def initialize(ability, battle)
    @ability                             = ability
    @battle                              = battle
    @on_switch_in_trigger_max_per_battle = -1
    @on_switch_in_trigger_max_per_switch = -1
    @on_switch_in_trigger_times_battle   = 0
    @on_switch_in_trigger_times_switch   = 0
    @on_switch_in_extra_trigger_times    = 0
  end

  def ==(other)
    if other.is_a?(AbilitySystem)
      @ability == other.ability
    else
      @ability == other
    end
  end

  def reset_switch_counter
    @on_switch_in_trigger_times_switch = 0
  end

  def on_switch_in_blocked?(aiCheck = false); return false; end

  def on_switch_in_extra_trigger_times(aiCheck = false); return @on_switch_in_extra_trigger_times; end

  def on_switch_in(battler, aiCheck = false)
    return false if on_switch_in_blocked?(aiCheck)

    success       = false
    total_ret     = 0
    trigger_times = 1 + on_switch_in_extra_trigger_times(aiCheck)

    trigger_times.times do
      next if on_switch_in_triggered_max?
      ret1 = BattleHandlers::AbilityOnSwitchIn.trigger(@ability, battler, @battle, aiCheck)
      ret2 = on_switch_in_effect(battler, aiCheck)
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

  def on_switch_in_effect(battler, aiCheck = false); return false; end
end

class AbilitySystem_EXAMPLE < AbilitySystem
  def initialize(ability, battle)
    super
    @on_switch_in_trigger_max_per_battle = 1
    @on_switch_in_trigger_max_per_switch = 1
    @on_switch_in_extra_trigger_times    = 1
  end

  def on_switch_in_effect(battler, aiCheck = false)
    return 0 if aiCheck
    @battle.pbShowAbilitySplash(battler, @ability)
    @battle.pbAnimation(:GREYMIST, battler, nil, 0)
    @battle.field.applyEffect(:GreyMist, applyEffectDurationModifiers(3, battler))
    @battle.pbHideAbilitySplash(battler)
    return true
  end
end