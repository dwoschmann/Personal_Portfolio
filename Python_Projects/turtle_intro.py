from turtle import Turtle, Screen
import random

# Flag to control the race
is_race_on = False

# Create a Turtle screen
screen = Screen()
screen.setup(width=500, height=400)

# Get user's bet on the winning turtle
user_bet = screen.textinput(title="Make your bet", prompt="Which turtle will win the race? Enter a color: ")

# Define colors and starting positions for the turtles
colors = ["red", "orange", "yellow", "green", "blue", "purple"]
y_positions = [-70, -40, -10, 20, 50, 80]

# List to store all turtle instances
all_turtles = []

# Create 6 turtles and set their initial positions
for turtle_index in range(0, 6):
    new_turtle = Turtle(shape="turtle")
    new_turtle.penup()
    new_turtle.color(colors[turtle_index])
    new_turtle.goto(x=-230, y=y_positions[turtle_index])
    all_turtles.append(new_turtle)

# If the user made a bet, start the race
if user_bet:
    is_race_on = True

# Continue the race until a turtle reaches the finish line
while is_race_on:
    for turtle in all_turtles:
        # Check if a turtle has reached the finish line (x-coordinate > 230)
        if turtle.xcor() > 230:
            is_race_on = False
            winning_color = turtle.pencolor()

            # Check if the winning turtle's color matches the user's bet
            if winning_color == user_bet:
                print(f"You've won! The {winning_color} turtle is the winner!")
            else:
                print(f"You've lost! The {winning_color} turtle is the winner!")

        # Make each turtle move a random distance forward
        rand_distance = random.randint(0, 10)
        turtle.forward(rand_distance)

# Close the screen when clicked
screen.exitonclick()
