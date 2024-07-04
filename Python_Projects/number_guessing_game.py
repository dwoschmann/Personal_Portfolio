#Number Guessing Game Objectives:

# Allow the player to submit a guess for a number between 1 and 100.
# Check user's guess against actual answer. Print "Too high." or "Too low." depending on the user's answer. 
# If they got the answer correct, show the actual answer to the player.
# Track the number of turns remaining.
# If they run out of turns, provide feedback to the player. 
# Include two different difficulty levels (e.g., 10 guesses in easy mode, only 5 guesses in hard mode).

import random

random_number = (random.randint(1, 100))
difficulty = input("Type 'Easy' or 'Hard' mode. ").lower()
if difficulty == "hard":
    turns = 5
if difficulty == "easy":
    turns = 10
print(f"You have {turns} turns.")

guessing = True
while guessing:
    guess = int(input("Pick a number between 1 and 100: "))
    turns -= 1
    if guess == random_number:
        print(f"Correct! {random_number}")
        guessing = False
    elif turns == 0:
        print(f"Out of turns. Number was {random_number}")
        guessing = False
    elif guess < random_number:
        print("Too low")
        print(f"Number of turns remaining: {turns}")
    elif guess > random_number:
        print("Too High")
        print(f"Number of turns remaining: {turns}")
