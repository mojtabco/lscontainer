#! /bin/bash

GOLD="\033[93m"
RESET="\033[0m"

requisite(){

 if ! command -v jq &>/dev/null;
 then
    echo "jq could not be found, but can be installed with: "
    echo "apt install jq"
    echo "jq is a command line tool for processing JSON data."
    exit 1
 fi
}

#main()
if [ "$1" == "-h" ];
then  
  echo ""
  echo "Usage:  lscontainer Without using arguments"
  echo "        Show details container (Status Container, Image details, Network details, Volumes details)"
  echo "        User's guide to use the script, for more guidance, refer to the address https://github.com/mojtabco/lscontainer"
  echo "    -e  Show environment container"
  echo "    -h  show the help"
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed."
    exit 1
fi
 
# Checks that jq tools are installed
requisite

echo -e "${GOLD}"
echo -e "List of containers available in the system"
readarray -t CONTAINERS_AVAILABLE < <(docker ps -aq | xargs docker inspect --format='{{.Name}}' | cut -f2 -d/)
echo -e "---------------------------------------------------------------${RESET}"

    for CONTAINER_NAME in "${CONTAINERS_AVAILABLE[@]}"; do

      CONTAINER_STATUS=$(docker container inspect $CONTAINER_NAME | jq -r '.[].State.Status')
      CONTAINER_IMAGE=$(docker container inspect $CONTAINER_NAME | jq -r '.[].Config.Image')
      CONTAINER_NETWORK_NAME=$(docker container inspect $CONTAINER_NAME | jq -r '.[].NetworkSettings.Networks | keys[0]')
      CONTAINER_NETWORK_DRIVER=$(docker network inspect $CONTAINER_NETWORK_NAME | jq -r '.[].Driver')
      CONTAINER_IP=$(docker inspect $CONTAINER_NAME | jq -r '.[].NetworkSettings.Networks[].IPAddress')
      CONTAINER_EXPOSED_PORT=$(docker inspect $CONTAINER_NAME | jq -j '.[].NetworkSettings.Ports | keys[] | gsub("p"; "p ")')
      CONTAINER_HOST_PORT=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{if eq (len $conf) 0}}{{else}}{{$p}} -> {{(index $conf 0).HostPort}}{{end}}{{end}}' $CONTAINER_NAME)
      
      echo -e -n "Container: $CONTAINER_NAME"
      echo -e "     Satus: $CONTAINER_STATUS"
      echo -e "Image details"
      echo -e "    Image: $CONTAINER_IMAGE"
      echo -e "Network details"
      echo -e "    Name: $CONTAINER_NETWORK_NAME"
      echo -e "    Driver: $CONTAINER_NETWORK_DRIVER"
      echo -e "    IP Address: $CONTAINER_IP"
      echo -e "    Exposed Ports: $CONTAINER_EXPOSED_PORT"
      echo -e "    Host Port: $CONTAINER_HOST_PORT"
      echo -e "Volumes details"

      NUMBER_MOUNTS=$(docker inspect $CONTAINER_NAME | jq '.[].Mounts | length') 
      echo "    Mounts Number:" $NUMBER_MOUNTS
  
      j=0
      for ((j=0; j<NUMBER_MOUNTS; j++)); do
          
          VOULME_TYPE=$(docker inspect $CONTAINER_NAME | jq -r '.[].Mounts['$j'].Type')
          VOULME_NAME=$(docker inspect $CONTAINER_NAME | jq -r '.[].Mounts['$j'].Name')
          VOULME_SOURCE=$(docker inspect $CONTAINER_NAME | jq -r '.[].Mounts['$j'].Source')
          VOULME_DESTINATION=$(docker inspect $CONTAINER_NAME | jq -r '.[].Mounts['$j'].Destination')
          VOULME_RW=$(docker inspect $CONTAINER_NAME | jq -r '.[].Mounts['$j'].RW')
          
          echo -e "    Mounts Type: $VOULME_TYPE"
          echo -e "    Mounts Name: $VOULME_NAME"
          echo -e "    Mounts Source: $VOULME_SOURCE"
          echo -e "    Mounts Destination: $VOULME_DESTINATION"
          echo -e "    Mounts Read/Write: $VOULME_RW"
          echo -e -n "    Mounts Volume Size: KB " 
          echo "scale=2; $(du -sb $VOULME_SOURCE | cut -f1) / 1024" | bc
          if [ "$NUMBER_MOUNTS" -gt 1 ]; then
            echo ""
          fi
      done

      if [ "$1" == "-e" ];
      then
         CONTAINER_ENV=$(docker container inspect $CONTAINER_NAME | jq -r '.[].Config.Env[]' | sed 's/^/    /')
         echo -e "Environment details"
         echo -e "$CONTAINER_ENV"
      fi

      echo -e "---------------------------------------------------------------"
    done
