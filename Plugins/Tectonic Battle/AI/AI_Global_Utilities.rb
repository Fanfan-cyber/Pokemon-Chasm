#=============================================================================
# Get approximate properties for a battler
#=============================================================================
def pbRoughType(move, user, target)
    if user.should_apply_adaptive_ai_v3?(target, move)
        battle = user.battle
        if battle.adaptive_ai_v3_type_claced?(user, target)
            battle.get_adaptive_ai_v3_type(user, target)[1][0]
        else
            calc_data = calc_best_offense_typeMod_types(move, user, target, true, true)
            battle.record_adaptive_ai_v3_type(user, target, calc_data)
            calc_data[1][0]
        end
    elsif user.should_apply_adaptive_ai_v2?(target, move)
        battle = user.battle
        if battle.adaptive_ai_v2_type_claced?(user, target)
            battle.get_adaptive_ai_v2_type(user, target)[1][0]
        else
            calc_data = calc_best_offense_typeMod_types(move, user, target, false, true)
            battle.record_adaptive_ai_v2_type(user, target, calc_data)
            calc_data[1][0]
        end
    elsif user.should_apply_adaptive_ai_v1?(target, move)
        battle = user.battle
        if battle.adaptive_ai_v1_type_claced?(user, target)
            battle.get_adaptive_ai_v1_type(user, target)
        else
            calc_type = calc_best_offense_types(target)[0]
            battle.record_adaptive_ai_v1_type(user, target, calc_type)
            calc_type
        end
    else
        move.pbCalcType(user)
    end
end

#=============================================================================
# Figure out if the AI should play more aggressively
# because the situation allows/requires it
#=============================================================================
def getUrgency
    urgency = 0
    eachOpposing do |b|
        urgency += 1 if !b.canActThisTurn? # pressure sleeping mons
        urgency += 2 if b.hasSetupMove?
        urgency += 2 if b.hasSetupMove? && b.lastRoundMoveCategory == 2 # Actively setting up
        urgency += 2 if b.hasUseableHazardMove?
        urgency += 1 if b.hasUseableHazardMove? && b.lastRoundMoveCategory == 2 # Actively hazard stacking
        urgency += 2 if b.hasActiveAbilityAI?(:CONTRARY) || b.hasActiveAbilityAI?(:INVERSION)
    end
    if inWeatherTeam && urgency = 0
        weatherInfo = [
            [:SUN_TEAM, @battle.sunny?, :DROUGHT, :HEATROCK],
            [:RAIN_TEAM, @battle.rainy?, :DRIZZLE, :DAMPROCK],
            [:SANDSTORM_TEAM, @battle.sandy?, :SANDSTREAM, :SMOOTHROCK],
            [:HAIL_TEAM, @battle.icy?, :SNOWWARNING, :ICYROCK],
            [:MOONGLOW_TEAM, @battle.moonGlowing?, :MOONGAZE, :MIRROREDROCK],
            [:ECLIPSE_TEAM, @battle.eclipsed?, :HARBINGER, :PINPOINTROCK],
        ]    
        weatherInfo.each do |weatherEntry|
            weatherPolicy = weatherEntry[0]
            weatherActive = weatherEntry[1]
            urgency += 1 if weatherActive && weatherPolicy # Weather teams play more aggressively
        end
    end
    urgency = 5 * urgency
    return urgency
end