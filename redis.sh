#!/bin/bash 

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="/var/log/shell-script/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
M="\e[35m"
C="\e[36m"
W="\e[37m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script as root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $? -ne 0 ]; then
        echo -e "$2  ... $M FAILURE $N" | tee -a $LOGS_FILE
        exit 1
  else
       echo -e "$2   ... $G success $N" | tee -a $LOGS_FILE
 fi
}


dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "Disable redis Default version"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "Enable required module"

dnf install redis -y &>>$LOGS_FILE
VALIDATE $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected -mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections" 

systemctl enable redis &>>$LOGS_FILE
systemctl start redis 
VALIDATE $? "ensbled and  start redis"

