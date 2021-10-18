# frozen_string_literal: true

class FileParser
  def initialize(path, statefile, archive_on_completion = false)
    @path = path
    @log = File.open(path, "r:UTF-16LE:UTF-8")
    @statefile = statefile
    @archive_on_completion = archive_on_completion
    @lines_to_skip = File.open(@statefile) {|f| f.readline.to_i} rescue 0
  end

  def emit(&block)
    @log.each_line do |line|
      next if @log.lineno <= @lines_to_skip.to_i && !@archive_on_completion

      yield line
    end

    if @archive_on_completion
      File.delete(@statefile) if File.exist?(@statefile)
      File.rename @path, "logs/_processed/#{File.basename(@path)}"
    else
      File.open(@statefile, "w") {|f| f.write(@log.lineno)}
    end
  end
end
