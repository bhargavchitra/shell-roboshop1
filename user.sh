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
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.bunnyone.online

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
VALIDATE $? "Disable nodejs Default version"


dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enable required module"


dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "install nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then 
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else 
    echo -e "Roboshop user already exist... $Y SKIPPING $N"
fi 

mkdir /app
VALIDATE "creating app directory" 

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading user code"

cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code" 


unzip /tmp/user.zip &>>$LOGS_FILE
VALIDATE $? " Uzip catalogue code "

npm install &>>$LOGS_FILE
VALIDATE $? "Installing dependencies." 

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Created systemctl services"

systemctl daemon-reload
systemctl enable user  &>>$LOGS_FILE
systemctl start user
VALIDATE $? "Starting and enabling user"













