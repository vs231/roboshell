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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Downloading erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "rabitt script dwnld"

dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "installed rabbit"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "enabled rabbit"

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "started rabbit"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "user added"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "permissions given"