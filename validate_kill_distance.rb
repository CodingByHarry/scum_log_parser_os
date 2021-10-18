# frozen_string_literal: true

require "time"
require "sequel"
require "bigdecimal"

class ValidateKillDistance
  DB = Sequel.connect("mysql2://username:password@host/database_name")

  def execute!
    DB["SELECT * FROM kills"].each do |kill|
      x1 = BigDecimal(kill[:killerServerX], 16)
      y1 = BigDecimal(kill[:killerServerY], 16)
      x2 = BigDecimal(kill[:victimServerX], 16)
      y2 = BigDecimal(kill[:victimServerY], 16)

      # Pythagorean distance calculation.
      # https://stackoverflow.com/questions/53802487/calculating-the-distance-between-two-random-points-in-a-c-battleship-game
      new_distance = (Integer.sqrt((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1)) / 100).round

      if new_distance.to_f != kill[:distance].to_f
        puts "##{kill[:id]} - New: #{new_distance} | Old: #{kill[:distance]}"
        # DB[:kills].where(id: kill[:id]).update(distance: new_distance)
      end
    end
  end
end

ValidateKillDistance.new.execute!
