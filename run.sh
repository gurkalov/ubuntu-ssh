#!/bin/bash

set -e

echo "${SSH_KEY}" > /root/.ssh/authorized_keys

exec /usr/sbin/sshd -D
