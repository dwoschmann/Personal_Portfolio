from turtle import Turtle
import random

COLORS = ["red", "orange", "yellow", "green", "blue", "purple"]
STARTING_MOVE_DISTANCE = 5
MOVE_INCREMENT = 7.5


class CarManager:

    def __init__(self):
        self.all_cars = []
        # the cars the get created have to live somewhere, hence the empty list that we will add the new cars to
        self.car_speed = STARTING_MOVE_DISTANCE

        # there's no direct inheritance from another class (like CarManager(Turtle) or similar). The class is standalone and doesn't need to invoke any method from a parent class using super(). Therefore, the super() function is not required in the __init__ method of CarManager.

    def create_car(self):
        random_chance = random.randint(1, 6)
        if random_chance == 1:
            # this is to delay the amount of cars being created, computer keeps rolling "dice" and generates a car when it rolls a "1", this also provides some variability
            new_car = Turtle("square")
            new_car.shapesize(stretch_wid=1, stretch_len=2)
            new_car.penup()
            new_car.color(random.choice(COLORS))
            random_y = random.randint(-250, 250)
            new_car.goto(300, random_y)
            self.all_cars.append(new_car)

    def move_cars(self):
        for car in self.all_cars:
            car.backward(self.car_speed)

    def level_up(self):
        self.car_speed += MOVE_INCREMENT
