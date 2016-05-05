#!/bin/bash

red=31
green=32
yellow=33
blue=34

function cecho {
	local color="${1}"
	local msg="${2}"
	printf "\033[${color}m${msg}\033[m\n"
}

function usage {
	cat << EOF
Usage:
    gg <command> [<args>]

SubCommands:
    gg build
    gg run
    gg test [<target>]
    gg gen <num-of-tests>
EOF
}

function build {
	g++ -O2 -std=c++11 main.cpp -o main
	return $?
}

function test_at {
	cecho $green "test at ${1}"
	./main < "${1}"	
}

function run_test {
	local target="${1}"
	if [ -z "${target}" ] || [ "${target}" = "all" ]; then
		for input_file in `find . -name "*.in"`
		do
			test_at "${input_file}"
		done
	else
		test_at "${target}.in"
	fi
}

function gen {
	local template_path=~/.config/gg/template.cpp
	if [ -f $template_path ] && [ ! -f main.cpp ]; then
		cp $template_path main.cpp
	else
		touch main.cpp
	fi
	for i in `seq 1 ${1}`
	do
		touch "${i}.in"
	done
	cecho $green "generated template"
}


case "${1}" in
	"build")
		build && cecho $green "build succeeded"
	;;

	"run")
		build && cecho $green "build succeeded and running" && ./main
	;;

	"test")
		build && cecho $green "build succeeded" && run_test "${2}"
	;;

	"gen")
		gen "${2}"
	;;

	"copy")
		cat main.cpp | pbcopy && cecho $green "copy main.cpp to clipboard"
	;;

	"help"|"--help"|"-h")
		usage
	;;

	*)
		usage
	;;
esac
