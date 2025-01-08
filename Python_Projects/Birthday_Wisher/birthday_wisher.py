import pandas
import smtplib
import datetime
import random

my_email = "dwoschmann@gmail.com"
my_password = "mkcd dglo niif hpxh"

today = datetime.datetime.now()
# Extract the month and day from the current date
today_tuple = (today.month, today.day) # (2, 3)
data = pandas.read_csv("birthdays.csv")
# Use dictionary comprehension to create a dictionary with (month, day) tuples as keys and corresponding data rows as values
birthdays_dict = {
    (data_row.month, data_row.day): data_row for (index, data_row) in data.iterrows()
}
# birthdays_dict = {
#     (12, 21): {'name': 'Test', 'email': 'dwoschmann@gmail.com', 'year': 1961, 'month': 2, 'day': 3},
#     (8, 19): {'name': 'Daniel', 'email': 'dwoschmann@gmail.com', 'year': 1998, 'month': 8, 'day': 19},
#     (11, 6): {'name': 'Mady', 'email': 'mleighlogan@gmail.com', 'year': 1998, 'month': 11, 'day': 6},
# }

if today_tuple in birthdays_dict:
    # Retrieving the birthday person's information from the dictionary using today's date as the key
    birthday_person = birthdays_dict[today_tuple]
    # {'name': 'Test', 'email': 'dwoschmann@gmail.com', 'year': 1961, 'month': 12, 'day': 21},
    birthday_email = birthday_person["email"]
    letter_file_path = f"letter_templates/letter_{random.randint(1, 3)}.txt"

    with open(letter_file_path) as letter_file:
        contents = letter_file.read()
        custom_letter = contents.replace("[NAME]", birthday_person["name"])

    with smtplib.SMTP("smtp.gmail.com") as connection:
        connection.starttls()
        connection.login(user=my_email, password=my_password)
        connection.sendmail(
            from_addr=my_email,
            to_addrs=f"{birthday_email}",
            msg=f"Subject:Happy Birthday!\n\n{custom_letter}"
        )
