#!/bin/bash
#Set the root password as root if not set as an ENV variable
export PASSWD=${PASSWD:=root}
#Set the root password
echo "root:$PASSWD" | chpasswd
#Spawn dropbear
dropbear -E -F &

#if [[ -n "$MESH_OPENAPS" ]] ; then
#fi

export MESH_OPENAPS
OPENAPS_HOME=${OPENAPS_HOME-/app/openaps}

if [[ -n "$OPENAPS_HOME" ]] ; then
  if [[ ! -d "$OPENAPS_HOME" ]] ; then
    mkdir -p $OPENAPS_HOME
    rmdir $OPENAPS_HOME
    (
      openaps init $OPENAPS_HOME
      if [[ -n "$MESH_OPENAPS" ]] ; then
        cd $OPENAPS_HOME
        git remote add origin $MESH_OPENAPS
        git pull -u origin master
      fi
    )
  fi
fi

#start your application from here...
# python app/main.py
cd /opt/monitor
python monitor.py $OPENAPS_HOME

