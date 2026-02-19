#!/bin/bash

QUESTION_FILE="Question.txt"
HIGHSCORE_FILE="highscore.txt"

touch "$HIGHSCORE_FILE"

show_highscores() {
    echo "===== HIGHSCORES ====="
    if [[ ! -s "$HIGHSCORE_FILE" ]]; then
        echo "No highscores yet."
    else
        sort -t '|' -k2 -nr "$HIGHSCORE_FILE" | head -10
    fi
    exit 0
}

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
        echo "Wrong! Correct answer was $ANSWER"
        streak=0
        incorrect=$((incorrect + 1))
    fi

    sleep 1
    clear
}

run_quiz() {

    echo "Welcome to Quiz Game"
    read -r -p "What is your name? " player_name
    echo "Hello, $player_name. Let us begin!"
    echo

    if [[ ! -f "$QUESTION_FILE" ]]; then
        echo "Error: Question file not found."
        exit 1
    fi

    mapfile -t QUESTIONS < "$QUESTION_FILE"
    mapfile -t SHUFFLED < <(shuf -i 0-$((${#QUESTIONS[@]} - 1)))

    score=0
    streak=0
    longest_streak=0
    incorrect=0
    TOTAL_QUESTIONS=${#QUESTIONS[@]}

    for idx in "${SHUFFLED[@]}"; do
        line="${QUESTIONS[$idx]}"

        Q=$(echo "$line" | cut -d '|' -f1)
        A=$(echo "$line" | cut -d '|' -f2)
        B=$(echo "$line" | cut -d '|' -f3)
        C=$(echo "$line" | cut -d '|' -f4)
        D=$(echo "$line" | cut -d '|' -f5)
        ANSWER=$(echo "$line" | cut -d '|' -f6 | tr -d '[:space:]')

        ask_question "$Q" "$A" "$B" "$C" "$D" "$ANSWER"
    done

    percent=$(((score * 100) / TOTAL_QUESTIONS))
    DATE=$(date)

    echo "$player_name|$score|$percent%|$DATE" >> "$HIGHSCORE_FILE"

    echo "===== RESULTS ====="
    echo "Correct: $score"
    echo "Incorrect: $incorrect"
    echo "Longest streak: $longest_streak"
    echo "Final score: $percent%"
}

run_practice() {
    echo "Practice Mode (scores not saved)"
    run_quiz
}

case "$1" in
    highscores)
        show_highscores
        ;;
    practice)
        run_practice
        ;;
    "")
        run_quiz
        ;;
    *)
        echo "Usage:"
        echo "./quiz.sh"
        echo "./quiz.sh practice"
        echo "./quiz.sh highscores"
        exit 1
        ;;
esac
