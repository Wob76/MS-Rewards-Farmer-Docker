#!/bin/sh

# Update Chrome
echo "Updating Chrome"
chmod 1777 /tmp
apt-get update
apt-get install --only-upgrade google-chrome-stable
apt autoremove

# clean up old runtime files
echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Cleaning up tmp folder"
rm -rf /tmp/* /tmp/.*

# check for updates
if [ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1) ] 
then 
  echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Bot is up to date"
else
  echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Pulling latest version of bot and updating dependencies"
  git pull
  pip install --upgrade --root-user-action=ignore -r requirements.txt
fi

if [ ! -z "$MSR_COMMIT" ]
then
  echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Checking out at $MSR_COMMIT"
  git checkout $MSR_COMMIT
  pip install --upgrade --root-user-action=ignore -r requirements.txt
fi

# setting the parameter from enviroment variables
PARAMS=""

if [ ! -z "$MSR_VISIBLE" ] && [ $MSR_VISIBLE = "true" ]
then
  echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Setting visible parameter"
  PARAMS="$PARAMS --visible"
fi

if [ ! -z "$MSR_LANG" ]
then
  echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Setting language parameter"
  PARAMS="$PARAMS --lang $MSR_LANG"
fi

if [ ! -z "$MSR_GEO" ]
then
  echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Setting geolocation parameter"
  PARAMS="$PARAMS --geo $MSR_GEO"
fi

if [ ! -z "$MSR_PROXY" ]
then
  echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Setting proxy parameter"
  PARAMS="$PARAMS --proxy $MSR_PROXY"
fi

if [ ! -z "$MSR_TELEGRAM" ]
then
  echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Setting telegram parameter"
  PARAMS="$PARAMS --telegram $MSR_TELEGRAM"
fi

if [ ! -z "$MSR_DISCORD" ]
then
  echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Setting discord parameter"
  PARAMS="$PARAMS --discord $MSR_DISCORD"
fi

if [ ! -z "$MSR_VERBOSE_NOTIFY" ] && [ $MSR_VERBOSE_NOTIFY = "true" ]
then
  echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Setting verbose notifications"
  PARAMS="$PARAMS --verbosenotifs"
fi

#if [ ! -z "$MSR_CHROMEVERSION" ]
#then
#  echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Setting Chrome version"
#  PARAMS="$PARAMS --chromeversion $MSR_CHROMEVERSION"
#fi

# start virtual display
Xvfb $DISPLAY -screen 1 1280x800x8 -nolisten tcp &

# start the bot
echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") [INFO] Starting bot"
echo "Params are: $PARAMS"
exec $@ $PARAMS
/usr/bin/tail -f /app/logs/activity.log
