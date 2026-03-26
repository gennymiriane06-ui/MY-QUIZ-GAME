#!/usr/bin/env bash

QUESTIONS_FILE="questions.txt"
HIGHSCORES_FILE="highscores.txt"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
BOLD="\e[1m"
DIM="\e[2m"
RESET="\e[0m"

divider() {
    echo -e "${DIM}────────────────────────────────────────────────────${RESET}"
}

show_highscores() {
    clear
    echo ""
    echo -e "${BOLD}${CYAN} TOP 5 HIGH SCORES ${RESET}"
    divider

    if [[ ! -f "$HIGHSCORES_FILE" || ! -s "$HIGHSCORES_FILE" ]]; then
        echo -e "  ${YELLOW}No scores recorded yet. Play a game first!${RESET}"
        echo ""
        exit 0
    fi

    local rank=1
    while IFS="|" read -r user score ratio date_played; do
        echo -e "  ${BOLD}${rank}.${RESET} ${CYAN}${user}${RESET}"
        echo -e "     Score   : ${YELLOW}${score}%${RESET}"
        echo -e "     Result  : ${ratio} correct"
        echo -e "     Date    : ${date_played}"
        divider
        (( rank++ ))
    done < <(sort -t"|" -k2 -rn "$HIGHSCORES_FILE" | head -5)

    echo ""
    exit 0
}

load_questions() {
    if [[ ! -f "$QUESTIONS_FILE" ]]; then
        echo -e "${RED}Error: '$QUESTIONS_FILE' not found.${RESET}"
        echo "Please create the questions file and try again."
        exit 1
    fi

    if [[ ! -s "$QUESTIONS_FILE" ]]; then
        echo -e "${RED}Error: '$QUESTIONS_FILE' is empty.${RESET}"
        exit 1
    fi

    QUESTIONS=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && QUESTIONS+=("$line")
    done < "$QUESTIONS_FILE"
}

shuffle_questions() {
    local count=${#QUESTIONS[@]}
    local shuffled_indexes
    shuffled_indexes=$(shuf -i 0-$(( count - 1 )))

    local new_order=()
    while read -r idx; do
        new_order+=("${QUESTIONS[$idx]}")
    done <<< "$shuffled_indexes"

    QUESTIONS=("${new_order[@]}")
}

ask_question() {
    local raw_line="$1"
    local q_number="$2"
    local q_total="$3"
    local mode="$4"

    IFS="|" read -r q_text opt_a opt_b opt_c opt_d correct_letter <<< "$raw_line"

    clear

    echo ""
    echo -e "${BOLD}${CYAN}  QUIZ GAME${RESET}"
    divider

    echo -e "  ${DIM}Question ${BOLD}${q_number}${RESET}${DIM} of ${q_total}${RESET}"
    echo ""

    echo -e "  ${BOLD}${YELLOW}${q_number}. ${q_text}${RESET}"
    echo ""

    echo -e "    ${opt_a}"
    echo -e "    ${opt_b}"
    echo -e "    ${opt_c}"
    echo -e "    ${opt_d}"
    echo ""
    divider

    local player_answer=""
    while true; do
        read -rp "  Your answer (A/B/C/D): " player_answer

        player_answer="${player_answer^^}"

        if [[ "$player_answer" == "A" || "$player_answer" == "B" || \
              "$player_answer" == "C" || "$player_answer" == "D" ]]; then
            break
        else
            echo -e "  ${RED}Invalid input. Please enter A, B, C, or D.${RESET}"
        fi
    done

    echo ""

    if [[ "$player_answer" == "$correct_letter" ]]; then
        ANSWER_CORRECT=1

        if [[ "$mode" == "practice" ]]; then
            echo -e "  ${GREEN}✔  Correct! (${correct_letter})${RESET}"
        fi
    else
        ANSWER_CORRECT=0

        if [[ "$mode" == "practice" ]]; then
            echo -e "  ${RED}✘  Incorrect. The correct answer was ${correct_letter})${RESET}"
        fi
    fi

    if [[ "$mode" == "practice" ]]; then
        echo ""
        read -rp "  Press Enter to continue…" _
    fi
}

run_game() {
    local mode="$1"

    clear
    echo ""
    echo -e "${BOLD}${CYAN}"
    echo -e "TERMINAL QUIZ GAME"
    echo -e "${RESET}"
    echo ""

    if [[ "$mode" == "practice" ]]; then
        echo -e "  ${YELLOW}Mode: PRACTICE${RESET} — answers shown after each question"
        echo -e "  ${DIM}No scores will be saved in this mode.${RESET}"
    else
        echo -e "  ${YELLOW}Mode: NORMAL${RESET} — score and streaks tracked"
    fi

    echo ""
    divider

    local username=""
    if [[ "$mode" == "normal" ]]; then
        while true; do
            read -rp "  Enter your name: " username
            username="${username// /_}"
            if [[ -n "$username" ]]; then
                break
            else
                echo -e "  ${RED}Name cannot be empty.${RESET}"
            fi
        done
        echo ""
        echo -e "  Welcome, ${CYAN}${username}${RESET}! Good luck."
    else
        echo -e "  Starting practice session…"
    fi

    echo ""
    read -rp "  Press Enter to begin…" _

    load_questions
    shuffle_questions

    local total=${#QUESTIONS[@]}

    local correct=0   
    local incorrect=0  
    local streak=0 
    local best_streak=0

    local i
    for (( i = 0; i < total; i++ )); do
        ask_question "${QUESTIONS[$i]}" "$(( i + 1 ))" "$total" "$mode"

        if [[ "$ANSWER_CORRECT" -eq 1 ]]; then
            (( correct++ ))
            (( streak++ ))

            if (( streak > best_streak )); then
                best_streak=$streak
            fi
        else
            (( incorrect++ ))
            streak=0
        fi
    done

    local score=0
    if (( total > 0 )); then
        score=$(( correct * 100 / total ))
    fi

    clear
    echo ""
    echo -e "${BOLD}${CYAN}  ── GAME OVER ──${RESET}"
    divider
    echo -e "  ${BOLD}Results for ${CYAN}${username:-"Practice"}${RESET}:"
    echo ""
    echo -e "  Correct answers   : ${GREEN}${correct}${RESET}"
    echo -e "  Incorrect answers : ${RED}${incorrect}${RESET}"
    echo -e "  Total questions   : ${total}"

    if [[ "$mode" == "normal" ]]; then
        echo -e "  Longest streak    : ${YELLOW}${best_streak}${RESET}"
    fi

    echo ""
    divider

    local grade=""
    if   (( score == 100 )); then grade="${GREEN}Perfect! 🏆${RESET}"
    elif (( score >= 80  )); then grade="${GREEN}Great job! 🌟${RESET}"
    elif (( score >= 60  )); then grade="${YELLOW}Good effort! 👍${RESET}"
    elif (( score >= 40  )); then grade="${YELLOW}Keep practising! 📚${RESET}"
    else                         grade="${RED}Better luck next time! 💪${RESET}"
    fi

    echo -e "  Final score : ${BOLD}${YELLOW}${score}%${RESET}   —  ${grade}"
    divider
    echo ""

    if [[ "$mode" == "normal" ]]; then
        local today
        today=$(date "+%Y-%m-%d")
        echo "${username}|${score}|${correct}/${total}|${today}" >> "$HIGHSCORES_FILE"
        echo -e "  ${DIM}Score saved to ${HIGHSCORES_FILE}.${RESET}"
        echo ""
    fi
}

case "$1" in

    highscores)
        show_highscores
        ;;

    practice)
        run_game "practice"
        ;;

    *)
        run_game "normal"
        ;;
esac