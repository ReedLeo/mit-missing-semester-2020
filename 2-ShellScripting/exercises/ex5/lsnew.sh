#!/usr/bin/env bash

lsnew() {
	script_path=$(pwd)
	recency_day=1
	if [[ $# -gt 0 ]]; then
		script_path=$1
		if [[ $# -gt 1 ]]; then
			recency_day=$2
		fi
	fi

	find "$script_path" -name "*" -mtime -"$recency_day" -print0 | xargs -0 ls -lhtc
}
