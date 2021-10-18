# frozen_string_literal: true

require "sequel"

class ParseSquadMember
  REGEX_STEAMID64 = /SteamId: (?<steamid64>\d{17})/.freeze
  REGEX_STEAM_NAME = /SteamName: (?<steamname>.*)(?= CharacterName)/.freeze
  REGEX_CHAR_NAME = /CharacterName: (?<name>.*)(?= MemberRank)/.freeze
  REGEX_RANK = /MemberRank: (?<rank>\d{1,5})/.freeze

  DB = Sequel.connect("mysql2://username:password@host/database_name")

  def initialize(squad_name, squad_scumid, line)
    @line = line.strip
    @squad_name = squad_name
    @squad_scumid = squad_scumid
  end

  def execute!
    steamid64 = @line.match(REGEX_STEAMID64)[:steamid64]
    rank = @line.match(REGEX_RANK)[:rank]

    if DB[:users].where(steamId64: steamid64).empty?
      puts "Error: Unable to find player with steamid #{steamid64}"
    else
      DB[:users].where(steamId64: steamid64).update(
        squadScumId: @squad_scumid,
        squadRank: rank,
        squadUpdatedAt: Time.now.utc,
      )
    end
  end
end
