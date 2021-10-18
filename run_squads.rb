#!/usr/bin/env ruby

require "rufus-scheduler"
require_relative "./fetch_files.rb"
require_relative "./parse_squads_file.rb"

scheduler = Rufus::Scheduler.new

scheduler.every "1m" do
  puts "=== [#{Time.now}] Fetch files ========================"
  FetchFiles.new(type: :squads).execute!

  puts "=== [#{Time.now}] Parse Squads File =================="
  ParseSquadsFile.new.execute!
end

scheduler.join
