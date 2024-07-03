print("Welcome to Treasure Island!")
print("Your mission is to find the treasure.")

step1 = input("Left or Right? ").lower()
if step1 == "left": 
    step2 = input("Swim or Wait? ").lower()
    if step2 == "wait":
        step3 = input("Which door? ").lower()
        if step3 == "yellow":
            print("You win!")
        elif step3 == "blue":
            print("Eaten by beasts, game over.")
        elif step3 == "red":
            print("Burned by fire, game over.")
        else:
            print("Game Over")
    else:
        print("Attacted by a trout, game over.")
else:
    print("You fell into a hole, game over.")
