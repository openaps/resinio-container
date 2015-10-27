#!/bin/bash
#Set the root password as root if not set as an ENV variable
export PASSWD=${PASSWD:=root}
#Set the root password
echo "root:$PASSWD" | chpasswd
#Spawn dropbear
dropbear -E -F &

#if [[ -n "$MESH_OPENAPS" ]] ; then
#fi

if [[ ! -d /root/.ssh ]] ; then
  mkdir ~/.ssh
fi
if [[ -n "$IMPORT_GITHUB_USER" ]] ; then
  ssh-import-id-gh $IMPORT_GITHUB_USER | tee -a /root/.ssh/authorized_keys
fi

adduser openaps 
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

(


vendor=${1-'all'}
function print_dist_data ( ) {
package=$1
filename=$2
cat <<EOF | python -
import pkg_resources
print pkg_resources.resource_string("$package", "$filename")
EOF
}

function gen_medtronic ( ) {
   echo decocare etc/80-medtronic-carelink.rules
}

function gen_dexcom ( ) {
   echo dexcom_reader etc/udev/rules.d/80-dexcom.rules
}

function gen_known ( ) {
"gen_$1"
}

if [[ $EUID -ne 0 ]] ; then
  echo run as root
  exit 1
fi
(
case $vendor in
  all)
    for x in medtronic dexcom ; do
      gen_known $x
    done
  ;;
  medtronic|dexcom)
    gen_known $vendor
  ;;
esac
) | while read module file ; do
  filename=$(basename $file)
  installed="/etc/udev/rules.d/$filename"
  cat <<EOF | python - > $installed && echo -n installed' ' || echo -n failed' '
import pkg_resources
print pkg_resources.resource_string("$module", "$file")
EOF
  echo $installed
done
which udevadm && udevadm control --reload

)


#start your application from here...
# python app/main.py
cd /opt/monitor
python monitor.py $OPENAPS_HOME

