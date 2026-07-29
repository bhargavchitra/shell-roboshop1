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
MONGODB_HOST=cart.bunnyone.online

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

dnf module disable nodejs -y
VALIDATE $? "Disable Nodejs Default version"

dnf module enable nodejs:20 -y
VALIDATE $? "Enable required module"

dnf install nodejs -y
VALIDATE $? "Install NodeJS"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then 
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else 
    echo -e "Roboshop cart already exist... $Y SKIPPING $N"
fi 

mkdir /app 
VALIDATE "creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
VALIDATE $? "Downloading cart code"

cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code" 

unzip /tmp/cart.zip
VALIDATE $? " Uzip cart code "

npm install 
VALIDATE $? "Installing dependencies." 

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Created systemctl services"

systemctl daemon-reload
systemctl enable cart 
systemctl start cart
VALIDATE $? "Starting and enabling cart"