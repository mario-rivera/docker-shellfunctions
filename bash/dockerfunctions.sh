#!/bin/bash
DOCKER_BASH_FUNCTIONS_DIR=$(dirname "${BASH_SOURCE[0]}")
# comment line

create_network_ifnotexists(){
    # -z is if output is empty
    if [ -z "$(docker network ls | grep $1)" ]; then
        docker network create $1
        echo "Network $1 created"
    fi
}

remove_network(){
    if [ ! -z "$(docker network ls | grep $1)" ]; then
        docker network rm $1
        echo "Network $1 removed"
    else
        echo "Tried to remove network $1, but it does not exist"
    fi
}

connect_to_network(){
    if [ -z "$(docker network inspect $1 -f '{{range $value := .Containers}}{{ $value }}{{end}}' | grep -w "$2")" ]; then
        echo "Container $2 is not connected to network $1"
        docker network connect $1 $2
        echo "Connected container $2 to network $1"
    fi
}

disconnect_from_network(){
    if [ ! -z "$(docker network inspect $1 -f '{{range $value := .Containers}}{{ $value }}{{end}}' | grep -w "$2")" ]; then
        echo "Disconnecting container $2 from network $1"
        docker network disconnect $1 $2
    fi
}

check_container_ps(){
    local result=$(eval $1)

    if [ ! -z "$result" ]; then
        # 0 = true
        return 0
    else
        # 1 = false
        return 1
    fi
}

container_is_stopped(){
    check_container_ps "docker ps -a -f status=exited -f name=$1 | grep -w \"\\s$1\$\""
}

container_is_running(){
    check_container_ps "docker ps -a -f status=running -f name=$1 | grep -w \"\\s$1\$\""
}

container_exists(){
    check_container_ps "docker ps -a -f name=$1 | grep -w \"\\s$1\$\""
}

stop_container(){
    if container_is_running $1; then
        docker stop $1
        echo "Container $1 stopped"
    else
        echo "Tried to stop $1, but it is not running"
    fi
}

remove_container(){
    stop_container $1

    if container_exists $1 && container_is_stopped $1; then
        docker rm $1
        echo "Container $1 removed"
    else
        if ! container_exists $1; then
            echo "Tried to remove $1 container but it does not exist"
        elif ! container_is_stopped $1; then
            echo "Tried to remove $1 container but it is not stopped"
        fi
    fi
}
