# frozen_string_literal: true

require "sequel"

class ParseSquadHeader
  SquadHeader = Struct.new(:name, :scumid)

  REGEX_SQUAD_ID = /SquadId: (?<id>\d{1,5})/.freeze
  REGEX_SQUAD_NAME = /SquadName: (?<name>.*)(?=\])/.freeze

  DB = Sequel.connect("mysql2://username:password@host/database_name")

  def initialize(line)
    @line = line
  end

  def execute!
    id = @line.match(REGEX_SQUAD_ID)[:id]
    name = @line.match(REGEX_SQUAD_NAME)[:name]

    if DB[:squads].where(scumid: id).empty?
      DB[:squads].insert(scumid: id, name: name)
    else
      DB[:squads].where(scumid: id).update(name: name)
    end

    SquadHeader.new(name, id)
  end
end
