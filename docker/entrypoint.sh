#!/bin/bash

# Add local user
# Either use runtime USER_ID:GROUP_ID or fallback 1000:1000

USER_ID=${USER_ID:-1000}
GROUP_ID=${GROUP_ID:-1000}
mainUser=${mainUser:-sirfuser}
OLD_HOME=/home-away
export HOME=/home/$mainUser

if [ -d $HOME ]; then
  cd $HOME
  if [ "$@" = "/usr/local/bin/service.sh" ]; then
    bash /usr/local/bin/service.sh
  else
    exec gosu $mainUser "$@"
  fi
fi

cd /
mv $OLD_HOME $HOME
cd $HOME

echo "$UID:$GID Creating and switching to: $mainUser:$USER_ID:$GROUP_ID"
# groupadd -g $GROUP_ID -o -f $mainUser
addgroup --quiet --system --gid "$GROUP_ID" "$mainUser"
useradd --system --shell /bin/bash -u $USER_ID -o -c "" -M -d $HOME \
   -g $mainUser -G sudo $mainUser \
   -p $(echo virtual | openssl passwd -1 -stdin)
#adduser --quiet --system --shell /bin/bash \
#  --no-create-home --home /home/"$mainUser" \
#  --ingroup "$mainUser" --uid "$USER_ID" "$mainUser"
echo "$mainUser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/"$mainUser"

for i in /opt/* "$HOME"; do
  if [ -d "$i" ]; then
    chown -R $mainUser "$i"
    chgrp -R $mainUser "$i"
  fi
done

if [ "$@" = "/usr/local/bin/service.sh" ]; then
  bash /usr/local/bin/service.sh
else
  exec gosu $mainUser "$@"
fi
