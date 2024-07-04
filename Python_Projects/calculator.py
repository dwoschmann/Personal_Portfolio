# Define four basic arithmetic functions for addition, subtraction, multiplication, and division
def add(n1, n2):
    return n1 + n2

def subtract(n1, n2):
    return n1 - n2

def multiply(n1, n2):
    return n1 * n2

def divide(n1, n2):
    return n1 / n2

# Note: Using 'return' instead of 'print' in functions
# In the arithmetic functions (add, subtract, multiply, divide), 'return' is used to return the result of the calculation.
# When you use 'return', the result is passed back from the function to the calling code, allowing you to store, manipulate, or display the result as needed.
# If 'print' were used instead of 'return' in these functions, they would only display the result on the console without providing a way to use the result in other parts of the program. Using 'return' allows you to work with the result programmatically, which is often the desired behavior when creating functions for calculations.

# Create a dictionary called 'operations' that maps operator symbols to their corresponding functions
operations = {
    "+": add,
    "-": subtract,
    "*": multiply,
    "/": divide,
}

# Define a function named 'calculator' to encapsulate the main functionality
def calculator():
    # Prompt the user for the first number and convert the input to a floating-point number
    num1 = float(input("First number? "))
    
    # Loop through the keys (operator symbols) in the 'operations' dictionary and print them
    for symbol in operations:
        print(symbol)
    
    # Prompt the user to pick an operation (operator symbol)
    operation_symbol = input("Pick an operation. ")
    
    # Prompt the user for the second number and convert the input to a floating-point number
    num2 = float(input("Second number? ")
    
    # Retrieve the appropriate calculation function from the 'operations' dictionary
    calculation_function = operations[operation_symbol]
    # The variable 'calculation_function' now holds the reference to the chosen operation function.
    
    # Perform the calculation by calling the selected function with 'num1' and 'num2'
    first_answer = calculation_function(num1, num2)
    # The selected operation function is called with 'num1' and 'num2', and the result is stored in 'first_answer'.
    
    # Print the result of the first calculation
    print(f"{num1} {operation_symbol} {num2} = {first_answer}")
    
    not_done_calculating = True
    
    # Start a loop for continued calculations
    while not_done_calculating:
        # Prompt the user to continue or exit
        keep_calculating = input(f"Type 'y' to keep calculating with {first_answer}, or type 'n' to exit? ")
        if keep_calculating == "y":
            # Prompt the user to pick another operation
            operation_symbol = input("Pick another operation: ")
            # Prompt the user for the next number and convert the input to a floating-point number
            num3 = float(input("What's the next number: "))
            # Retrieve the appropriate calculation function from the 'operations' dictionary based on the new operation symbol
            calculation_function = operations[operation_symbol]
            # Perform a new calculation using the result of the first calculation (first_answer) and num3
            second_answer = calculation_function(first_answer, num3)
            print(f"{first_answer} {operation_symbol} {num3} = {second_answer}")
            first_answer = second_answer
        else:
            # Set the loop condition to False to exit the loop
            not_done_calculating = False

# Call the 'calculator' function to start the calculation process
calculator()
