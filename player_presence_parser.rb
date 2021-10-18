# frozen_string_literal: true

require "time"
require "sequel"

class PlayerPresenceParser
  REGEX_TIMESTAMP = /\d{4}(\.)\d{2}(\.)\d{2}(\-)\d{2}(\.)\d{2}(\.)\d{2}/.freeze # 2020.08.27-10.30.20
  REGEX_IPV4 = /(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/.freeze
  REGEX_PLAYER_ONLINE = /logged in/.freeze # $ is important, admin appends (as drone)
  # REGEX_ADMIN_ONLINE = /logged in \(as drone\)$/.freeze
  REGEX_STEAMID64 = /(?<steamid64>\d{17})/.freeze
  REGEX_IGN = /\d{17}:(?<=\:)((?<ign>.*?))(?=\()/.freeze
  REGEX_SCUMID_ONLINE = /\((?<scumid>\d+)\)/.freeze
  REGEX_SCUMID_OFFLINE = /\'(?<scumid>\d+)\'/.freeze

  DB = Sequel.connect("mysql2://username:password@host/database_name")

  def initialize(line)
    @line = line
  end

  def execute!
    timestamp = Time.strptime(@line.match(REGEX_TIMESTAMP).to_s, "%Y.%m.%d-%H.%M.%S")
    presence = @line.match?(REGEX_PLAYER_ONLINE) ? "online" : "offline"

    if presence == "online"
      scumid = @line.match(REGEX_SCUMID_ONLINE)[:scumid]
      steamid64 = @line.match(REGEX_STEAMID64)[:steamid64]
      ign = @line.match(REGEX_IGN)[:ign]

      # .first returns a hash so cannot call upadate, need to use sequel Models.
      user = DB[:users].where(steamId64: steamid64).first

      if user
        begin
          DB[:users]
            .where(steamId64: steamid64)
            .update(ign: ign, scumId: scumid, presence: "online", presenceUpdatedAt: timestamp)
        rescue Sequel::DatabaseError => error
          # Hack for invalid characters.
          DB[:users]
            .where(steamId64: steamid64)
            .update(scumId: scumid, presence: "online", presenceUpdatedAt: timestamp)
        end
      else
        begin
          DB[:users].insert(
            ign: ign,
            scumId: scumid,
            steamId64: steamid64,
            presence: "online",
            presenceUpdatedAt: timestamp,
          )
        rescue Sequel::DatabaseError => error
          # Hack for invalid characters.
          DB[:users].insert(
            scumId: scumid,
            steamId64: steamid64,
            presence: "online",
            presenceUpdatedAt: timestamp,
          )
        end
      end
    elsif presence == "offline"
      scumid = @line.match(REGEX_SCUMID_OFFLINE)[:scumid]

      # .first returns a hash so cannot call upadate, need to use sequel Models.
      user = DB[:users].where(scumId: scumid).first

      if user
        DB[:users]
          .where(scumId: scumid)
          .update(presence: "offline", presenceUpdatedAt: timestamp)
      else
        puts "Unable to find player (scumid=#{scumid})"
        puts @line
      end
    else
      puts "Something went wrong"
      puts @line
    end
  end
end
