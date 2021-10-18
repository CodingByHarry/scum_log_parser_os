#!/usr/bin/env ruby

require "rufus-scheduler"
require_relative "./fetch_files.rb"
require_relative "./parse_login_files.rb"
require_relative "./award_coins.rb"

scheduler = Rufus::Scheduler.new

scheduler.every "1m" do
  puts "=== [#{Time.now}] Fetch files ========================"
  FetchFiles.new(type: :login).execute!

  puts "=== [#{Time.now}] Parse Login Files =================="
  ParseLoginFiles.new.execute!
end

scheduler.every "10m" do
  puts "=== [#{Time.now}] Award Coins ========================"

  AwardCoins.new.execute!
end

scheduler.join
