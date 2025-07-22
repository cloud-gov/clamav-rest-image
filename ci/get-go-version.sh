#!/bin/bash

go_version=$(curl -s "https://go.dev/VERSION?m=text" | head -n 1)
echo "$go_version" > go-version/version