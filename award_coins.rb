# frozen_string_literal: true

require "sequel"

COINS = 5

class AwardCoins
  DB = Sequel.connect("mysql2://username:password@host/database_name")

  def execute!
    DB["SELECT * FROM users WHERE presence = 'online'"].each do |row|
      next unless row[:discordId]

      DB[:users]
        .where(discordId: row[:discordId])
        .update(balance: row[:balance] + COINS)

      puts "#{row[:steamId64]} [#{row[:ign]}] (#{row[:scumId]}) received #{COINS} coins"
    end
  end
end
