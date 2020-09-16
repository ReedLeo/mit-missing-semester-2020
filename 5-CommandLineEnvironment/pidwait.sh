#!/usr/bin/env zsh

pidwait() {
	echo "You want to wait for $1"
	while kill -0 $1; do sleep 1; done
}
