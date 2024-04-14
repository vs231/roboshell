#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(data +%F-%H-%M-%S)
LOGFILE=/tmp/$0.$TIMESTAMP.log/
$TIMESTAMP &>> $LOGFILE
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R $1 $Y check the error "
    else 
        echo -e " $G $2  $Y installed successfuly"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e " $R ERROR $Y your r not a root user"
else
    echo -e " $N You are $G root user"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? " disabled node js"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabled nodejs"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "installed nodejs"

if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "useradded"
else
    echo -e "$N user already added .....$Y skipping"
fi

mkdir -p /app 
VALIDATE $? "app created"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "file downloaded"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? " file unzipped"

npm install &>> $LOGFILE
VALIDATE $? " installed npm"

cp /home/centos/roboshell/user.service /etc/systemd/system/user.service &>> LOGFILE
VALIDATE $? "coppied user service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " daemon reloaded "

systemctl enable user &>> $LOGFILE
VALIDATE $? "enabled user"

systemctl start user &>> $LOGFILE
VALIDATE $? "user started"

cp /home/centos/roboshell/mongo.sh /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "routed to mongo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "installed mongo"

mongo --host mongodb.vs-devops.online </app/schema/user.js &>> $LOGFILE
VALIDATE $? " connected to mongo successfully"