#!/bin/bash

echo "welcome to quiz  game"

read -r -p " what is your name?:" player_name
name=$player_name

echo "Hello, $name welcome to Quiz Game. let us begin"
echo

QUESTION_FILE="Question.txt"
 export HIGHSCORE_FILE="highscore.txt"
longest_streak=0
# create highscore file if missing

# check if question file exists
if [[ ! -f "$QUESTION_FILE" ]]; then
    echo "Error: Question file '$QUESTION_FILE' not found"
    exit 1
fi
# load questions into an array
while IFS= read -r line; do
    QUESTIONS+=("$line")
done < "$QUESTION_FILE"
# shuffle questions using shuf
 mapfile -t SHUFFLED < <(shuf -i 0-$((${#QUESTIONS[@]} - 1)))
score=0
Date=$(date)
streak=0
incorrect=0
TOTAL_QUESTIONS=${#QUESTIONS[@]}
ask_question() {
    local QUESTION="$1"
    local A="$2"
    local B="$3"
    local C="$4"
    local D="$5"
    local ANSWER="$6"
    echo "$QUESTION"
    echo "$A"   
    echo "$B"
    echo "$C"
    echo "$D"
    read -r -p "Your answer (A/B/C/D): " USER_ANSWER
    USER_ANSWER=$(echo "$USER_ANSWER" | tr '[:lower:]' '[:upper:]')
    if [[ "$USER_ANSWER" == "$ANSWER" ]]; then
        echo "Correct!"
        score=$((score + 1))
        streak=$((streak + 1))
        if [[ $streak -gt $longest_streak ]]; then
            longest_streak=$streak
        fi
    else
        echo "Wrong!"
        streak=0
        incorrect=$((incorrect + 1))
    fi
    sleep 1.5
    clear
}
# loop through shuffled questions
for idx in "${SHUFFLED[@]}"; do
    line="${QUESTIONS[$idx]}"
    Q=$(echo "$line" | cut -d '|' -f1)
    A=$(echo "$line" | cut -d '|' -f2)
    B=$(echo "$line" | cut -d '|' -f3)
    C=$(echo "$line" | cut -d '|' -f4)
    D=$(echo "$line" | cut -d '|' -f5)
    ANSWER=$(echo "$line" | cut -d '|' -f6 | tr -d ' [:space:]')
    ask_question "$Q" "$A" "$B" "$C" "$D" "$ANSWER"
done
echo ""
echo -e "$name|$score|$score/$TOTAL_QUESTIONS|$Date" >> highscore.txt

percent=$(((score * 100) / TOTAL_QUESTIONS ))
echo "Correct: $score Incorrect: $incorrect Winning streak: $longest_streak Final score: $percent% "



