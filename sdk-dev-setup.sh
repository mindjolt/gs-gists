#!/bin/sh

if [ ! `which brew` ]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

export JAVA_HOME=""
if /usr/libexec/java_home -v 11 >/dev/null 2>&1; then
    export JAVA_HOME="$(/usr/libexec/java_home -v 11)"
    msg='export JAVA_HOME="$(/usr/libexec/java_home -v 11)"'
elif /usr/libexec/java_home -v 1.8 >/dev/null 2>&1; then
    export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
    msg='export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"'
fi    
[ -z "$JAVA_HOME" ] && echo "You must have jdk8 or jdk11 installed!" && exit

brew upgrade
brew install sbt nuget
/opt/homebrew/bin/nuget sources Add -Name github -Source https://nuget.pkg.github.com/mindjolt/index.json -Username $GH_USER -Password $GH_PAT -StorePasswordInClearText

export JAVA_HOME="$(/usr/libexec/java_home)"

# Create a stub project so we can grab additional requirements
echo
echo '*******************************************************'
echo '*                                                     *'
echo '* When prompted below, enter your github credentials. *'
echo '*                                                     *'
echo '*******************************************************'
echo
last=$CWD
cd /tmp
sbt new mindjolt/unity-sdk.g8 --force --name=stub
cd /tmp/stub
#This is not working, there is no documentation on how to do this or what the task is
#sbt envSetup
cd $last

echo "*******************************************************************************************"
echo "*                                                                                         *"
echo "* Please add the following to your .bash_profile to ensure you are using the correct jdk: *"
echo "*                                                                                         *"
echo "* $msg"
echo "*                                                                                         *"
echo "*******************************************************************************************"



