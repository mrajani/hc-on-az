#!/bin/bash

echo "Unset all Azure ARM_ env vars"
unset $(env | grep ARM_ | cut -d '=' -f1)
