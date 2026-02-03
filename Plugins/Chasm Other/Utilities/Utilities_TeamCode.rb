require 'stringio'

# Bytes required enum
module BytesRequired
  U8 = 1
  U16 = 2
  U32 = 4
end

POKE_PARTY_FORMAT_VERSION = 1
VERSION_BYTES = 4

# Byte protocol shift
ENCODING_SHIFT = 5 # The first 5 bits are reserved (unused in the new format, they represent the major version in the old one)
VERSION_MAJOR_SHIFT = 0
VERSION_MINOR_SHIFT = 5
VERSION_PATCH_SHIFT = 10
VERSION_DEV_SHIFT = 15 # End of header, not repeated - u16
STYLE_HP_SHIFT = 0
STYLE_ATK_SHIFT = 5
STYLE_DEF_SHIFT = 10
STYLE_SDEF_SHIFT = 15
STYLE_SPEED_SHIFT = 20
LEVEL_SHIFT = 25 # Stats and style points fit into one u32
POKEMON_MAPPED_ID_SHIFT = 0
ABILITY_MAPPED_ID_SHIFT = 13
MOVE1_LOWER_7BITS_MAPPED_ID_SHIFT = 25 # First u32
MOVE1_UPPER_6BITS_MAPPED_ID_SHIFT = 0
MOVE2_MAPPED_ID_SHIFT = 6
MOVE3_MAPPED_ID_SHIFT = 19 # Second u32
MOVE4_MAPPED_ID_SHIFT = 0
ITEM1_MAPPED_ID_SHIFT = 13
FORM_SHIFT = 22
FLAG_ITEM2_SHIFT = 30
FLAG_ITEM1_TYPE_SHIFT = 31 # Third u32

# Byte protocol masks
OLD_CODE_CHECK_MASK = 0x1f
ENCODING_MASK = 0xe0
VERSION_DEV_MASK = 0b1 << VERSION_DEV_SHIFT # End of header, not repeated - u16
STYLE_HP_MASK = 0b11111 << STYLE_HP_SHIFT
STYLE_ATK_MASK = 0b11111 << STYLE_ATK_SHIFT
STYLE_DEF_MASK = 0b11111 << STYLE_DEF_SHIFT
STYLE_SDEF_MASK = 0b11111 << STYLE_SDEF_SHIFT
STYLE_SPEED_MASK = 0b11111 << STYLE_SPEED_SHIFT
LEVEL_MASK = 0b1111111 << LEVEL_SHIFT
POKEMON_MAPPED_ID_MASK = 0x1fff << POKEMON_MAPPED_ID_SHIFT
ABILITY_MAPPED_ID_MASK = 0xfff << ABILITY_MAPPED_ID_SHIFT
MOVE1_LOWER_7BITS_MAPPED_ID_MASK = 0x7f << MOVE1_LOWER_7BITS_MAPPED_ID_SHIFT
MOVE1_UPPER_6BITS_MAPPED_ID_MASK = 0x3f << MOVE1_UPPER_6BITS_MAPPED_ID_SHIFT
MOVE2_MAPPED_ID_MASK = 0x1fff << MOVE2_MAPPED_ID_SHIFT
MOVE3_MAPPED_ID_MASK = 0x1fff << MOVE3_MAPPED_ID_SHIFT
MOVE4_MAPPED_ID_MASK = 0x1fff << MOVE4_MAPPED_ID_SHIFT
ITEM1_MAPPED_ID_MASK = 0x1ff << ITEM1_MAPPED_ID_SHIFT
FORM_MASK = 0xf << FORM_SHIFT
FLAG_ITEM2_MASK = 0x1 << FLAG_ITEM2_SHIFT
FLAG_ITEM1_TYPE_MASK = 0x1 << FLAG_ITEM1_TYPE_SHIFT

def load_team_code()
  code = encode_team($Trainer.party)
  domain = Settings::DEV_VERSION ? "tectonic-dev" : "tectonic"
  System.launch("https://#{domain}.alphakretin.com/teambuilder?team=#{code}")
  pbMessage(_INTL("Pokémon team opened in team builder website."))
end

# Encodes the string id as (num chars (u8)) (u8 value 1, 2, 3...)
def encode_string_id(id, u8s)
  id_str = id.to_s
  u8s.push(id_str.length)
  id_str.each_byte { |byte| u8s.push(byte) }
end

# Encodes style points and level into a u32
def encode_stats(mon)
  sp = mon.ev
  stats = 0
  stats |= (sp[:HP] << STYLE_HP_SHIFT) & STYLE_HP_MASK
  stats |= (sp[:ATTACK] << STYLE_ATK_SHIFT) & STYLE_ATK_MASK
  stats |= (sp[:DEFENSE] << STYLE_DEF_SHIFT) & STYLE_DEF_MASK
  stats |= (sp[:SPECIAL_DEFENSE] << STYLE_SDEF_SHIFT) & STYLE_SDEF_MASK
  stats |= (sp[:SPEED] << STYLE_SPEED_SHIFT) & STYLE_SPEED_MASK
  stats |= (mon.level << LEVEL_SHIFT) & LEVEL_MASK
  return stats
end

def encode_team(party)
  buffer = StringIO.new

  # Header
  poke_party_encoding_u8 = 0 # Encoding is always 0 in this context
  poke_party_version_u8 = POKE_PARTY_FORMAT_VERSION
  version_split = Settings::GAME_VERSION.split(".")
  version_u16 = Settings::DEV_VERSION ? VERSION_DEV_MASK : 0
  version_u16 |= (version_split[0].to_i & 0x1f) << VERSION_MAJOR_SHIFT
  version_u16 |= (version_split[1].to_i & 0x1f) << VERSION_MINOR_SHIFT
  version_u16 |= (version_split[2].to_i & 0x1f) << VERSION_PATCH_SHIFT

  data = [
    [poke_party_encoding_u8, BytesRequired::U8],
    [poke_party_version_u8, BytesRequired::U8],
    [version_u16, BytesRequired::U16]
  ]

  party.each do |mon|
    next if mon.nil?

    has_1_item = mon.items.length >= 1 && !mon.items[0].nil?
    has_2_items = mon.items.length == 2 && !mon.items[1].nil?
    stats_u32 = encode_stats(mon)

    u8s = []
    encode_string_id(mon.species, u8s)
    encode_string_id(GameData::Ability.get(mon.ability).id, u8s)
    encode_string_id(has_1_item ? mon.items[0] : "", u8s)
    encode_string_id(mon.itemTypeChosen || "", u8s)
    encode_string_id(has_2_items ? mon.items[1] : "", u8s)
    mon.moves.each do |move|
      encode_string_id(move ? move.id : "", u8s)
    end
    # Pad moves if less than 4
    (4 - mon.moves.length).times { encode_string_id("", u8s) } if mon.moves.length < 4
    u8s.push(mon.form)

    u8s.each { |x| data.push([x, BytesRequired::U8]) }
    data.push([stats_u32, BytesRequired::U32])
  end

  # Write data to buffer
  data.each do |value, bytes_required|
    case bytes_required
    when BytesRequired::U8
      buffer.write([value].pack('C'))
    when BytesRequired::U16
      buffer.write([value].pack('n'))
    when BytesRequired::U32
      buffer.write([value].pack('N'))
    end
  end

  # Convert to URL-safe base64
  code = [buffer.string].pack('m0')
  code.gsub!("+", "-")
  code.gsub!("/", "_")
  code.gsub!("=", "")

  return code
end