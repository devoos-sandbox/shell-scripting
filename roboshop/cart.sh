#!/bin/bash


component="cart"
appContent="https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip"
appLog="/tmp/${component}.log"
appUser="roboshop"
appDir="/app"
# Override variables
mongodbRepo="https://raw.githubusercontent.com/devoos-sandbox/shell-scripting/refs/heads/main/roboshop/mongodb.repo"

source roboshop/common.sh

nodejs