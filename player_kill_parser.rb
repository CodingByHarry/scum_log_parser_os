# frozen_string_literal: true

require "time"
require "json"
require "sequel"
require "bigdecimal"

class PlayerKillParser
  DB = Sequel.connect("mysql2://username:password@host/database_name")

  def initialize(line)
    @line = line
  end

  def execute!
    timestamp, entry = @line.split(": ", 2)
    timestamp = Time.strptime(timestamp, "%Y.%m.%d-%H.%M.%S")
    entry = JSON.parse(entry)

    killer_steamid64 = entry["Killer"]["UserId"]
    killer = DB[:users].where(steamId64: killer_steamid64).first || {}
    victim_steamid64 = entry["Victim"]["UserId"]
    victim = DB[:users].where(steamId64: victim_steamid64).first || {}
    weapon_parts = entry["Weapon"].split(" ")
    weapon_name = weapon_parts.first
    weapon_damage = weapon_parts.last.to_s.gsub("[", "").gsub("]", "")

    x1 = BigDecimal(entry["Killer"]["ServerLocation"]["X"], 16)
    y1 = BigDecimal(entry["Killer"]["ServerLocation"]["Y"], 16)
    x2 = BigDecimal(entry["Victim"]["ServerLocation"]["X"], 16)
    y2 = BigDecimal(entry["Victim"]["ServerLocation"]["Y"], 16)

    # Pythagorean distance calculation.
    # https://stackoverflow.com/questions/53802487/calculating-the-distance-between-two-random-points-in-a-c-battleship-game
    distance = (Integer.sqrt((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1)) / 100).round

    if DB[:kills].where(killerSteamId64: killer_steamid64, killerServerX: x1, victimSteamId64: victim_steamid64, victimServerX: x2, logTimestamp: timestamp).empty?
      DB[:kills].insert(
        killerUserId: killer.fetch(:id, nil),
        killerName: entry["Killer"]["ProfileName"],
        killerInEvent: entry["Killer"]["IsInGameEvent"],
        killerServerX: entry["Killer"]["ServerLocation"]["X"],
        killerServerY: entry["Killer"]["ServerLocation"]["Y"],
        killerServerZ: entry["Killer"]["ServerLocation"]["Z"],
        killerClientX: entry["Killer"]["ClientLocation"]["X"],
        killerClientY: entry["Killer"]["ClientLocation"]["Y"],
        killerClientZ: entry["Killer"]["ClientLocation"]["Z"],
        killerSteamId64: killer_steamid64,
        killerImmortal: entry["Killer"]["HasImmortality"],
        victimUserId: victim.fetch(:id, nil),
        victimName: entry["Victim"]["ProfileName"],
        victimInEvent: entry["Victim"]["IsInGameEvent"],
        victimServerX: entry["Victim"]["ServerLocation"]["X"],
        victimServerY: entry["Victim"]["ServerLocation"]["Y"],
        victimServerZ: entry["Victim"]["ServerLocation"]["Z"],
        victimClientX: entry["Victim"]["ClientLocation"]["X"],
        victimClientY: entry["Victim"]["ClientLocation"]["Y"],
        victimClientZ: entry["Victim"]["ClientLocation"]["Z"],
        victimSteamId64: victim_steamid64,
        weaponName: weapon_name,
        weaponDamage: weapon_damage,
        timeOfDay: entry["TimeOfDay"],
        logTimestamp: timestamp,
        distance: distance,
      )
    end
  end
end
