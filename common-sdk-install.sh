#!/bin/sh

command -v jq >/dev/null >/dev/null || brew install jq

if [[ ! -d "Assets" ]] || [[ ! -d "ProjectSettings" ]]; then
  echo "You must run this from the root of your Unity project."
  exit 1
fi

function fetch () {
    package=$1
    latest=$(curl --silent -H "X-Result-Detail: info " "https://artifactory.sgn.com:443/artifactory/api/search/artifact?name=${package}.zip&repos=jcpm-release-local" | jq -r "(.results|=sort_by(.created)[-1].downloadUri).results")
    curl --silent -o /tmp/package.zip ${latest}
    rm -rf ${package}
    unzip -q /tmp/package.zip
    rm /tmp/package.zip
}

mkdir -p Assets/Plugins/JamCity
cd Assets/Plugins/JamCity

while true; do
    read -p  "Do you want to also install Json.Net.Unity3D? [y/n] " yn
    case $yn in
        [Yy]* ) 
            echo "Installing Json.Net.Unity3D..."
	    fetch "Json.Net.Unity3D"
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer y or n.";;
    esac
done

echo "Installing JamCity.CommonsSdk..."
fetch "JamCity.CommonSdk"
