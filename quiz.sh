#!/bin/bash

# Simple quiz game
FILE="questions.txt"

# Check file
if [[ ! -f "$FILE" ]]; then
  echo "questions.txt not found!"
  exit 1
fi

clear
echo "WELCOME TO THE QUIZ!"
echo

mapfile -t QUESTIONS < "$FILE"
TOTAL=${#QUESTIONS[@]}
CORRECT=0

for line in "${QUESTIONS[@]}"; do
  IFS='|' read -r Q A B C D ANS <<< "$line"

  echo "$Q"
  echo "  $A"
  echo "  $B"
  echo "  $C"
  echo "  $D"
  echo

  read -rp "Your answer (A/B/C/D): " REPLY
  REPLY=$(echo "$REPLY" | tr '[:lower:]' '[:upper:]')

  if [[ "$REPLY" == "$ANS" ]]; then
    echo "Correct!"
    ((CORRECT++))
  else
    echo "Wrong! Correct answer: $ANS"
  fi

  echo
done

echo "You got $CORRECT out of $TOTAL correct!"
it a