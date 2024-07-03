print("Welcome to the tip Calculator!")

bill = float(input("What was the total bill? "))
tip = int(input("How much would you like to tip 10, 12, or 15? "))
people = int(input("How many peeple are splitting the bill? "))
total_bill = float(bill + (bill / tip))
tip_share = float(total_bill / people)

formatted_share = "{:.2f}".format(tip_share)
# got this line from stackoverflow on how to format answer to a decimal

print(f"Each person should pay: ${formatted_share}")
# the "f" string lets it know that there is a value inside pf the curly braces{}
