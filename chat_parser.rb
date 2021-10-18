# frozen_string_literal: true

require "time"
require "sequel"

class ChatParser
  REGEX_GAMEVERSION = /Game version: (?<gameversion>\d+(\.\d+)*)/.freeze
  REGEX_TIMESTAMP = /\d{4}(\.)\d{2}(\.)\d{2}(\-)\d{2}(\.)\d{2}(\.)\d{2}/.freeze # 2020.08.27-10.30.20
  REGEX_CHAT = /'(?<context>Local|Global|Squad): (?<content>.*)'/.freeze
  REGEX_IDS = /'(?<steamid64>\d{17}):(?<=\:)((?<ign>.*?))(?=\()\((?<scumid>\d+)\)'/.freeze
  REGEX_MENTIONS = /admin(s?)|coderhulk|hulk|ilikewalruses|walrus|koalaa|cheat|exploit|#/i.freeze

  DB = Sequel.connect("mysql2://username:password@host/database_name")

  def initialize(line)
    @line = line
  end

  def execute!
    return unless valid_line?

    timestamp = Time.strptime(@line.match(REGEX_TIMESTAMP).to_s, "%Y.%m.%d-%H.%M.%S")
    _, context, content = *@line.match(REGEX_CHAT)
    _, steamid64, ign, scumid = *@line.match(REGEX_IDS)
    mention_admins = content.match?(REGEX_MENTIONS)

    if DB[:chats].where(sentAt: timestamp, context: context, content: content, authorSteamId64: steamid64).empty?
      DB[:chats].insert(
        sentAt: timestamp,
        context: context,
        content: content,
        authorSteamId64: steamid64,
        authorIgn: ign,
        authorScumId: scumid,
        mentionAdmins: mention_admins,
      )
    end
  end

  private

  def valid_line?
    !@line.to_s.strip.empty? && !@line.match?(REGEX_GAMEVERSION)
  end
end
