import random

names_string =  input("Enter names, seperated by a comma. ")
names = names_string.split(", ")

print(names)
# Daniel, Mady, Sydney, Kennedy, Ernie

num_items = len(names)
# gives us the length of the list = 5
random_choice = random.randint(0, num_items - 1)
# index however needs to be [0, 4] so num_items - 1 = 4
person_who_will_pay = names[random_choice]

print(f"{person_who_will_pay} is going to pay today.")
