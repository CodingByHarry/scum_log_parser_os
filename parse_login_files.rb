# frozen_string_literal: true

require_relative "./file_parser.rb"
require_relative "./player_presence_parser.rb"

class ParseLoginFiles
  def initialize
    @files = Dir["logs/login_*.log"].sort
  end

  def execute!
    @files.each do |filename|
      archive_on_completion = @files.last != filename # Leave most recent file in logs directory.
      parser = FileParser.new(filename, "login.statefile", archive_on_completion)
      puts "Parsing #{filename}"
      parser.emit(&method(:parse_line))
    end
  end

  private

  def parse_line(line)
    return unless line.match?(/logged in|logging out/)

    PlayerPresenceParser.new(line).execute!
  end
end
