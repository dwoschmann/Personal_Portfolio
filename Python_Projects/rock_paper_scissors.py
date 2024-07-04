import random

rock = '''
    _______
---'   ____)
      (_____)
      (_____)
      (____)
---.__(___)
'''

paper = '''
    _______
---'   ____)____
          ______)
          _______)
         _______)
---.__________)
'''

scissors = '''
    _______
---'   ____)____
          ______)
       __________)
      (____)
---.__(___)
'''

cpu_choice = random.randint(0, 2)
user_choice = int(input("What do you choose? Type 0 for Rock, 1 for Paper or 2 for Scissors. "))

if user_choice == 0:
    if cpu_choice == 1:
        print("You lose")
    elif cpu_choice == 2:
        print ("You win")
else:
    print("You tie")

if user_choice == 1:
    if cpu_choice == 2:
        print("You lose")
    elif cpu_choice == 0:
        print ("You win")
    else:
        print("You tie")


if user_choice == 2:
    if cpu_choice == 0:
        print("You lose")
    elif cpu_choice == 1:
        print ("You win")
    else:
        print("You tie")
