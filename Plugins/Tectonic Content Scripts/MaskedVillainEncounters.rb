def setupPostCatacombs()
  # called after defeating Sang 1, sets up everything post-Rock-Climb
  pbSetSelfSwitch(4,"B",true)
  pbSetSelfSwitch(8,"A",true,189)
  pbSetSelfSwitch(12,"A",true,189)
  # active yez 5 meeting events
  pbSetSelfSwitch(23,"A",true,216)
  pbSetSelfSwitch(24,"A",true,216)
  pbSetSelfSwitch(25,"A",true,216)
  # diables the avatar of spiritomb and cutscene
  pbSetSelfSwitch(1,"A",true,220)
  pbSetSelfSwitch(5,"A",true,220)
  $PokemonGlobal.forceMapBGM("Masked Encounter",217)
end

def setupDigsiteEvent()
  pbSetSelfSwitch(47,"A",true,212)
  pbSetSelfSwitch(48,"A",true,212)
  pbSetSelfSwitch(49,"A",true,212)
  pbSetSelfSwitch(50,"A",true,212)
  pbSetSelfSwitch(51,"A",true,212)
  pbSetSelfSwitch(52,"A",true,212)
  pbSetSelfSwitch(56,"A",true,212)
  $PokemonGlobal.forceMapBGM("Masked Encounter",212)  
end