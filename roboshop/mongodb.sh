#!/bin/bash

stat() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32m Success \e[0m"
  else
    echo -e "\e[31m Failure \e[0m"
    echo -e "\e[33m Check the log file /tmp/frontend.log for more information \e[0m"
    exit 1
  fi
}

component="mognodb"
# appContent="https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip"
url="https://raw.githubusercontent.com/devoos-sandbox/shell-scripting/refs/heads/main/roboshop"
appLog="/tmp/${component}.log"