#!/bin/bash 


USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing mongoDB server"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable mongoDB"

systemctl start mongod 
VALIDATE $? "start mongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf 
VALIDATE $? "Allowing remote connections" 

systemctl restart mongod 
VALIDATE $? "Restarted MongoDB"
