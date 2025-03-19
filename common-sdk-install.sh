#!/bin/sh

command -v jq >/dev/null >/dev/null || brew install jq

if [[ ! -d "Assets" ]] || [[ ! -d "ProjectSettings" ]]; then
  echo "You must run this from the root of your Unity project."
  exit 1
fi

function fetch () {
    token=$GH_PAT
    package=$1
    latest=$(curl -s -H "Authorization: bearer ${token}" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/mindjolt/jcpm-release-local/contents/packages/${package}" | jq -r '.[] | select(.type == "dir") | .name' | sort -V | tail -n 1)
    curl -s -H "Authorization: bearer ${token}" -H "Accept: application/vnd.github.raw+json" "https://api.github.com/repos/mindjolt/jcpm-release-local/contents/packages/${package}/${latest}/${package}.zip" -o /tmp/package.zip
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
