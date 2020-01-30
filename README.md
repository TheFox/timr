# Timr

Timr is a time tracking tool for the [Command-line](https://en.wikipedia.org/wiki/Command-line_interface), written in [Ruby](https://www.ruby-lang.org/). You can track your time spent for a specific project. I know, there are (too) many time tracking tools and such blabla you can use. The main focus of this tool is to use it on the Command-line and make automatic reports. I love the Command-line, so I want the terminal to handle as much as possible. I don't want programs with fancy UIs. Text-based is good enough. All data are stored in YAML files. So editing can also be done by using your favorite editor.

## Project Outlines

The project outlines as described in my blog post about [Open Source Software Collaboration](https://blog.fox21.at/2019/02/21/open-source-software-collaboration.html).

- The main purpose of this software is to track time.
- It could be also an invoice generator. Track times for clients and generate invoices out of that.
- This list is open. Feel free to request features.

## Install

You can either install Timr via [RubyGems.org](https://rubygems.org/gems/timr) or from [source](https://github.com/TheFox/timr).

## Install via RubyGems.org

The preferred method of installation is via RubyGems.org:  
<https://rubygems.org/gems/timr>

```bash
gem install timr
```

## Install from Source

1. Clone `git clone https://github.com/TheFox/timr.git && cd timr`.
2. Run `./bin/install.sh`. This creates the `timr` gem local and installs it.

## Get Started

The simplest thing you can do after installation is start a new Task:

```bash
timr start
```

And after some time you probably want to stop:

```bash
timr stop
```

To show the current status:

```bash
timr status
```

## Task

A Task can have a name, a description, an estimation and many more. A Task can have multiple Tracks. One Track can have only one Task as parent. So a Task represents a collection of Tracks.

## Track

A Track is atomic. It's the smallest time unit. This is where the time comes from. It's a time span presented by a begin date time and end date time. All date times are stored as UTC and converted temporary to your local timezone.

## Stack

The Stack holds Tracks. If you know [Git Stashing](https://git-scm.com/book/en/v1/Git-Tools-Stashing) it's very similar. Just for Tracks. The most recent Track is sometimes called the *Top Track*. It's either the current running Track or on `pause` the latest ran Track.

When first starting a new Task, a new Track will be created and pushed to the Stack. When running the Stop command this Task will be removed from the Stack.

You can push another Track to the Stack by running the Push command. It is like the Start command but without removing the previous Track from the Stack. The Push and Pop command is helpful when you need to work temporary on another Task. When running the Pop command the Top Track will be stopped and removed from the Stack. Further, the next Track on the Stack will continue immediately.

## Clients

It's recommended to put each client in a separate directory.

```
$HOME/.timr/client1
$HOME/.timr/client2
$HOME/.timr/client3
```

Use `-C` to change the directory in which Timr should operate:

```bash
timr -C "$HOME/.timr/client1"
```

Default:

```
$HOME/.timr/defaultc
```

## Commands

See `timr <command> --help` to read details about a specific command, or `timr help <command>` to open the man page for this command.

The man pages are also available online: <https://timr.fox21.at/man/timr.1.html>

### Start Command

The Start command always removes all Tracks from the Stack. If there is another current running Task this Task will be stopped and removed from the Stack.

```bash
timr start [<options>] [<task_id> [<track_id>]]
```

See more informations on the [timr-start(1)](https://timr.fox21.at/man/timr-start.1.html) man page.

### Stop Command

Stopps the current running Track and removes it from the Stack.

```bash
timr stop [<options>]
```

See more informations on the [timr-stop(1)](https://timr.fox21.at/man/timr-stop.1.html) man page.

### Pause Command

Pause the current running Track.

```bash
timr pause [<options>]
```

See more informations on the [timr-pause(1)](https://timr.fox21.at/man/timr-pause.1.html) man page.

### Continue Command

Continue the previous paused Track. When a Track will be continued (or *restarted*) it's actual a copy using the same message.

```bash
timr continue [<options>]
```

See more informations on the [timr-continue(1)](https://timr.fox21.at/man/timr-continue.1.html) man page.

### Push Command

Sometimes you need to work on a Task only temporary. You want to track the time for this as well. For example fixing a bug. When you fixed the bug you want to continue your actual work. Here comes `timr push` and `timr pop` into the game. It modifies the Stack. When you push a new Task the below Task will be paused. On pop the Top Task will be stopped and the next below will continue.

```bash
timr push [<options>] [<task_id> [<track_id>]]
```

See more informations on the [timr-push(1)](https://timr.fox21.at/man/timr-push.1.html) man page.

### Pop Command

Stop and pop the current running Track from the Stack.

```bash
timr pop [<options>]
```

See more informations on the [timr-pop(1)](https://timr.fox21.at/man/timr-pop.1.html) man page.

### Status Command

Print the current Stack status.

```bash
timr status [<options>]
```

See more informations on the [timr-status(1)](https://timr.fox21.at/man/timr-status.1.html) man page.

### Log Command

Show recent Tracks.

```bash
timr log [<options>]
```

See more informations on the [timr-log(1)](https://timr.fox21.at/man/timr-log.1.html) man page.

### Task Command

Show, add, edit, or remove a Task.

```bash
timr task <subcommand> [<options>] [<task_id>]
```

See more informations on the [timr-task(1)](https://timr.fox21.at/man/timr-task.1.html) man page.

### Track Command

Show, add, edit, move, or remove a Track.

```bash
timr track <subcommand> [<options>] [<track_id>]
```

See more informations on the [timr-track(1)](https://timr.fox21.at/man/timr-track.1.html) man page.

### Report Command

Export Tasks and Tracks.

```bash
timr report [<options>]
```

See more informations on the [timr-report(1)](https://timr.fox21.at/man/timr-report.1.html) man page.

### Reset Command

Remove current running Track.

```bash
timr reset [<options>]
```

See more informations on the [timr-reset(1)](https://timr.fox21.at/man/timr-reset.1.html) man page.

## Workflow Example

Here is an example as shell commands how your workflow could look like while using Timr.

Before starting to work on a Task:

```bash
timr start
```

Do your work.

After finished your Task:

```bash
timr stop
```

But you like to name your Task at the beginning to know on what you worked:

```bash
timr start --name 'Refactor Star Wars'
```

In case you need to do several things on your Task provide a more specific message:

```bash
timr start --name 'Refactor Star Wars' --message 'This is what I am going to do.'
```

But maybe you have not set `--message` on `start`. So you can also set it on `stop`:

```bash
timr stop --message 'This is what I have done.'
```

## Bash Completion

Timr comes with a completion for Bash: `bin/timr_bash_completion.sh` file is included to the Timr gem. To get the full path to `bin/timr_bash_completion.sh` run:

```bash
echo $(timr --install-basepath)/bin/timr_bash_completion.sh
```

In the following examples replace `/path/to/bin/timr_bash_completion.sh` with the output of the executed `echo` command.

Create a link to this file in your `bash_completion.d` directory. Unter Linux the path is `/etc/bash_completion.d`. Under macOS the path is `/usr/local/etc/bash_completion.d`. In this example we will use the path for macOS:

```bash
ln -s /path/to/bin/timr_bash_completion.sh /usr/local/etc/bash_completion.d
```

Alternatively you can direct source from your `~/.bashrc` file:

```bash
if [ -f /path/to/bin/timr_bash_completion.sh ]; then
	source /path/to/bin/timr_bash_completion.sh
fi
```

Do not forget to remove all links when deinstalling Timr.

## Project Links

- [Homepage](https://timr.fox21.at/)
- [API Reference Mainpage](https://timr.fox21.at/api/)
- [Man pages](https://timr.fox21.at/man/timr.1.html)
- [Code Coverage](https://timr.fox21.at/coverage/)
- [GitHub Page](https://github.com/TheFox/timr)
- [RubyGems Page](https://rubygems.org/gems/timr)

## Contributing

See [Contributing](.github/CONTRIBUTING.md) page.
