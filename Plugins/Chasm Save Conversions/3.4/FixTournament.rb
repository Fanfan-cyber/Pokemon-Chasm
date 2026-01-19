SaveData.register_conversion(:tournament_340) do
  game_version '3.4.0'
  display_title 'Updating saved Tournament data for 3.4.0 changes'
  to_all do |save_data|
    # TODO: When Tournament is moved out of GlobalMetadata, this will be in the same conversion to avoid conflicts
    save_data[:global_metadata].tournament.updateTrainerTypes()
  end
end
