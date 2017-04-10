
# Source from this file running
# 	source bin/timr_bash_completion.sh

function _timr_command {
	local curr_word=$1
	local timr_commands=(
		continue
		help
		log
		pause
		pop
		push
		report
		start
		status
		stop
		task
		track
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_continue_main {
	local curr_word=$1
	local timr_commands=(
		--help
		--date
		--time
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_log_main {
	local curr_word=$1
	local timr_commands=(
		--help
		
		--from
		--to
		
		--day
		--month
		--year
		
		--all
		
		--start-date --start-time
		--end-date --end-time
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_pause_main {
	local curr_word=$1
	local timr_commands=(
		--help
		--end-date --date
		--end-time --time
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_pop_main {
	local curr_word=$1
	local timr_commands=(
		--help
		
		--start-date --start-time
		--end-date --end-time
		
		--date
		--time
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_push_main {
	local curr_word=$1
	local timr_commands=(
		--help
		
		--name
		--description
		--hourly-rate
		--flat-rate
		
		--message
		--edit
		--date
		--time
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_report_main {
	local curr_word=$1
	local timr_commands=(
		--help
		--day
		--month
		--year
		--all
		--tasks
		--tracks
		--csv
		--force
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_start_main {
	local curr_word=$1
	local timr_commands=(
		--help
		
		--name
		--description
		--estimation
		--hourly-rate
		--flat-rate
		
		--message
		--edit
		--date
		--time
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_status_main {
	local curr_word=$1
	local timr_commands=(
		--help
		--full
		--reverse
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_stop_main {
	local curr_word=$1
	local timr_commands=(
		--help
		
		--start-date
		--start-time
		--end-date --date
		--end-time --time
		
		--message
		--edit
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_task_main {
	local curr_word=$1
	local timr_commands=(
		--help
		
		add
		remove
		set
		show
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_task_add {
	local curr_word=$1
	local timr_commands=(
		--name
		--description
		--estimation
		--billed --unbilled
		--hourly-rate --no-hourly-rate
		--flat-rate --no-flat-rate
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_task_remove {
	local curr_word=$1
	COMPREPLY=( $(compgen -A variable 'TIMR_' -- "${curr_word}") )
}

function _timr_task_set {
	local curr_word=$1
	local timr_commands=(
		--name
		--description
		--estimation
		--billed --unbilled
		--hourly-rate --no-hourly-rate
		--flat-rate --no-flat-rate
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_task_show {
	local curr_word=$1
	local timr_commands=(
		--tracks
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_track_main {
	local curr_word=$1
	local timr_commands=(
		--help
		
		add
		remove
		set
		show
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_track_add {
	local curr_word=$1
	local timr_commands=(
		--message
		--start-date --start-time
		--end-date --end-time
		--billed --unbilled
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_track_remove {
	local curr_word=$1
	COMPREPLY=( $(compgen -A variable 'TIMR_' -- "${curr_word}") )
}

function _timr_track_set {
	local curr_word=$1
	local timr_commands=(
		--message
		--start-date --start-time
		--end-date --end-time
		--billed --unbilled
		--task
	)
	COMPREPLY=( $(compgen -W '${timr_commands[@]}' -- "${curr_word}") )
}

function _timr_track_show {
	local curr_word=$1
	COMPREPLY=( $(compgen -W '--task' -- "${curr_word}") )
}

function _timr_main {
	#echo "exec _timr_main"
	
	local curr_word
	# local prev_word
	
	curr_word="${COMP_WORDS[COMP_CWORD]}"
	# prev_word="${COMP_WORDS[COMP_CWORD-1]}"
	
	# echo
	# echo "curr_word '$curr_word'"
	# echo "prev_word '$prev_word'"
	# echo "COMP_CWORD '${COMP_CWORD}'"
	# echo "COMP_WORDS A '${COMP_WORDS[@]}'"
	unset -v 'COMP_WORDS[0]'
	# echo "COMP_WORDS B '${COMP_WORDS[@]}'"
	# echo
	
	COMPREPLY=()
	
	local timr_command timr_subcommand
	
	# echo "loop commands"
	for word in "${COMP_WORDS[@]}"; do
		# echo "loop word: '$word'"
		case ${word} in
			-*)
				# Skip, next.
				;;
			*)
				if [[ ! -z "$word" ]]; then
					if [[ -z "$timr_command" ]]; then
						timr_command=$word
					else
						timr_subcommand=$word
						break
					fi
				fi
				;;
		esac
	done
	
	if [[ -z "$timr_command" ]]; then
		case ${curr_word} in
			-*)
				COMPREPLY=( $(compgen -W "-V --version -h --help -C" -- "${curr_word}") )
				;;
			*)
				_timr_command "$curr_word"
				;;
		esac
	else
		if [[ "$curr_word" = "$timr_command" ]]; then
			# To fit *) in the case below.
			unset timr_command
		fi
		if [[ "$curr_word" = "$timr_subcommand" ]]; then
			# To fit *) in the second level case below.
			unset timr_subcommand
		fi
		
		case "${timr_command}" in
			continue|log|pause|pop|push|report|start|status|stop)
				"_timr_${timr_command}_main" "$curr_word"
				;;
			task|track)
				case "${timr_subcommand}" in
					add|remove|set|show)
						"_timr_${timr_command}_${timr_subcommand}" "$curr_word"
						;;
					*)
						"_timr_${timr_command}_main" "$curr_word"
						;;
				esac
				;;
			help|*)
				_timr_command "$curr_word"
				;;
		esac
	fi
	# echo
}

# Dev
# complete -F _timr_main -o bashdefault timr_dev

complete -F _timr_main -o bashdefault timr
# complete -r timr # Remove timr.
