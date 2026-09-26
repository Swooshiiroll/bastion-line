#!/bin/sh
# Launches Bastion Line from source with Godot 4.7 (on PATH as godot or godot4).
cd "$(dirname "$0")" && exec "$(command -v godot4 || command -v godot)" --path .
