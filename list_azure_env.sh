#!/bin/bash

rg_name=$(az group list | jq '.[].name')
echo rg_name=${rg_name} >> az.auto.tfvars
tenantId=$(az account list | jq '.[].tenantId')
echo tenantId=${tenantId} >> az.auto.tfvars

# az account list-locations -o table
