#!/bin/bash

ROS_DISTRO=""
PROFILE="Default"
CATKIN_WS="catkin_ws"
ROS_SYSTEM_PATH="/opt/ros"
CREATE_NEW_WS=false
BUILD_TOOLS=("catkin-tools" "catkin_make") #(catkin-tools catkin_make)
SELECTED_BUILD_TOOL="${BUILD_TOOLS[0]}"
TERMINAL_OPTIONS=("terminator" "mate-terminal")
TERMINAL_SELECTION="${TERMINAL_OPTIONS[0]}"

SHORT_OPTIONS="r:w:l:p:c::h"
LONG_OPTIONS="ros-distro:,workspace:,list-workspaces:,profile:,create::,help"
HELP_TEXT="Usage:\n
-r|--ros-distro [ros-distro] -w|--workspace [workspace name]\n
-l|--list-workspaces [ros-distro]\n
-c|--ros-distro [ros-distro] -w|--workspace [workspace name] --create\n
-h|--help \n"

function select_build_tool()
{
  for var in "${BUILD_TOOLS[@]}"
  do

    if [ "$var" == "$1" ]
    then
      SELECTED_BUILD_TOOL=$1
      echo "Selected build tool '${SELECTED_BUILD_TOOL}'"
      return 
    fi
  done

  echo "Selected default build tool '${SELECTED_BUILD_TOOL}'"
  return
}

function check_supported_ros_distro()
{
	ros_distro=$1
	
	# check directory
	if [ ! -d "$ROS_SYSTEM_PATH/$ros_distro" ]; then		
		return 1 
	else
		return 0
	fi
}

function check_catkin_workspace_exists()
{
	catkin_dir="$HOME/ros/$2/$1"

	# check directory
	if [ ! -d "$catkin_dir" ]; then		
		return 1 
	else
		return 0
	fi
}

function get_workspace_list()
{
	ros_distro=$1
	ros_dir="$HOME/ros/$1"
	local -a a=()

	# check for valid directory
	if [ ! -d "$ros_dir" ]; then
		return
	fi

	# iterating through directories
	counter=0
	for d in $(ls -d $ros_dir/*); do
		catkin_ws=$(basename $d)

		# skip rosbuild
		if [ $catkin_ws == "rosbuild" ]; then
			continue
		fi

		# add ws to array
		a[$counter]=$catkin_ws
		let counter=counter+1

	done

	echo ${a[@]}
}

function list_catkin_workspaces()
{
	ros_distro=$1
	ros_dir="$HOME/ros/$1"

	# check for valid directory
	if [ ! -d "$ros_dir" ]; then
		return 1
	fi

	declare -a a=()
	a=$(get_workspace_list $ros_distro)

	for i in ${a[@]}; do
		echo "ros catkin workspace: $i"
	done

	return 0
}

function main()
{
	PARSED_OPTIONS=$(getopt -n "$0" -o $SHORT_OPTIONS --long $LONG_OPTIONS -- "$@")

	#Bad arguments, something has gone wrong with the getopt command.
	if [ $? -ne 0 ];
	then
		exit 1
	fi
	 
	# A little magic, necessary when using getopt.
	eval set -- "$PARSED_OPTIONS"		

	while true; do
		OPTARG=$2		
		case "$1" in
			-r|--ros-distro)
				#echo "ros-distro selected $OPTARG"
				ROS_DISTRO=$OPTARG
				shift 2
				;;

			-w|--workspace)
				#echo "catkin workspace selected $OPTARG"
				CATKIN_WS=$OPTARG
				shift 2
				;;

			-l|--list-workspaces)

				if(! list_catkin_workspaces $OPTARG); then
					echo "ros $2 has no catkin workspaces"
					exit 1
				else
					exit 0
				fi
				;;

			-h|--help)
				echo -e $HELP_TEXT
				exit 0
				;;

			-p|--profile)

				PROFILE=$OPTARG
				shift 2
				;;

      -c| --create)

        CREATE_NEW_WS=true
        select_build_tool $OPTARG
        if [[ -z "$OPTARG" ]]; then
          shift 1
        else
          shift 2
        fi

        ;;

			--)
				# finished parsing options
				break;;

      *)
        #echo "no valid entry, shifting 1"
        shift 1
        ;;


		esac
	
		let OPTIND=OPTIND+1
	done

	# positional arg ros-distro
	if [ $# -ge 2 ]; then
		ROS_DISTRO=$2
	fi

	# positional arg workspace
	if [ $# -ge 3 ]; then
		CATKIN_WS=$3
	fi

		# positional arg profile
	if [ $# -ge 4 ]; then
		PROFILE=$4
	fi

	# check ros distro
	if(! check_supported_ros_distro $ROS_DISTRO); then
		echo "$(tput setaf 1)ROS Distribution '$ROS_DISTRO' was not found$(tput sgr0)"
		exit 1
	fi

	# check catkin workspace
	if(! check_catkin_workspace_exists $CATKIN_WS $ROS_DISTRO); then

    if $CREATE_NEW_WS ; then

      # checking that required variables have been set
      if [ "$ROS_DISTRO" == "" ] ; then
        echo "$(tput setaf 1)ROS distribution has not been set; recommended use:$(tput sgr0)"
        echo "$(tput setaf 1)ros_session -c [ros-distro] [catkin_ws]:$(tput sgr0)"
        exit 1
      fi

      ROSBUILD_DIR="$HOME/ros/$ROS_DISTRO/rosbuild"

      # workspace creation
      source "$HOME/ros_development_config/general/ros_create_workspace.bash" $ROS_DISTRO $CATKIN_WS $SELECTED_BUILD_TOOL $ROSBUILD_DIR
      
    else
		  echo "$(tput setaf 1)Catkin workspace $CATKIN_WS for ros $ROS_DISTRO was not found$(tput sgr0)"
		  exit 1
    fi

	else
    echo "$(tput setaf 3)Catkin workspace already exists at $CATKIN_WS, skipping creation.$(tput sgr0)"
  fi
	
	# launch terminals
	if ["$TERMINAL_SELECTION" -eq "${TERMINAL_OPTIONS[0]}" ]; then
		launch_terminator_terminal
	elif ["$TERMINAL_SELECTION" -eq "${TERMINAL_OPTIONS[1]}" ]; then
		launch_mate_terminal
	else
		launch_terminator_terminal
	fi
	
}

function launch_terminator_terminal()
{
	TERMINAL_CMD="terminator"
	cp -f ~/.bashrc ${LINUX_CONF_PATH}/bashrc.tmp
	echo "source $LINUX_CONF_PATH/general/ros_core_setup.bash $ROS_DISTRO $CATKIN_WS">>"$LINUX_CONF_PATH/bashrc.tmp"
	echo "echo -e \"\033]0;ROS-$ROS_DISTRO [$CATKIN_WS]\007\"">>"$LINUX_CONF_PATH/bashrc.tmp" # set title
	echo "export PS1=\"ROS-$ROS_DISTRO[$CATKIN_WS]: \"&& clear">>"$LINUX_CONF_PATH/bashrc.tmp"
	echo "echo \"$(tput setaf 3)ROS catkin workspace [$CATKIN_WS] is ready$(tput sgr0)\"">>"$LINUX_CONF_PATH/bashrc.tmp"
	COMMAND="$TERMINAL_CMD -g $LINUX_CONF_PATH/general/terminator_config -l ros_devel"
	# the terminator configuration file has been set to execute the "bashrc.temp" script on each new terminal
	eval $COMMAND & >> /dev/null
	return 0
}

function launch_mate_terminal()
{
	TERMINAL_CMD="mate-terminal"
	# construct bash file
	cp -f ~/.bashrc ${LINUX_CONF_PATH}/bashrc.tmp
	echo "source $LINUX_CONF_PATH/general/ros_core_setup.bash $ROS_DISTRO $CATKIN_WS">>"$LINUX_CONF_PATH/bashrc.tmp"
  TERMINAL_TAB_ARGS="--title='ros-$ROS_DISTRO: $CATKIN_WS' --profile=$PROFILE --command='bash --rcfile $LINUX_CONF_PATH/bashrc.tmp'"
	NEW_TAB_ARG="--tab $TERMINAL_TAB_ARGS"
	COMMAND="$TERMINAL_CMD --window $TERMINAL_TAB_ARGS $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG $NEW_TAB_ARG"

	eval $COMMAND &
	return 0
}

main "$@"
