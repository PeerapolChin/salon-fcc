#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

# query list of services
SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
do
    echo "$SERVICE_ID) $SERVICE_NAME"
done


read SERVICE_ID_SELECTED
SERVICE_ID_SELECTED_RESULT=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# if no service 
  if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
# if have service    
  else
    # fill customer phone number 
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # check old customer name
    CHECK_CUSTOMER=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    MAKE_APPOINTMENT(){
    CUST_NAME=$($PSQL "SELECT name FROM customers WHERE name='$CUSTOMER_NAME'  AND phone='$CUSTOMER_PHONE' ")
    # CUSTOMER_NAME=
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE' AND name='$CUSTOMER_NAME'")
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    # format
    CUSTOMER_NAME_FORMAT=$(echo $CUSTOMER_NAME | sed 's/\s//g' -E)
    SERVICE_NAME_FORMAT=$(echo $SERVICE_NAME | sed 's/\s//g' -E)
    # APPOINTMENT TIME
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    # insert APP TIME
    INSERT_APP_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, '$SERVICE_ID', '$SERVICE_TIME')")
    # APP RESULT
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    }
        # if customer doesn't exist
        if [[ -z $CHECK_CUSTOMER ]]
        then
           # get new customer name
           echo -e "\nI don't have a record for that phone number, what's your name?"
           read CUSTOMER_NAME
           # insert new customer
           INSERT_CUS_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
           MAKE_APPOINTMENT
        # if customer does exist
        else
           MAKE_APPOINTMENT
        fi

  fi
}
MAIN_MENU