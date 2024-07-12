import smtplib
import datetime
import random

# Set your email credentials
my_email = "dwoschmann@gmail.com"
my_password = "mkcd dglo niif hpxh"

# Get the current date and weekday
now = datetime.datetime.now()
weekday = now.weekday()

# Check if today is Saturday (weekday == 5)
if weekday == 5:
    with open("quotes.txt") as quote_file:
        all_quotes = quote_file.readlines()
        random_quote = random.choice(all_quotes)

    # Establish a connection to the SMTP server
    with smtplib.SMTP("smtp.gmail.com") as connection:
        # Start TLS for secure communication
        connection.starttls()
        # Log in to your email account
        connection.login(user=my_email, password=my_password)
        connection.sendmail(
            from_addr=my_email,
            to_addrs="mleighlogan@gmail.com",
            msg=f"Subject:Saturday Motivation\n\n{random_quote}"
        )
