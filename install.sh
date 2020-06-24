#!/bin/bash

OUTFILE=/tmp/install.exp

function auto_accept {
cat <<EOF >>$OUTFILE
spawn $1;
expect {
  "y/N" { exp_send "y\r" ; exp_continue }
  eof
}
EOF
}

cat <<EOF >$OUTFILE
#!/usr/bin/expect
set timeout -1;
log_user 0;
EOF

auto_accept 'sdkmanager --licenses'
auto_accept 'sdkmanager "tools"'
auto_accept 'sdkmanager "platform-tools"'
auto_accept 'sdkmanager "extras;android;m2repository"'
auto_accept 'sdkmanager "extras;google;m2repository"'

for VER in $(sdkmanager --list 2>/dev/null | cut -d'|' -f1 | awk '{$1=$1};1' | grep -v '\-rc' | grep 'build-tools\;' | sort -r | head -n 1); do
	auto_accept "sdkmanager \"$VER\""
done

for VER in $(sdkmanager --list 2>/dev/null | cut -d'|' -f1 | awk '{$1=$1};1' | grep -v '\-rc' | grep 'platforms\;' | cut -d'-' -f2 | sort -nr | head -n 6); do
	auto_accept "sdkmanager \"platforms;android-$VER\""
done

expect $OUTFILE
