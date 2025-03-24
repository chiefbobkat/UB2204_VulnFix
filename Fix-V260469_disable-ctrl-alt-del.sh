#!/bin/bash

# Disable the ctrl-alt-del.target
sudo systemctl disable ctrl-alt-del.target

# Mask the ctrl-alt-del.target
sudo systemctl mask ctrl-alt-del.target

# Reload the systemd manager configuration
sudo systemctl daemon-reload
