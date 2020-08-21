#!/usr/bin/env bash

ziphtml() {
	filename=$1
	find . -name '*.html' -type f -print0 | xargs -0 tar caf "$filename"
}
