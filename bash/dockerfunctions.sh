#!/bin/bash
DOCKER_BASH_FUNCTIONS_DIR=$(dirname "${BASH_SOURCE[0]}")

create_network_ifnotexists(){
    # -z is if output is empty
    if [ -z "$(docker network ls | grep $1)" ]; then
        echo "Creating network $1"
        docker network create $1
    fi
}

remove_network(){
    # if network exists remove
    if [ ! -z "$(docker network ls | grep $1)" ]; then
        echo "Removing network $1"
        docker network rm $1
    fi
}

connect_to_network(){
    # -z if output is empty
    if [ -z "$(docker network inspect $1 -f '{{range $value := .Containers}}{{ $value }}{{end}}' | grep -w "$2")" ]; then
        echo "Container $2 is not connected to network $1"
        echo "Connecting container $2 to network $1"
        docker network connect $1 $2
    fi
}

disconnect_from_network(){
    if [ ! -z "$(docker network inspect $1 -f '{{range $value := .Containers}}{{ $value }}{{end}}' | grep -w "$2")" ]; then
        echo "Disconnecting container $2 from network $1"
        docker network disconnect $1 $2
    fi
}

check_container_ps(){
    if [ $($1) ]; then
        # 0 = true
        return 0
    else
        # 1 = false
        return 1
    fi
}

container_is_stopped(){
    check_container_ps "docker ps -aq -f status=exited -f name=$1"
}

container_is_running(){
    check_container_ps "docker ps -aq -f status=running -f name=$1"
}

container_exists(){
    check_container_ps "docker ps -aq -f name=$1"
}

stop_container(){
    if container_is_running $1; then
        docker stop $1
    fi
}

remove_container(){
    stop_container $1
    
    if container_exists $1 && container_is_stopped $1; then
        docker rm $1
    fi
}