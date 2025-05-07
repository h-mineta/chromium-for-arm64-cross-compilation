#!/bin/bash

podman build -t chromium-headless . \
&& podman run --rm chromium-headless \
   cat /opt/chromium_headless_shell.tar.gz > chromium_headless_shell.tar.gz
