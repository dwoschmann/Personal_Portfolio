student_heights = input("Input a list of student heights: ").split()
# 156 178 165 171 187
for n in range(0, len(student_heights)):
    student_heights[n] = int(student_heights[n])

total_height = 0
for height in student_heights:
    total_height += height
# this for loop replicates the sum() function
# each item in student_heights list is named to "height"
# total_height = 857

number_of_students = 0
for student in student_heights:
    number_of_students += 1
# this for loop replicates the len() function
# each item in number_of_students list is named to "student"
# number_of_students = 5

average_height = round(total_height / number_of_students)
print(average_height)
