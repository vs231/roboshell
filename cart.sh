#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0.$TIMESTAMP.log"
$TIMESTAMP &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then echo -e "$Y $2 $R ERROR...."
    else
        echo -e " $G $2 $Y successfully"
    fi
}
if [ $ID -eq 0 ]
then echo -e "$Y you are a $G root user" 
else 
    echo -e "$R ERROR... $Y not a root user"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? " disabled nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabled nodejs"

dnf install nodejs -y $>> $LOGFILE
VALIDATE $? "installed nodejs"

if [ $? -eq 0 ]
then echo -e " $N user already exist  $Y SKIPPING..... "
else
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "useradded"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "created app"

 cd /app

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "file uploded"

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "unziped file"

npm install &>> $LOGFILE
VALIDATE $? "npm installed"

cp /home/centos/roboshell/cart.service /etc/system/systemd/cart.service &>> $LOGFILE
VALIDATE $? "copied the cart service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloaded cart"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "enabled cart"

systemctl start cart &>> $LOGFILE
VALIDATE $? "started cart"



