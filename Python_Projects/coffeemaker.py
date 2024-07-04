MENU = {
    "espresso": {
        "ingredients": {
            "water": 50,
            "coffee": 18,
        },
        "cost": 1.5,
    },
    "latte": {
        "ingredients": {
            "water": 200,
            "milk": 150,
            "coffee": 24,
        },
        "cost": 2.5,
    },
    "cappuccino": {
        "ingredients": {
            "water": 250,
            "milk": 100,
            "coffee": 24,
        },
        "cost": 3.0,
    }
}

resources = {
    "water": 300,
    "milk": 200,
    "coffee": 100,
}

money = 0

formatted_resources = f"Water: {resources['water']}ml\nMilk: {resources['milk']}ml\nCoffee: {resources['coffee']}g"
formatted_money = f"Money: ${money:.2f}"

def collect_money(drink_cost):
    quarters = int(input("How many quarters?: ")) * 0.25
    dimes = int(input("How many dimes?: ")) * 0.10
    nickels = int(input("How many nickels?: ")) * 0.05
    pennies = int(input("How many pennies?: ")) * 0.01
    collected_money = quarters + dimes + nickels + pennies
    if collected_money > drink_cost:
        change = round(collected_money - drink_cost, 2)
        print(f"Here's your change: ${change:.2f}")
        global money
        money += drink_cost
        global formatted_money
        formatted_money = f"Money: ${money:.2f}"
    else:
        print("Sorry, that's not enough.")


def make_drink(drink_type):
    drink_data = MENU[drink_type]
    drink_ingredients = drink_data["ingredients"]
    drink_cost = drink_data["cost"]
    for ingredient, required_amount in drink_ingredients.items():
        # Iterate through the ingredients required for the chosen drink.
        # 'ingredient' represents the name of the ingredient (e.g., "water").
        # 'required_amount' is the quantity of that ingredient needed for the drink.
        if resources.get(ingredient, 0) < required_amount:
            # Check if there are sufficient resources (e.g., water, milk, coffee) available for the selected drink.
            # The 'resources' dictionary is checked to see if there is enough of each required ingredient.
            # '.get(ingredient, 0)' retrieves the current amount of the ingredient, or 0 if it doesn't exist in 'resources'.
            print(f"Sorry, there is not enough {ingredient}.")
            return
            # The 'return' statement exits the 'make_drink' function immediately, preventing further execution.
    collect_money(drink_cost)
    for ingredient, required_amount in drink_ingredients.items():
        resources[ingredient] -= required_amount
        global formatted_resources
        formatted_resources = f"Water: {resources['water']}ml\nMilk: {resources['milk']}ml\nCoffee: {resources['coffee']}g"
    print(f"Here is your {drink_type}. Enjoy!")


making_coffee = True
while making_coffee:
    user_input = input("What would you like? (espresso/latte/cappuccino): ").lower()
    if user_input == "off":
        making_coffee = False
    elif user_input == "report":
        print(formatted_resources)
        print(formatted_money)
    elif user_input in MENU:
        make_drink(user_input)
