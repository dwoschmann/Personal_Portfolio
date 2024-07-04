student_scores = input("Input a list of student scores: ").split()
# 78 65 89 86 55 91 64 89
for n in range(0, len(student_scores)):
  student_scores[n] = int(student_scores[n])

highest_score = 0
for score in student_scores:
    if score > highest_score:
    # this will loop through each item in 'student_scores' and if it is greater than the last score it runs through, it will asign it to 'highest_score' starting from 0
        highest_score = score
        # heighest score = 0 -> 78 -> 78 -> 89 -> 89 -> 89 -> 91 -> 91 -> 91

print(f"The highest score in the class is: {highest_score}.")
