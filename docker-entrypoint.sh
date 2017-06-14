#!/bin/bash


##
# this is the entry point for all 3 of the components for
# this app.  branching decisions are made based on ENV vars
# and it doe sthe correct thing.
##

TRIES=0
MAX_TRIES=240

waitforvolume() {
  while true ; do
    touch /mcrouter/.foo >> /dev/null 2>&1
    if [ $? != 0 ]; then
      echo "/mcrouter isn't available yet. have checked $TRIES out of $MAX_TRIES times"
      TRIES=$(($TRIES + 1))
      sleep 1;
      if [ $TRIES -gt $MAX_TRIES ]; then
        echo "Tried $MAX_TRIES times, exiting"
        exit -1
      fi
    else
      rm -f /mcrouter/.foo
      break;
    fi
  done
}

waitforconfig() {
  while [ ! -f /mcrouter/mcrouter-config.json ]; do
    echo "wating for mcrouter config"
    sleep 1;
  done
}

case $CLUSTER_ROLE in

provisioner)
  waitforvolume
  echo "Running: /mcr/bin/mcrouter-kuberentes-provisioner --mcrouterconfig=$MCROUTERCONFIG --inputtemplate=$INPUTTEMPLATE --namespace=$NAMESPACE --incluster=$INCLUSTER --kubeconfig=$KUBECONFIG"
  /mcr/bin/mcrouter-kuberentes-provisioner \
    --mcrouterconfig=$MCROUTERCONFIG \
    --inputtemplate=$INPUTTEMPLATE \
    --namespace=$NAMESPACE \
    --incluster=$INCLUSTER \
    --kubeconfig=$KUBECONFIG
  ;;
  memcached)
    echo "starting memcached" # TODO: may wana support large pages etc
    memcached -u root
    ;;
  mcrouter)
    echo "starting up mcrouter"
    # make sure the config is there before we start
    waitforconfig
    mcrouter -p 5000 -f /mcrouter/mcrouter-config.json
    ;;
  *)
  echo "not a valid role, exiting"
  echo "$CLUSTER_ROLE found"
  exit -1
esac

