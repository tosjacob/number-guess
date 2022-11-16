#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUM=$(($RANDOM % 1000 + 1))
COUNT=1
echo "Enter your username:"
read USERNAME

USER=$($PSQL "SELECT games, best FROM user_info where username = '$USERNAME'")

if [[ -z $USER ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ADDED=$($PSQL "INSERT INTO user_info(username) VALUES ('$USERNAME')")
  BEST=10000
  GAMES=0
else
  GAMES=$($PSQL "SELECT games FROM user_info WHERE username = '$USERNAME'")
  BEST=$($PSQL "SELECT best FROM user_info WHERE username = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

while (( $GUESS != $NUM ))
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
  elif [[ $GUESS -gt $NUM ]]
  then
    echo "It's lower than that, guess again:"
    ((COUNT++))
    read GUESS
  else
    echo "It's higher than that, guess again:"
    ((COUNT++))
    read GUESS
  fi
done

((GAMES++))
UPDATE=$($PSQL "UPDATE user_info SET games = $GAMES where username = '$USERNAME'")

if [[ $COUNT -lt $BEST ]]
then
UPDATE=$($PSQL "UPDATE user_info SET best = $COUNT where username = '$USERNAME'")
fi

echo "You guessed it in $COUNT tries. The secret number was $NUM. Nice job!"