class GymLeaderRematch
  def initialize
    @gym_leader_rematch = {}
  end

  def get_gym_leader_rematch_data(badge_num)
    @gym_leader_rematch[badge_num] ||= []
  end

  def current_data
    [battlePerfected?, tarotAmuletActive?, get_team_data]
  end

  def get_team_data
    $Trainer.party.map(&:species)
  end

  def add_gym_leader_data(badge_num, data_to_add)
    @gym_leader_rematch[badge_num] << data_to_add
  end

  def used?(team1, team2)
    team1.any? { |pkmn| team2.include?(pkmn) }
  end

  def check_finish(badge_num, current_data)
    current_perfected, current_amulet, current_team = current_data
    badge_num_data = @gym_leader_rematch[badge_num]

    used_pkmn = []
    team_count = 0
    badge_num_data.each do |perfect, amulet, team|
      next unless current_perfected == perfect
      next unless current_amulet == amulet
      used_pkmn.concat(team)
      team_count += 1
    end

    unless used?(current_team, used_pkmn)
      add_gym_leader_data(badge_num, current_data)
      team_count += 1
    end
    return team_count
  end

  def process(badge_num)
    @gym_leader_rematch[badge_num] ||= []

    count = check_finish(badge_num, current_data)
    if count >= GymLeaderRematch.rematch_times(badge_num) # times needed
      @gym_leader_rematch.delete(badge_num)
      return true, count
    else
      return false, count
    end
  end

  REMATCH_TIMES = [2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 7, 7, 7]

  def self.rematch_times(badge_num)
    REMATCH_TIMES[badge_num - 1]
  end

  def self.recorded_teams
    challenging_badge = $Trainer.badge_count + 1
    recorded_team = $Trainer.gym_leader_rematch.get_gym_leader_rematch_data(challenging_badge)
    normal_teams = []
    p_teams = []
    t_teams = []
    p_t_teams = []
    recorded_team.each_with_index do |(perfect, amulet, team), index|
      text = ""
      names = []
      team.each { |pkmn| names << GameData::Species.get(pkmn).name }
      text << names.quick_join
      team_data = { text: text, original_index: index }
      if perfect
        if amulet
          p_t_teams << team_data
        else
          p_teams << team_data
        end
      else
        if amulet
          t_teams << team_data
        else
          normal_teams << team_data
        end
      end
    end
    return p_t_teams, p_teams, t_teams, normal_teams, recorded_team, challenging_badge
  end

  def self.check_recorded_teams
    if TA.get(:simplemode)
      pbMessage(_INTL("This isn't available in Simple Mode!"))
      return
    end
    recorded_teams_data = recorded_teams
    if recorded_teams_data[4].empty?
      pbMessage(_INTL("You don't have any teams recorded for the Gym Leader you are challenging!"))
    else
      choice = [_INTL("P, T"), _INTL("Only P"), _INTL("Only T"), _INTL("Normal"), _INTL("Explain"), _INTL("Cancel")]
      loop do
        index = pbMessage(_INTL("Which do you want to check?"), choice, -1)
        case index
        when -1, 5 # Cancel
          break
        when 4
          pbMessage(_INTL("You need to defeat the Gym Leader with {1} completely different teams to obtain the badge you are currently challenging.", rematch_times(recorded_teams_data[5])))
          pbMessage(_INTL("When you defeat the Gym Leader, if the team doesn't include any Pokémon that have been used before, your team will be recorded."))
          pbMessage(_INTL("You can view all recorded teams here, and you can also delete teams that are no longer needed."))
          pbMessage(_INTL("Additionally, P means Perfect, T means Tarot Amulet."))
        when 0
          break if choose_team(recorded_teams_data[0], recorded_teams_data[4])
        when 1
          break if choose_team(recorded_teams_data[1], recorded_teams_data[4])
        when 2
          break if choose_team(recorded_teams_data[2], recorded_teams_data[4])
        when 3
          break if choose_team(recorded_teams_data[3], recorded_teams_data[4])
        end
      end
    end
  end

  def self.choose_team(teams, recorded_teams)
    if teams.empty?
      pbMessage(_INTL("There aren't any teams!"))
      return false
    else
      team_names = []
      teams.size.times { |time| team_names << _INTL("Team {1}", time + 1) }
      loop do
        index = pbMessage(_INTL("Which team do you want to check?"), team_names, -1)
        return false if index < 0
        selected_team = teams[index]
        pbMessage(_INTL("The team includes {1}.", selected_team[:text]))
        if pbConfirmMessageSerious(_INTL("Do you want to delete this team?"))
          original_index = selected_team[:original_index]
          recorded_teams.delete_at(original_index)
          pbMessage(_INTL("The team has been deleted."))
          return true
        end
      end
    end
  end
end
  
class Player
  def gym_leader_rematch
    @gym_leader_rematch ||= GymLeaderRematch.new
  end
end

def postGymSnapshot(badge_num)
  postBattleTeamSnapshot(_INTL("Badge {1} Team_{2}", badge_num, generate_unique_id), true)
  return if TA.get(:simplemode)
  result = $Trainer.gym_leader_rematch.process(badge_num)
  if result[0]
    if badge_num == 8
      pbMessage(_INTL("You have defeated the 8th Gym Leader!\nNow you can challenge the Former Champions' teams in the Battle Loader.\nGood luck!"))
    end
  else
    if badge_num == 5 # Bence and Joe
      pbSetSelfSwitch(21, 'A', false)
    end
    pbReceiveItem(:EXPCANDYXL, badge_num)
    pbMessage(_INTL("You did great, but you still need to defeat me {1} more time(s).\nYou can't use the Pokémon you've already used and you can check the recorded teams with the Battle Loader.\nKeep it up!", GymLeaderRematch.rematch_times(badge_num) - result[1]))
    pbFadeOutIn { pbStartOver { |mapName| _INTL("\\w[]\\wm\\c[12]\\l[3]You returned to {1} with your Pokémon, hoping to quickly come up with a strategy to defeat the Gym Leader...", mapName) } }
    command_end
  end
end