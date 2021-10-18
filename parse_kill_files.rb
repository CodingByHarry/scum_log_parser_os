# frozen_string_literal: true

require_relative "./file_parser.rb"
require_relative "./player_kill_parser.rb"

class ParseKillFiles
  def initialize
    @files = Dir["logs/kill_*.log"].sort
  end

  def execute!
    @files.each do |filename|
      archive_on_completion = @files.last != filename # Leave most recent file in logs directory.
      parser = FileParser.new(filename, "kill.statefile", archive_on_completion)
      puts "Parsing #{filename}"
      parser.emit(&method(:parse_line))
    end
  end

  private

  def parse_line(line)
    return unless line.include?(': {"Killer":{"ServerLocation"')

    PlayerKillParser.new(line).execute!
  end
end
