import turtle
import pandas

# Set up the turtle screen and load the U.S. states data
screen = turtle.Screen()
screen.title("U.S. States Game")
image = "blank_states_img.gif"
screen.addshape(image)
turtle.shape(image)

# Read the U.S. states data from a CSV file
data = pandas.read_csv("50_states.csv")
all_states = data.state.to_list()
guessed_states = []

# Loop until the user guesses all 50 states or types "Exit"
while len(guessed_states) < 50:
    # Get user input for state guessing
    answer_state = screen.textinput(title=f"{len(guessed_states)}/50 States Correct", prompt="What's another state's name?").title()
    if answer_state == "Exit":
        # Create a list of missed states using list comprehension
        missing_states = [state for state in all_states if state not in guessed_states]

        # Create a new DataFrame with missed states
        new_data = pandas.DataFrame(missing_states)

        # Save the DataFrame to a CSV file named "states_to_learn.csv"
        new_data.to_csv("states_to_learn.csv")

        # Exit the loop, ending the game
        break

    # Check if the guessed state is correct
    if answer_state in all_states:
        # Add the correct state to the list of guessed states
        guessed_states.append(answer_state)

        # Create a turtle to mark the guessed state on the map
        t = turtle.Turtle()
        t.hideturtle()
        t.penup()

        # Get coordinates of the guessed state from the data DataFrame
        state_data = data[data.state == answer_state]

        # Move the turtle to the specified coordinates on the map
        # .x and .y extract the X and Y coordinates from the DataFrame, and t.goto() moves the turtle to those coordinates, visually indicating the correct guesses on the map.
        t.goto(int(state_data.x), int(state_data.y))

        # Write the name of the guessed state on the map
        t.write(answer_state)
