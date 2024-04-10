#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMEST=$(date +%F-%H-%M-%S)
LOGFILE=/tmp/$0-TIMEST.log/

VALIDATE()
{
    if [ $1 -ne 0 ]
    then
        echo -e "$R Error $N can't install the package "
        exit 1
    else
        echo -e " $Y $2 $G succefully installed"
    fi
}
if [ $ID -ne 0 ]
then
    echo -e "$R Error... $N you are not root user" 
    exit 1
else
     echo " you are root user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied mongo.repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "installed mongodb"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enabled mongodb"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "started mongo"

sed -i '/s/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "changed the confg successfully"

systemctl restart mongod
VALIDATE $? "restarted the mongodb" 