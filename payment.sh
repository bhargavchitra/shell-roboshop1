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



dnf install python3 gcc python3-devel -y
VALIDATE $? "downloading python"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then 
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else 
    echo -e "Roboshop cart already exist... $Y SKIPPING $N"
fi 


mkdir -p /app
VALIDATE "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "Downloading catalogue code"

cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code" 

unzip /tmp/payment.zip
VALIDATE $? " Uzip catalogue code "

cd /app 
pip3 install -r requirements.txt
VALIDATE $? "installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Created systemctl services"


systemctl daemon-reload
systemctl enable payment 
systemctl start payment
VALIDATE $? "enabled and started payment" 



