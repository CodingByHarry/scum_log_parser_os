#!/usr/bin/env ruby

require "rufus-scheduler"
require_relative "./fetch_files.rb"
require_relative "./parse_kill_files.rb"

scheduler = Rufus::Scheduler.new

scheduler.every "1m" do
  puts "=== [#{Time.now}] Fetch files ========================"
  FetchFiles.new(type: :kill).execute!

  puts "=== [#{Time.now}] Parse Kill Files ==================="
  ParseKillFiles.new.execute!
end

scheduler.join
