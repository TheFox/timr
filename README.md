# Timr

Time Tracking for Hackers: CLI tool for tracking work hours.

Timr is a time tracking tool for the [Command-line](https://en.wikipedia.org/wiki/Command-line_interface) written in [Ruby](https://www.ruby-lang.org/). You can track your time spent for a specific project. I know. There are (too) many time tracking tools and such blabla you can use. The main focus of this tool is to use it on the Command-line and make automatic reports. I love the Command-line, so I want the terminal to handle as much as possible. I don't want programms with fancy UIs. Text-based is good enough. All data are stored in YAML files. So editing can also be done by using your favorite editor.

## Install

The preferred method of installation is via RubyGems.org:  
<https://rubygems.org/gems/timr>

	gem install timr

## Tasks

A Task can has a name and a description. A Task can has multiple Tracks. One Track can has only one Task as parent.

A Track is atomic. It's the smallest time unit. It's a time span presented by a begin date time and end date time. All date times are stored as UTC and converted temporary to your local timezone.

When a Track gets *continued* or *restarted* it's actual a copy using the same message.

## Projects

## Clients

It's recommended to put each client in a separate directory.

	$HOME/.timr/client1
	$HOME/.timr/client2
	$HOME/.timr/client3

Use `-C` to change the directory in which Timr should operate:

	timr -C "$HOME/.timr/client1"

## Commands

### Start Command

	timr start [<options>] [<task_id> [<track_id>]]

Options:

- `-n`, `--name`

	Track Name

### Status Command

### Push/Pop Command

	timr push

Sometimes you need to work on a task only temporary. You want to track the time for this as well. For example fixing a bug. When you fixed the bug you want to continue your actual work. Here comes `push` and `pop` into the game. It works like a stack. If you know [Git Stashing](https://git-scm.com/book/en/v1/Git-Tools-Stashing) it's very similar. But only for tasks. If you `push` a new task the below task will be paused. On `pop` the top task will be stopped and the next below will continued.

## API

- [API Reference Mainpage](https://timr.fox21.at/doc/)
- [Errors Inheritance Tree](https://timr.fox21.at/doc/TheFox/Timr/Error.html)

## Project Links

- [Timr Homepage](https://timr.fox21.at/)
- [Timr Code Coverage](https://timr.fox21.at/coverage/)
- [Timr Gem](https://rubygems.org/gems/timr)
- [Travis CI Repository](https://travis-ci.org/TheFox/timr)

## License

Copyright (C) 2016 Christian Mayer <https://fox21.at>

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
