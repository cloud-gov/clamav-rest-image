#!/bin/bash

go_version=$(curl -s "https://go.dev/VERSION?m=text")
echo "$go_version" > go-version/version