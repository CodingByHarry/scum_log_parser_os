# frozen_string_literal: true

require_relative "./parse_squad_header.rb"
require_relative "./parse_squad_member.rb"

class ParseSquadsFile
  def initialize
    @files = Dir["logs/squads_*.log"].sort
  end

  def execute!
    @files.each do |filename|
      puts "Parsing #{filename}"
      contents = File.open(filename).read
      contents.lines.slice_when do |record_before, record_after|
        record_before.strip.empty? && record_after.start_with?("[Squad")
      end.each(&method(:parse_squad))

      File.rename filename, "logs/_processed/#{File.basename(filename, ".*")}#{Time.now.uct.strftime("%H%m%S")}.log"
    end
  end

  private

  def parse_squad(lines)
    squad_name, squad_scumid = nil

    lines.each_with_index do |line, index|
      if index == 0
        squad_header = ParseSquadHeader.new(line).execute!
        squad_name = squad_header.name
        squad_scumid = squad_header.scumid
      elsif !line.strip.empty?
        ParseSquadMember.new(squad_name, squad_scumid, line).execute!
      end
    end
  end
end
