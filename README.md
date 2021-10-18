# SCUM Log Parser Bot

We created this bot for our own personal SCUM server and never intended to open source it. It was created in a way to just work for our setup with little regard for good principles and efficiency. Please keep this in mind when using it and make your own adjustments as needed.

There are 3 parts to this project
- [Discord Bot (this page)](https://github.com/CodingByHarry/scum_discord_bot_os)
- [Log Parser](https://github.com/CodingByHarry/scum_log_parser_os)
- [SCUM Game Bot](https://github.com/CodingByHarry/scum_game_bot_os)

## Getting started

Install Ruby 3.0.2

Go through each file and update the DB variable to contain the correct credentials. Sorry it's in a few places ...

Create services to run the following files
- run_chats.rb
- run_kills.rb
- run_rewards.rb
- run_squads.rb

Example service:

```sh
[Unit]
Description=Scumtopia Chat Logs Parser
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/servers/scum_log_parser/scum_log_parser
ExecStart=/root/.rbenv/bin/rbenv exec bundle exec ruby /root/servers/scum_log_parser/scum_log_parser/run_chats.rb
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Update `fetch_files.rb` with correct FTP credentials

## Contribute / Licensing / Credits
This bot is not to be used in a commercial scenario or for a profit driven server. This was released for other SCUM server owners to setup and use for free without being preasured in to paying for it by other SCUM bots. We would appreciate you crediting us (the authors) although not required.

Feel free to open a pull request if you think there are changes that should be made. I'll review them eventually.

Credits to [myself](https://github.com/CodingByHarry/) and [Daniel](https://github.com/danieldraper) as well as the SCUMTOPIA community for their support and testing.
