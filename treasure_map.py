row1 = ['O', 'O', 'O']
row2 = ['O', 'O', 'O']
row3 = ['O', 'O', 'O']
tmap = [row1, row2, row3]
print(f"{row1}\n{row2}\n{row3}")
position = input("Where do you want to put the treasure? ")
# "23" to get the 2nd collumn and 3rd row

horizontal = int(position[0])
vertical = int(position[1])
# indeces of lists must be integers

selected_row = tmap[vertical - 1]
# selects row based on "2[3]"
selected_row[horizontal - 1] = "X"
# selects and changes the row based on "[2]3"

print(f"{row1}\n{row2}\n{row3}")
