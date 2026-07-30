MOVE_DATA = {
  :BEDTIME => { :function_code => "SleepTargetIfInFullMoonglow", },
  :DRAGOMASTWAVES => { :desc  => proc { _INTL("Sends hindering waves of energy forward, lowering hit foes' Evasion by four steps. Deals 50% less damage to allies.") }, },
  :LONGSHOT => { :accuracy => 90, },
  #:SWORDSDANCE => { :desc          => proc { _INTL("A frenetic dance to uplift the fighting spirit. It raises the user's Attack stat by three steps.") },
  #                  :function_code => "RaiseUserAtk3", },
  :SYNAPTICUNLOCK => { :desc  => proc { _INTL("The user connects to the target's brainwaves to stabilize its mind, curing its dizziness, and granting it its legal abilities.") }, },
  :TAILWIND => { :desc  => proc { _INTL("The user whips up a turbulent whirlwind, boosting allies' Speed by 33% and lowering foes' Speed by 33% for 4 turns.") }, },
  :YOUNGAGAIN => { :total_pp => 1, },
}.freeze