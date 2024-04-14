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

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "diabled mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "version modified"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "installed mysql" 

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "enabled mysql"

systemctl started mysqld &>> $LOGFILE
VALIDATE $? "started mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "mysql installation done"

mysql -uroot -pRoboShop@1 &>> $LOGFILE
VALIDATE $? "mysql rooted to roboshop"