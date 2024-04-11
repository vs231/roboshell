#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0.$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$R $2 $Y package Error... $N can't be installed"
        exit 1
    else 
        echo -e "$Y $2 $G installed successfully "
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR $Y You R not a ROOT USER"
    exit 1
else
     echo -e "You are a $G root user"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? " disabled nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? " enabled nodejs "

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "installed nodejs "

id roboshop
if ( $? -ne 0 )
then 
    useradd roboshop &>> $LOGFILE
    VALIDATE  $? "add user"
else
    echo -e " user already added $Y skipping....."
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? " drive added"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &&> $LOGFILE
VALIDATE $? "zip file"

cd /app 

unzip /tmp/catalogue.zip 
VALIDATE   $? "unziped the file"

npm install &>> $LOGFILE
VALIDATE $? -e " $G npm installed "

cp home/centos/roboshell/catalogue.service  /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "copied the copied the catalogue"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " daemon reloded"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? " enabled catalogue"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "started catalogue"

cp /home/centos/roboshell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "mongo code entered"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? " mongo installed " 

mongo --host mongodb.vs-devops.online </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? " connected to mongo"