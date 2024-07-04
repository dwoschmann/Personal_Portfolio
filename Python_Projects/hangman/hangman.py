import random
import hangman_words
# importing list of random words from a different notepad file
random_word = random.choice(hangman_words.word_list)

from hangman_art import stages
from hangman_art import logo
print(logo)
# importing ASCI art from different notepad file

display = []
for blanks in range(len(random_word)):
    display += "_"
    # creates the list of blank spaces that is the length of the word
print(display)
['_', '_', '_', '_', '_', '_', '_']

end_of_game = False
lives = 7
# lives corespondes with how many stages of hangman art there are

while not end_of_game:
    # this loops the game until there are no more "_" in display
    guess = input("Guess a random letter: ").lower()  
    if guess in display:
        print(f"Already guessed {guess}.")   
    
    for postion in range(len(random_word)):
        letter = random_word[postion]
        # the for loop will loop through each "_"...
        if letter == guess:
        # and if the letter is mathed up with the postion in the display...
            display[postion] = letter
            print(display)
            # ['a', '_', '_', '_', 'a', '_', '_']
            # it will repalce the "_" with the correctly guessed letter    
    
    if guess not in random_word:
    # this if statement must be outside the for loop since it is a different condition
        lives -= 1
        print(stages[lives])
        if lives == 0:
            end_of_game = True
             # flips while loop to true which ends the loop
            print("You Lose.")
            print(random_word)    
    
    if "_" not in display:
        end_of_game = True
        print(random_word)
        print("You Win")
