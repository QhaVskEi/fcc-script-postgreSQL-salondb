#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"
echo -e "Welcome to My Salon, how can i help you?\n"

MAIN_SALON(){
  
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  MY_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$MY_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo  "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_SALON "You've enter invalid input"
  else
    SERVICES_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

    if [[ -z $SERVICES_AVAILABLE ]]
    then
      MAIN_SALON "I could not find that service. What would you like today?"

    else
      echo -e "What's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        CUSTOMER_NAME_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME

    APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME','$CUSTOMER_ID','$SERVICE_ID_SELECTED')")
    
    GET_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    FORMATED_SERVICE=$(echo $GET_SERVICE | sed 's/^ //g')
    FORMATED_CUSTOMER=$(echo $CUSTOMER_NAME | sed 's/^ //g')
    echo -e "\nI have put you down for a $FORMATED_SERVICE at $SERVICE_TIME, $FORMATED_CUSTOMER."
    fi
  fi
}


MAIN_SALON
