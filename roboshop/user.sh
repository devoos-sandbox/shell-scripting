#!/bin/bash


component="user"
appContent="https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip"
appLog="/tmp/${component}.log"
appUser="roboshop"
appDir="/app"
# Override variables

source roboshop/common.sh

nodejs