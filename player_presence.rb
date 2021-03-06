# frozen_string_literal: true

require "time"
require "sequel"

REGEX_VALID_LINE = /logged in|logging out/.freeze
REGEX_TIMESTAMP = /\d{4}(\.)\d{2}(\.)\d{2}(\-)\d{2}(\.)\d{2}(\.)\d{2}/.freeze # 2020.08.27-10.30.20
REGEX_IPV4 = /(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/.freeze
REGEX_PLAYER_ONLINE = /logged in$/.freeze
REGEX_ADMIN_ONLINE = /logged in \(as drone\)$/.freeze
REGEX_OFFLINE = /logging out$/.freeze
REGEX_STEAMID64 = /\d{17}/.freeze
REGEX_SCUMID = /\'(?<scumid>\d+)\'|\((?<scumid>\d+)\)/.freeze # '1' - Logging out and (1) - Logging in

class PlayerPresence
  DB = Sequel.connect("mysql2://username:password@host/database_name")

  def execute!
    players = {}

    # Parse and prepare data from logs.
    Dir["logs/login_*.log"].each do |filename|
      File.open(filename).each do |raw_line|
        line = raw_line.gsub(" ", "").force_encoding("ASCII-8BIT")

        next unless line.match?(REGEX_VALID_LINE)

        timestamp = Time.strptime(line.match(REGEX_TIMESTAMP).to_s, "%Y.%m.%d-%H.%M.%S").to_i
        presence = line.match?(REGEX_PLAYER_ONLINE) ? :online : :offline
        scumid = line.match(REGEX_SCUMID)[:scumid].to_s
        steamid64 = line.match(REGEX_STEAMID64).to_s

        players[scumid] ||= {steamid64: steamid64, entries: []}
        players[scumid][:entries] << {timestamp: timestamp, presence: presence.to_s}
      end
    end

    # Determine which players are online and award them X coins.
    players.each do |scumid, player|
      player[:entries].sort_by! {|entry| entry[:timestamp]}

      entry = player[:entries].last

      DB[:users]
        .where(steamid64: player[:steamid64])
        .update(scumId: scumid, presence: entry[:presence].to_s)

      print "."
    end
    puts ""
  end
end
