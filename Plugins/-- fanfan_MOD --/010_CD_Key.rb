module CDKey
  @@pkmn_cd_key = {}
  @@item_cd_key = {}
  @@other_key   = {}

  def self.register_pkmn_key(key, pkmn_hash)
    @@pkmn_cd_key[key.to_s.downcase.to_sym] = proc {
      if block_given?
        ret = yield
        next false unless ret
      end
      pkmn_hash.each do |pkmn, level|
        pbAddPokemon(pkmn, level)
      end
      next true
    }
  end

  def self.register_item_key(key, items_hash)
    @@item_cd_key[key.to_s.downcase.to_sym] = proc {
      if block_given?
        ret = yield
        next false unless ret
      end
      items_hash.each do |item, quantity|
        pbReceiveItem(item, quantity)
      end
      next true
    }
  end

  def self.register_other_key(key, value = true)
    key = [key.to_s.downcase.to_sym] unless key.is_a?(Array)
    @@other_key[key[0]] = proc { |condition_check|
      if block_given?
        ret = yield
        next false unless ret
      end
      TA.set(key[-1], value) unless condition_check
      next true
    }
  end

  def self.enter_cd_key
    text = pbEnterText(_INTL("Enter a code."), 0, 30).downcase.to_sym
    return if text.empty?
    valid_code = false
    if @@pkmn_cd_key.key?(text)
      valid_code = true
      if $Trainer.gift_code[:pkmn].include?(text)
        pbMessage(_INTL("The code has been used!"))
      else
        ret = @@pkmn_cd_key[text]&.call
        if ret
          $Trainer.gift_code[:pkmn] << text
        else
          pbMessage(_INTL("You can't use the code now!"))
        end
      end
    end
    if @@item_cd_key.key?(text)
      valid_code = true
      if $Trainer.gift_code[:item].include?(text)
        pbMessage(_INTL("The code has been used!"))
      else
        ret = @@item_cd_key[text]&.call
        if ret
          $Trainer.gift_code[:item] << text
        else
          pbMessage(_INTL("You can't use the code now!"))
        end
      end
    end
    if @@other_key.key?(text)
      valid_code = true
      ret = @@other_key[text]&.call
      if ret
        if text == :customtypechart
          HotTest.load_custom_type_chart
        elsif text == :customtribethresh
          params = ChooseNumberParams.new
          params.setRange(1, 5)
          params.setDefaultValue(5)
          newthresh = pbMessageChooseNumber(_INTL("Set new Tribe threshold."), params)
          TA.set(:customtribethresh, newthresh)
        elsif text == :customrevivalturn
          params = ChooseNumberParams.new
          if pbConfirmMessage(_INTL("Single battle? Or others?"))
            params.setRange(9, 15)
            params.setDefaultValue(Settings::FAINT_HEALING_TURN)
            newturns = pbMessageChooseNumber(_INTL("Set new Revival Turns."), params)
            TA.set(:customrevivalturnsingle, newturns)
          else
            params.setRange(3, 9)
            params.setDefaultValue(Settings::FAINT_HEALING_TURN_DOULBE)
            newturns = pbMessageChooseNumber(_INTL("Set new Revival Turns."), params)
            TA.set(:customrevivalturndouble, newturns)
          end
        end
      else
        pbMessage(_INTL("You can't use the code now!"))
      end
    end
    if automatic_generated_pkmn(text)
      valid_code = true
    end
    if automatic_generated_item(text)
      valid_code = true
    end
    pbMessage(_INTL("Please enter a valid code!")) unless valid_code
  end

  def self.check_code(code)
    data_part = code[4..-1]
    return false if data_part.length < 7
    letter_checksum = data_part[-2..-1].downcase
    return false unless letter_checksum.match?(/^[a-z]{2}$/i)
    checksum_str = data_part[-4...-2]
    return false unless checksum_str.match?(/^\d{2}$/)
    checksum = checksum_str.to_i
    level_str = data_part[-6...-4]
    return false unless level_str.match?(/^\d{2}$/)
    level = level_str.to_i
    return false if level < 1 || level > MAX_LEVEL_CAP
    name_part = data_part[0...-6].upcase.to_sym
    return false if name_part.empty?
    calculated_checksum = name_part.length + level
    return false unless checksum == calculated_checksum
    expected_letters = checksum_str.chars.map do |digit|
      # 1->a, 2->b, ..., 9->i, 0->j
      if digit == '0'
        'z'
      else
        ('a'.ord + digit.to_i - 1).chr
      end
    end
    return false unless letter_checksum == expected_letters.join
    return name_part, level
  end

  def self.automatic_generated_pkmn(code)
    return false unless code.start_with?("pkmn")
    result = check_code(code)
    return false unless result
    pkmn, level = result

    species_data = GameData::Species.try_get(pkmn)
    return unless species_data

    pbAddPokemon(species_data, level)
    return true
  end

  def self.automatic_generated_item(code)
    return false unless code.start_with?("item")
    result = check_code(code)
    return false unless result
    item, amount = result

    item_data = GameData::Item.try_get(item)
    return false unless item_data

    pbReceiveItem(item_data, amount)
    return true
  end

  UNUSED_CODE = %i[adaptiveai nocopymon whosyourdaddy]
  CHECK_CODE  = %i[disableperfect]
  def self.clear_unused_code
    UNUSED_CODE.each { |code| TA.set(code, false) }
    CHECK_CODE.each do |code|
      ret = @@other_key[code]&.call(true)
      TA.set(code, false) unless ret
    end
  end
end

CDKey.register_other_key(:debugger, true)

CDKey.register_other_key(:maxmoney, true)

CDKey.register_other_key(:infinitehp, true)
CDKey.register_other_key([:noinfinitehp, :infinitehp], false)
CDKey.register_other_key(:immunestatus, true)
CDKey.register_other_key([:noimmunestatus, :immunestatus], false)
CDKey.register_other_key(:hugepower, true)
CDKey.register_other_key([:nohugepower, :hugepower], false)
CDKey.register_other_key(:guaranteedeffects, true)
CDKey.register_other_key([:noguaranteedeffects, :guaranteedeffects], false)
CDKey.register_other_key(:guaranteedcrit, true)
CDKey.register_other_key([:noguaranteedcrit, :guaranteedcrit], false)
CDKey.register_other_key(:alltribes, true)
CDKey.register_other_key([:disablealltribes, :alltribes], false)
CDKey.register_other_key(:notribecopy, true)
CDKey.register_other_key([:disablenotribecopy, :notribecopy], false)

CDKey.register_other_key(:customtypechart)
CDKey.register_other_key(:customtribethresh)
CDKey.register_other_key(:customrevivalturn)

CDKey.register_other_key(:rocket, true)
CDKey.register_other_key([:norocket, :rocket], false)
CDKey.register_other_key(:zeroexp, true)
CDKey.register_other_key([:disablezeroexp, :zeroexp], false)
CDKey.register_other_key(:monoabil, true)
CDKey.register_other_key([:disablemonoabil, :monoabil], false)
CDKey.register_other_key(:customabil, true)
CDKey.register_other_key([:nocustomabil, :customabil], false)
CDKey.register_other_key(:doublebattle, true)
CDKey.register_other_key([:disabledouble, :doublebattle], false)
CDKey.register_other_key(:inversebattle, true)
CDKey.register_other_key([:noinversebattle, :inversebattle], false)
CDKey.register_other_key(:disableperfect, true) { next $Trainer&.checkBadge(1) }
CDKey.register_other_key([:enableperfect, :disableperfect], false)
CDKey.register_other_key(:simplemode, true) { next $Trainer&.checkBadge(1) }
CDKey.register_other_key([:normalmode, :simplemode], false)

CDKey.register_other_key(:speedup, true)
CDKey.register_other_key([:disablespeedup, :speedup], false)
CDKey.register_other_key(:freetarotamulet, true)
CDKey.register_other_key([:nofreetarotamulet, :freetarotamulet], false)
CDKey.register_other_key(:shuffledisplay, true)
CDKey.register_other_key([:noshuffledisplay, :shuffledisplay], false)
#CDKey.register_other_key(:disablerevive, true) { next $Trainer&.checkBadge(1) }
CDKey.register_other_key(:disablerevive, true)
CDKey.register_other_key([:battlerevive, :disablerevive], false)
CDKey.register_other_key(:enablelegendary, true)
CDKey.register_other_key([:disablelegendary, :enablelegendary], false)
CDKey.register_other_key(:copywhatever, true)
CDKey.register_other_key([:nocopywhatever, :copywhatever], false)
CDKey.register_other_key(:stupidai, true)
CDKey.register_other_key([:smartai, :stupidai], false)
CDKey.register_other_key(:revengeplus, true)
CDKey.register_other_key([:norevengeplus, :revengeplus], false)
CDKey.register_other_key(:opposingalwaysresting, true)
CDKey.register_other_key([:noalwaysresting, :opposingalwaysresting], false)

#CDKey.register_other_key(:adaptiveai, true)
#CDKey.register_other_key(:whosyourdaddy, true)
#CDKey.register_other_key([:nodaddy, :whosyourdaddy], false)
#CDKey.register_other_key(:nocopymon, true)
#CDKey.register_other_key([:copymonagain, :nocopymon], false)

CDKey.register_pkmn_key(:hyena1,    { :PIKACHU => 1  })
CDKey.register_pkmn_key(:psyduck10, { :PORYGON => 10 })
CDKey.register_pkmn_key(:alien1,    { :DEOXYS  => 1  }) { next $Trainer&.checkBadge(4) }

CDKey.register_item_key(:pokeball5,  { :POKEBALL   => 5   })
CDKey.register_item_key(:candyxl700, { :EXPCANDYXL => 700 }) { next $Trainer&.checkBadge(7) }

CDKey.register_item_key(:stylingkit,   { :STYLINGKIT   => 1 })
CDKey.register_item_key(:boxlink,      { :BOXLINK      => 1 })
CDKey.register_item_key(:omnidrive,    { :OMNIDRIVE    => 1 })
CDKey.register_item_key(:noisemachine, { :NOISEMACHINE => 1 })
CDKey.register_item_key(:packed,       { :STYLINGKIT   => 1, :BOXLINK => 1, :OMNIDRIVE => 1, :NOISEMACHINE => 1 })