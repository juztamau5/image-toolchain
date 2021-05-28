#!/bin/bash

# Copyright 2019 Cartesi Pte. Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#

if [ -z "$GID" -o -z "$UID" -o -z "$USER" -o -z "$GROUP" ]; then
    echo Running as root
    exec "$@"
else
  if [ ! $(getent group $GROUP) -a ! $(getent group $GID) ]; then
    groupadd -g $GID $GROUP
  else
    echo Group name $GROUP or id $GID already exist
  fi
  if [ ! $(getent passwd $USER) -a ! $(getent passwd $UID) ]; then
    useradd -u $UID -g $GID -G developer $USER
  else
    echo User name $USER or id $UID already exist
  fi
  export HOME=/home/$USER
  mkdir -p $HOME
  chown $USER:$GROUP $HOME

# Workaround for issue with su-exec tty ownership
# Should be removed once ticket https://github.com/ncopa/su-exec/issues/33 
# is resolved, or alternative solution with reusing file descriptors is found
  CURRENT_TTY=`tty`
  chown $USER:$GROUP $CURRENT_TTY

  exec /usr/local/bin/su-exec $USER "$@"
fi
