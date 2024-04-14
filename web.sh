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

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "installed nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enabled nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "started nginx"

rm -rf /usr/share/nginx/html/* &>> &LOGFILE
VALIDATE $? "old html code removed"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? " zip file downloaded"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "!...."

unzip /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unzipped the file"

cp /home/centos/roboshell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "configuration changed"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "restarted nginx" 



