class EffectSystem
  attr_reader :battle, :battler, :source, :duration, :priority, :flag, :triggers

  def initialize(battler, source = nil, duration = -1, priority = 100)
    @battle   = battler.battle
    @battler  = battler
    @source   = source
    @duration = duration
    @priority = priority
    @flag     = self.class.flag
    @triggers = effect_triggers
    @active   = true
  end

  def self.flag; return EffectFlags::NONE; end

  def effect_triggers; return []; end

  def on_begin_turn; end
  def on_end_turn; end
  def on_switch_in; end
  def on_switch_out; end
  def on_damage_calc(user, target, move, damage); return damage; end
  def on_prevent_switch; end
  def on_stat_calc(mod, stat); return mod; end
  def on_hp_change(old_hp, new_hp); end
  def on_status_apply; end
  def on_ability_change; end
  def on_effect_added; end
  def on_another_effect_added(new_effect); end

  def prevent_switch?; return false;          end
  def tick?;           return true;           end
  def expired?;        return @duration == 0; end
  def active?;         return @active;        end
  def ability_effect?; return false;          end
  def item_effect?;    return false;          end
  def normal_effect?;  return false;          end

  def tick
    return unless tick?
    return unless @duration > 0
    @duration -= 1
    expire if @duration <= 0
  end

  def expire
    @active = false
  end
end

class NormalEffect < EffectSystem
  def self.flag; return EffectFlags::NORMAL; end

  def normal_effect?; return true; end

  def tick; end
end

class AbilityEffect < EffectSystem
  def initialize(battler)
    super(battler, nil, -1)
  end

  def self.flag; return EffectFlags::ABILITY; end

  def ability_effect?; return true; end

  def tick; end
end

class ItemEffect < EffectSystem
  def self.flag; return EffectFlags::ITEM; end

  def item_effect?; return true; end

  def tick; end
end