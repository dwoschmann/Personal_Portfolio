from turtle import Screen
from paddle import Paddle
from ball import Ball
from scoreboard import Scoreboard
import time

screen = Screen()
screen.bgcolor("black")
screen.setup(width=800, height=600)
screen.title("Pong")
screen.tracer(0)

right_paddle = Paddle((350, 0))
left_paddle = Paddle((-350, 0))
ball = Ball()
scoreboard = Scoreboard()

game_is_on = True
while game_is_on:
    time.sleep(ball.move_speed)
    screen.update()
    ball.move()

    if ball.ycor() > 280 or ball.ycor() < -280:
        ball.bounce_y()
    if ball.distance(right_paddle) < 50 and ball.xcor() > 320:
        ball.bounce_x()
    if ball.distance(left_paddle) < 50 and ball.xcor() < -320:
        ball.bounce_x()

    if ball.xcor() > 380:
        ball.reset()
        scoreboard.left_point()
        scoreboard.update_score()
    if ball.xcor() < -380:
        ball.reset()
        scoreboard.right_point()
        scoreboard.update_score()

    screen.listen()
    screen.onkey(right_paddle.go_up, "Up")
    screen.onkey(right_paddle.go_down, "Down")
    screen.onkey(left_paddle.go_up, "w")
    screen.onkey(left_paddle.go_down, "s")


screen.exitonclick()
