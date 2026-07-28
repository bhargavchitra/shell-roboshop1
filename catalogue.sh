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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disable Nodejs Default version"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enable required module"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Install NodeJS"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then 
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "creating system user"
else 
    echo -e "Roboshop user already exist... $Y SKIPPING $N"
fi 

mkdir -p /app 
VALIDATE "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading catalogue code"

cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code" 

unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATE $? " Uzip catalogue code "

npm install &>>$LOGS_FILE
VALIDATE $? "Installing dependencies." 

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created systemctl services"


systemctl daemon-reload 
systemctl enable catalogue &>>$LOGS_FILE
systemctl start catalogue
VALIDATE $? "Starting and enabling catalogue"






