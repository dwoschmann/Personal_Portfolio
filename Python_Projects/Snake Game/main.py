from turtle import Screen
from snake import Snake
from food import Food
from scoreboard import Scoreboard
import time

# Set up the screen
screen = Screen()
screen.setup(width=600, height=600)
screen.bgcolor("black")
screen.title("My Snake Game")
screen.tracer(0)  # Turn off automatic screen updates

# Create instances of the Snake, Food, and Scoreboard classes
snake = Snake()  # Snake class represents the player-controlled snake
food = Food()  # Food class represents the food the snake can eat
scoreboard = Scoreboard()  # Scoreboard class manages the game score

# Listen for key events to control the snake
screen.listen()
screen.onkey(snake.up, "Up")
screen.onkey(snake.down, "Down")
screen.onkey(snake.left, "Left")
screen.onkey(snake.right, "Right")

# Game loop
game_is_on = True
while game_is_on:
    screen.update()  # Update the screen manually
    time.sleep(0.1)  # Introduce a delay for smoother animation
    snake.move()  # Move the snake

    # Check if the snake has eaten the food
    if snake.head.distance(food) < 15:
        food.refresh()  # Move the food to a new random position
        snake.extend()  # Extend the length of the snake
        scoreboard.increase_score()  # Update the score

    # Check if the snake has hit the wall
    if (
        snake.head.xcor() > 280
        or snake.head.xcor() < -280
        or snake.head.ycor() > 280
        or snake.head.ycor() < -280
    ):
        game_is_on = False
        scoreboard.game_over()  # Display game over message

    # Check for collisions with the snake's own body
    for segment in snake.segments:
        if segment == snake.head:
            pass
        elif snake.head.distance(segment) < 10:
            game_is_on = False
            scoreboard.game_over()  # Display game over message

screen.exitonclick()
