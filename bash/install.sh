#!/bin/bash

set -e

################################################################################
# Other functions                                                              #
################################################################################

function error_exit {
  echo "${PROGNAME}: &{1:-"Unknown Error"}" 1>&2
  exit 1
}

################################################################################
# Help                                                                         #
################################################################################

function display_help() {
   # Display Help
   echo ""
   echo
   echo "Syntax: scriptTemplate [1 | 2 | 3 | 4]"
   echo "options:"
   echo "1. Default install."
   echo "2. Extended install."
   echo "3. Run project."
   echo "4. Print software version and exit."
   echo "-----------------------------------"
}

function display_extended_install() {
   # Display Help
   echo "-----------------------------------"
   echo "Choose option:"
   echo "1. Install git"
   echo "2. Install postgresql"
   echo "3. Install java"
   echo "4. Install maven"
}

################################################################################
# Variables                                                                    #
################################################################################

git_setup=false
postgresql_setup=false
java_setup=false
maven_setup=false
project_download=false
project_compile=false
project_run=false

################################################################################
################################################################################
# Main program                                                                 #
################################################################################
################################################################################

display_help
read user_input1

case $user_input1 in
   1)
     $git_setup=true
     $postgresql_setup=true
     $java_setup=true
     $maven_setup=true
     $project_download=true
     $project_compile=true
   ;;
   2)
     display_extended_install
     read user_input2
   ;;
   3)
     $project_run=true
   ;;
   4)
     echo "Version 1.0.0 ALPHA"
     exit 0
   ;;
esac

if cd /home/; then
   mkdir -p logs
   cd logs
   touch -c log
   touch -c error_log
else
     error_exit "$LINENO: An error has occured. Cannot change directory! Aborting."
fi

exec 2>error_log
exec 3>log

yum -y update >&3
yum install -y wget >&3

if [[ $git_setup -eq true ]]
  then
    if which git | grep "git" >&3
      then
        echo "Git already installed"
    else
      yum install -y git >&3
    fi
fi

if [[ $postgresql_setup -eq true ]]
  then
    if which pgsql | grep "pgsql" >&3
      then
        echo "Postgresql already installed"
    else
      yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-6-x86_64/pgdg-redhat-repo-latest.noarch.rpm >&3
      yum install -y postgresql12 >&3
      yum install -y postgresql12-server >&3
      service postgresql-12 initdb >&3
      chkconfig postgresql-12 on >&3
      service postgresql-12 start >&3
    fi
fi

if which java | grep "java" >&3
then
echo "Java already installed"
else
yum install -y java-1.8.0-openjdk-devel >&3
fi

if which mvn | grep "mvn" >&3
then
echo "Maven already installed"
else
  if cd /opt; then
    wget http://www-us.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz >&3
    tar xzf apache-maven-3.6.3-bin.tar.gz >&3
    ln -s apache-maven-3.6.3 maven >&3
    echo -n > /etc/profile.d/maven.sh >&3
    echo "export M2_HOME=/opt/maven" >> /etc/profile.d/maven.sh
    echo "export PATH=${M2_HOME}/bin:${PATH}" >> /etc/profile.d/maven.sh
    source /etc/profile.d/maven.sh >&3
    rm -f apache-maven-3.6.3-bin.tar.gz >&3
  else
    error_exit "$LINENO: An arror has occurred."
  fi
fi

export MAVEN_OPTS="-Xmx512m"