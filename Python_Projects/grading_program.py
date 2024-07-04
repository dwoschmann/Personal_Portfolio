student_scores = {
    "Harry": 81,
    "Ron": 78,
    "Hermione": 99,
    "Draco": 74,
    "Neville": 62,
}

# Initialize an empty dictionary 'student_grades'
student_grades = {}

# Iterate through each student in 'student_scores'
for student in student_scores:
    # Get the score for the current student
    score = student_scores[student]
    
    # Determine the grade based on the score using conditional statements
    if score > 90:
        student_grades[student] = "Outstanding"
    elif score > 80:
        student_grades[student] = "Exceeds Expectations"
    elif score > 70:
        student_grades[student] = "Acceptable"
    else:
        student_grades[student] = "Fail"

print(student_grades)
