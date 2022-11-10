#!/bin/bash

declare -a user_list
declare user
for user_info in $(cat /etc/passwd | cut -d":" -f1,3,7) # get users and UIDs
do
	user_list+=($user_info) # append to the array to keep info
done

# show all processes
all() {
	echo  if [[ $option == "t" ]] 
	echo ---------------------------
	echo 
	echo "Hello $(whoami)"
	echo
	echo ---------------------------
	echo
	echo 'Users connected:'
	echo
	for user_info in ${user_list[@]} # list processes for every user
	do
		uid=$(echo $user_info | cut -d":" -f2) # get UID for ps
		if [[ $(ps -u $uid | grep ' pts\| tty') != "" ]] # avoid printing users with no processes
		then
			echo
			echo User: $(echo $user_info | cut -d":" -f1) 
			echo UID: $(echo $user_info | cut -d":" -f2) # print username
			echo 
			ps -u $uid --format tty,stime,time,pid,cmd | awk '$1 != "?" {print $0}'	# list processes
			echo
			echo
		fi
	done
}

# empty arguments o -h shows help screen
help() {
	echo 
	echo ---------------------------
	echo 
	echo "Hello $(whoami)"
	echo
	echo ---------------------------
	echo
	echo "This script lets you see users processes"
	echo 
	echo "Usage:"
	echo
	echo "-t: Show all users process"
	echo 
	echo "-v: verbose"
	echo
	echo "-u <user>: show specific user processes"
	echo
}

# search by specific user
one_user() {
	local user="$1"
	user_exists=0 # to start the loop
	while [[ $user_exists -eq 0 ]] # loop until specified user is found
	do
	if id -u "$user" >/dev/null 2>&1;then # check if user exists and avoid output
		for user_data in ${user_list[@]} # look for specific user line to get data
		do
			if [ $user == $(echo $user_data | cut -d":" -f1) ];then # get data of the user selected
				shell=$(echo $user_data | cut -d":" -f3) # get shell path
				uid=$(echo $user_data | cut -d":" -f2) # get UID for ps
			fi
		done
		shell_clean=$(echo $shell | awk 'BEGIN { FS = "/" } /nologin/ { print $NF }') # get shell info
		if [ "$shell_clean" == "nologin" ];then # check if user is offline
			echo 'User not online'
			user_exists=1 # break while loop
		else
			echo
			echo User: $(echo $user | cut -d":" -f1) 
			echo
			ps -u $uid --format tty,stime,time,pid,cmd | awk '$1 != "?" {print $0}' # print specific user processes
			user_exists=1 # break while loop
		fi
	else
		echo
		echo 'Username does not exist'
		echo
		read -p 'Enter username again: ' user # user input for another username
	fi
	done
}

# wrong input, show help option
wrong() {
	echo 
	echo 'Unrecognized option'
	echo 'See the ouput of script -h for a summery of options'
	echo
} 

# get flags and activate specific function
while getopts ":vtu:h" options; do 
    case "${options}" in
        t)
		  all
		  ;;
        u)
		  one_user ${OPTARG}
		  ;;
		v)
		  verbose=True
		  ;;
		:)
		  help
		  ;;
		h)
		  help
		  ;;
		?)
		  wrong
		  ;;
    esac
done
