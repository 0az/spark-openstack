#! /bin/bash

ssh_args=(-T -o ClearAllForwardings=yes)
if test "$#" -eq 0; then
	ssh_args+=(jump.cloudlab.internal)
else
	ssh_args+=("$@")
fi
