# frozen_string_literal: true

require "fileutils"
require "net/ftp"
require "net/ftp/list"

class FetchFiles
  FTP_HOST = ""
  FTP_PORT = 28321
  FTP_USERNAME = ""
  FTP_PASSWORD = ""
  FTP_BASE_PATH = "SCUM/Saved/SaveFiles/Logs"

  attr_reader :type

  def initialize(type:)
    @type = type
  end

  def execute!
    FileUtils.rm_rf Dir.glob("logs/#{type}_*.log")

    ftp = Net::FTP.new(FTP_HOST, port: FTP_PORT)
    ftp.passive = true
    ftp.login FTP_USERNAME, FTP_PASSWORD

    ftp.list(FTP_BASE_PATH) do |list_entry|
      entry = Net::FTP::List.parse(list_entry)

      next unless entry.file?
      next unless entry.basename.start_with?("#{type}_")

      if !File.exists?("logs/_processed/#{entry.basename}")
        ftp.getbinaryfile("#{FTP_BASE_PATH}/#{entry.basename}", "logs/#{entry.basename}")
        puts "Downloaded #{entry.basename}"
      end
    end

    ftp.close

    puts ""
  end
end
