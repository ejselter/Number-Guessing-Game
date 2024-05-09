#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#Generate random number
SECRET=$((1 + $RANDOM % 1000))
echo $SECRET

#ask for username and give info
echo -e "\nEnter your username:"
read USERNAME
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name='$USERNAME'")
BEST_GUESS=$($PSQL "SELECT best_guess FROM users WHERE name='$USERNAME'")

if [[ -z $GAMES_PLAYED ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."

else
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."

fi

#define guessing functions
GUESSER(){
  read GUESS
}

HOT_COLD(){
  if [[ $GUESS > $SECRET ]]
  then
    echo "It's lower than that, guess again:"
    GUESSER
  else
    echo "It's higher than that, guess again:"
    GUESSER
  fi
}
#counter for guesses
COUNT=1

#guesser with while loops
echo "Guess the secret number between 1 and 1000:"
GUESSER

#check if number is integer
re='^[0-9]+$'
while ! [[ $GUESS =~ $re ]]
do
  echo "That is not an integer, guess again:"
  GUESSER

done

#loop for guessing until guess=secret
while [[ $GUESS != $SECRET ]]
do
  HOT_COLD
  COUNT=$((COUNT+1))
done

#correct guess and inserting guess data
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
INSERT_GAME_DATA=$($PSQL "INSERT INTO games(user_id, num_tries, secret) VALUES($USER_ID, $COUNT, $SECRET)")

BEST_GUESS=$($PSQL "SELECT MIN(num_tries) FROM games WHERE user_id=$USER_ID")
GAMES_PLAYED=$($PSQL "SELECT count(*) FROM games WHERE user_id=$USER_ID")

INSERT_BEST=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_guess=$BEST_GUESS WHERE user_id=$USER_ID")

echo "You guessed it in $COUNT tries. The secret number was $SECRET. Nice job!"
exit
