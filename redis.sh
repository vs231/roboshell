#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0.$TIMESTAMP.log/"
exec &>> $LOGFILE
$TIMESTAMP &>> $LOGFILE

VALIDATE (){
    if [ $1 -ne 0 ]
    then echo -e "$1 $R ERROR... $Y can't be installed"
    else
        echo -e " $2 $G installed successfully "
    fi
}

if [ $ID -ne 0 ]
then echo -e " $R ERROR... $Y you are not a root user"
else
    echo -e "$Y you are a $G root user" 
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? " installed redis" 

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "enabled redis"

dnf install redis -y &>> $LOGFILE
VALIDATE $? "installed redis"

sed -i 's/127.0.0.0/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE
VALIDATE $? "configuration updated"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "enabled redis"

systemctl startt redis &>> $LOGFILE
VALIDATE $? "started redis"