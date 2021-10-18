#!/usr/bin/env ruby

require "rufus-scheduler"
require_relative "./fetch_files.rb"
require_relative "./parse_chat_files.rb"

scheduler = Rufus::Scheduler.new

scheduler.every "1m" do
  puts "=== [#{Time.now}] Fetch files ========================"
  FetchFiles.new(type: :chat).execute!

  puts "=== [#{Time.now}] Parse Chat Files ==================="
  ParseChatFiles.new.execute!
end

scheduler.join
