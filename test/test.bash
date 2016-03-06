#!/bin/bash 
[[ ! -n $RECURRY_PATH ]] && echo -e "usage: RECURRY_PATH=/foo/bar/node-recurry ./test/commands\n\nplease install recurry and define its path" && exit 

[[ -n $RECURRY_PATH/cache.json ]] && rm $RECURRY_PATH/cache.json
[[ -n cache.json ]] && rm cache.json
killall node
echo "starting recurry API server at port 3333"
PORT=3333 timeout 20 $RECURRY_PATH/server &
sleep 3s
echo "proceeding.."

SELF_PATH="$(dirname "$(readlink -f "$0")" )"
export PATH=$PATH:node_modules/.bin

[[ -n $ONLINE ]] && {
  export HUBOT_IRC_SERVER=irc.freenode.net
  export HUBOT_IRC_ROOMS=#hubot-syslog
  export HUBOT_IRC_NICK=hubot
  export HUBOT_IRC_UNFLOOD=true
  adapter="-a irc"
}
export DEBUG=1 ;
export FILE_BRAIN_PATH=$SELF_PATH

[[ -f $FILE_BRAIN_PATH/brain-dump.json ]] && rm $FILE_BRAIN_PATH/brain-dump.json
echo brain=$FILE_BRAIN_PATH/brain-dump.json

hubot ${adapter} -r $SELF_PATH/scripts
