module SaveData
  def self.get_data_from_file(file_path)
    validate file_path => String
    encrypted_data = File.read(file_path)
    Marshal.restore(Zlib::Inflate.inflate(encrypted_data.unpack("m")[0]))
  end

  def self.read_from_file(file_path, convert = false)
    validate file_path => String
    save_data = get_data_from_file(file_path)
    save_data = to_hash_format(save_data) if save_data.is_a?(Array)
    save_data[:mod_version] = "0.0.1" unless save_data[:mod_version]
    outdated = (PluginManager.compare_versions(save_data[:mod_version], MOD_VERSION) < 0) || $DEBUG
    # Updating to a new version
    #if convert && !save_data.empty? && PluginManager.compare_versions(save_data[:game_version], Settings::GAME_VERSION) < 0
    if convert && !save_data.empty? && outdated
      save_data[:mod_version] = MOD_VERSION
      if run_conversions(save_data, file_path)
        encrypted_data = [Zlib::Deflate.deflate(Marshal.dump(save_data))].pack("m")
        File.open(file_path, "wb") { |file| file.write(encrypted_data) }
      end
      if removeIllegalElementsFromAllPokemon(save_data) || outdated
        encrypted_data = [Zlib::Deflate.deflate(Marshal.dump(save_data))].pack("m")
        File.open(file_path, "wb") { |file| file.write(encrypted_data) }
      end
    end
    return save_data
  end

  def self.save_to_file(file_path)
    validate file_path => String
    save_data = self.compile_save_hash
    encrypted_data = [Zlib::Deflate.deflate(Marshal.dump(save_data))].pack("m")
    File.open(file_path, "wb") { |file| file.write(encrypted_data) }
  end

  def self.save_backup(file_path)
    validate file_path => String
    save_data = self.compile_save_hash
    encrypted_data = [Zlib::Deflate.deflate(Marshal.dump(save_data))].pack("m")
    File.open(file_path + ".bak", 'wb') { |file| file.write(encrypted_data) }
  end

  def self.run_conversions(save_data, filePath = nil)
    validate save_data => Hash
    conversions_to_run = self.get_conversions(save_data)
    return false if conversions_to_run.none?
    filePath = SaveData::FILE_PATH unless filePath
    encrypted_data = [Zlib::Deflate.deflate(Marshal.dump(save_data))].pack("m")
    File.open(filePath + '.bak', 'wb') { |file| file.write(encrypted_data) }
    echoln "Running #{conversions_to_run.length} conversions..."
    conversions_to_run.each do |conversion|
      echo "#{conversion.title}..."
      conversion.run(save_data)
      echoln ' done.'
    end
    echoln '' if conversions_to_run.length > 0
    save_data[:essentials_version] = Essentials::VERSION
    save_data[:game_version] = Settings::GAME_VERSION
    save_data[:mod_version] = MOD_VERSION
    return true
  end
end

module AntiAbuse
  DEBUG_PASSWORD  = "12138"
  PROMISE_CLAIM   = ["I promise", "我保证"]
  GAME_OFFICIAL   = %w[宝可饭堂 pokefans 地震啦！！！ 493645591].freeze
  GO_SOURCE_CHECK = false
  OFFICIAL_SITE   = "https://bbs.pokefans.xyz/threads/598/"
  CHEAT_CLASS     = [:CheatItemsAdapter, :ScreenCheat_Items, :SceneCheat_Items, :Scene_Cheat, :Window_GetItem, :PokemonLoad].freeze
  CHEAT_METHOD    = [:pbenabledebug, :pbDebugMenu]
  CHEAT_PROCESS   = %w[nw.exe cheatengine-i386.exe cheatengine-x86_64.exe cheatengine-x86_64-SSE4-AVX2.exe GearNT.exe].freeze
  FILES_TO_DELETE = ["Saves", "Achievements.dat", "Time Capsule.dat"].freeze
  @@debug_control = false

  def self.print_update_log
    file = File.open("release_version.txt", "wb")
    file.write(Settings::GAME_VERSION)
    file.close
    return unless is_chinese?
    file = File.open("release_version_mod.txt", "wb")
    file.write(CHANGE_LOG)
    file.close
    PokeBattle_Battle::Field.print_field_effect_manual
  end

  def self.apply_anti_abuse
    check_path
    debug_check
  end

  def self.debug_check
    kill_windows_shit
    kill_joiplay_shit
    debug_passcode
  end

  def self.debug_passcode
    return if !$DEBUG || @@debug_control
    password = pbEnterText(_INTL("Enter Debug Password."), 0, 32)
    exit if password != DEBUG_PASSWORD
    @@debug_control = true
  end

  def self.get_promise
    is_chinese? ? PROMISE_CLAIM[1] : PROMISE_CLAIM[0]
  end

  def self.check_promise
    pbMessage(_INTL("This game is not welcome to anyone who has attacked any fan-made games in any way.\nIf you have done so and still believe you have done nothing wrong, please close the game directly by clicking the top-right corner."))
    pbMessage(_INTL("If you have not done so, or have done so but have realized your mistake and promise not to do it again, please enter the full text of \"<imp>{1}</imp>\".", get_promise))
    if is_chinese?
      $Options.textinput = 0 if pbConfirmMessage(_INTL("Do you want to enter with cursor?"))
    end
    password = pbEnterText(_INTL("Enter your Promise."), 0, 32)
    exit if password != get_promise
  end

  def self.check_claim
    return if TA.get(:quit_to_menu)
    TA.set(:quit_to_menu, false)
    unless GO_SOURCE_CHECK
      pbMessage(_INTL("This mod was created by Fanfan.\nIf you paid for it, you've been duped!"))
      pbMessage(_INTL("This mod is a hardcore game with extensive adjustments, and is not suitable for players with immature psychological age or non-hardcore gaming enthusiasts. Please be advised."))
      pbMessage(_INTL("If you encounter difficulties, you can join QQ group 493645591 for help!\nYou can also check the release_version_mod.txt file in the game folder for a basic introduction, available passwords, and complete update history!"))
      pbMessage(_INTL("This may be the hardest game you've ever played, but I assure you, it's also the most interesting and most balanced game you've ever played!"))
      check_promise
      pbMessage(_INTL("Have a good run!"))
      return
    end
    if pbConfirmMessageSerious(_INTL("Did you download the game from the official post?"))
      pbMessage(_INTL("Please enter the post where you downloaded the game. (Website or QQ group)"))
      forum = pbEnterText(_INTL("Enter the right post."), 0, 32)
      exit unless GAME_OFFICIAL.include?(forum)
      return
    end
    System.launch(OFFICIAL_SITE) if pbConfirmMessage(_INTL("Would you like to re-download the game from the official post?"))
    exit
  end

  def self.kill_windows_shit
    #echoln("Check.")
    #exit unless windows?
    return unless windows?
    CHEAT_PROCESS.each do |process_name|
      next unless process_exists?(process_name)
      #punishment_deletion
      exit
    end
  end

  def self.punishment_deletion
    deleted_count = 0
    FILES_TO_DELETE.each do |file|
      path = File.join(Dir.pwd, file)
      if File.exist?(path)
        begin
          if File.directory?(path)
            delete_directory(path)
            deleted_count += 1
          else
            File.delete(path)
            deleted_count += 1
          end
        rescue => e
          puts "[ANTI-CHEAT] Failed to Delete: #{path} - #{e.message}"
        end
      end
    end
    deleted_count
  end

  def self.delete_directory(dir_path)
    Dir.each_child(dir_path) do |entry|
      full_path = File.join(dir_path, entry)
      if File.directory?(full_path)
        delete_directory(full_path)
      else
        File.delete(full_path)
      end
    end
    Dir.delete(dir_path)
  end

  require 'win32ole'
  def self.process_exists?(process_name)
    wmi = WIN32OLE.connect("winmgmts://")
    processes = wmi.ExecQuery("SELECT * FROM Win32_Process WHERE Name = '#{process_name}'")
    return processes.count != 0
  end

  def self.check_path
    current_path = Dir.pwd
    if current_path.include?("/AppData/Local/Temp")
      pbMessage(_INTL("Warning: Do not run the game from the ZIP file directly.\nPlease extract all files before launching."))
      exit
    end
  end

  def self.kill_joiplay_shit
    #exit if $CHEAT
    #exit if $CHEATS
    $CHEAT  = false
    $CHEATS = false
  end

  def self.kill_all_cheats
    rewrite_cheat_method
    CHEAT_CLASS.each { |klass| kill_cheat_klass(klass) }
    exit if $wtw
    $wtw = false
  end

  def self.kill_cheat_klass(klass_name)
    return unless Object.const_defined?(klass_name)
    Object.send(:remove_const, klass_name)
  end

  def self.rewrite_cheat_method
    CHEAT_CLASS.each do |klass_name|
      next unless Object.const_defined?(klass_name)
      klass = Object.const_get(klass_name)
      klass.define_method(:initialize) { exit }
    end
    CHEAT_METHOD.each { |method| define_method(method) { exit } }
  end

  def self.windows?
    [/win/i, /mingw/i, /mswin/i].any? { |regex| regex.match?(RUBY_PLATFORM) }
  end
end