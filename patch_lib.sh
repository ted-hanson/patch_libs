#!/bin/sh

## 
#  COMMAND: patch_lib [-r <command> -g <get-boxes-cmd> [-c <containers>] [-q]] [-h] 
#    Will ssh into all containers and execute the get-boxes-cmd 
#    and then ssh into the output of that and run command
#  EXAMPLE USAGE:
#    ./patch_lib.sh -r 'hostname' -g "grep mps /etc/hosts | awk '{ print \$3 }'"
#    ./patch_lib.sh -g 'echo mcol' -r 'date' -c c1
##

# default to non-verbose
VERBOSE=1
CONTAINERS='c1 c2 c3 c5 c6 c7 c10 c12 c13 c17'

prompt() {
  echo "Containers: $CONTAINERS"
  echo "On boxes that match: $HOSTS"
  echo "Running command: $COMMAND"
  echo 'Continue (y/n)? \c'
  read a

  while [ "$a" != "y" ]; do
    [ "$a" == "n" ] && echo "ABORTING RUN" && exit 1
    [ "$a" != "n" ] && echo "Please enter y or n: \c" && read a
  done
}


# Grab args for script
while true ; do
  case "$1" in 
    # POSSIBLE MANDITORY ARGS
    -h )
        echo "COMMAND: patch_lib [-r <command> -g <get-boxes-cmd> [-c <containers>] [-q]] (-h)"
        echo "    Will ssh into all <containers> (by default unless set) and execute the"
        echo "    <get-boxes-cmd> and then ssh into the output of that and run <command>"
        exit 0
    ;;
    -r )
        COMMAND=$2
        shift 2
    ;;
    -g )
        HOSTS=$2
        shift 2
    ;;
    # OPTIONAL ARGS
    -q )
        VERBOSE=0
        shift 1
    ;;
    -c )
        CONTAINERS=$2
        shift 2
    ;;
    * )
        break
    ;;
  esac
done;

if [ $# -ne 0 ] || [ -z "$COMMAND" ] || [ -z "$HOSTS" ] ; then
  echo "Incorrect Usage: patch_lib [-r <command> -g <get-boxes-cmd> [-c <containers>] [-q]] [-h]"
  exit 2 
fi

# if didn' use -q
[ $VERBOSE -eq 1 ] && prompt

for container in $CONTAINERS; do
  ssh -t $container "for s in \`$HOSTS\` ; do ssh -t \$s '${COMMAND}'; done; exit;"
done
