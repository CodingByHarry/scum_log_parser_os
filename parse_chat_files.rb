# frozen_string_literal: true

require_relative "./file_parser.rb"
require_relative "./chat_parser.rb"

class ParseChatFiles
  def initialize
    @files = Dir["logs/chat_*.log"].sort
  end

  def execute!
    @files.each do |filename|
      archive_on_completion = @files.last != filename # Leave most recent file in logs directory.
      parser = FileParser.new(filename, "chat.statefile", archive_on_completion)
      puts "Parsing #{filename}"
      parser.emit(&method(:parse_line))
    end
  end

  private

  def parse_line(line)
    ChatParser.new(line).execute!
  end
end
