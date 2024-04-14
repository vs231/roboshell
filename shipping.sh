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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "installed maven"

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop &>> $LOGFILE
    VALIDATE  $? "add user"
else
    echo -e " user already added $Y skipping....."
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? " drive added"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &&> $LOGFILE
VALIDATE $? "zip file"

cd /app 

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE   $? "unziped the file"

mvn clean package &>> $LOGFILE
VALIDATE $? " mvn installed "

cp /home/centos/roboshell/shipping.service  /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copied the catalogue"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " daemon reloded"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? " enabled shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "started shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "installed mysql"

mysql -h mysql.vs-devops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILE
VALIDATE $? "mysql connected " 

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restarted shipping"