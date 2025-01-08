age: int
name: str
height: float
is_human: bool

# Type Hints
def police_check(age: int) -> bool:
# Helps prevent bugs before they happen with data types
    if age > 18:
        can_drive = True
    else:
        can_drive = False
    return can_drive


if police_check(12):
    print("You may pass")
else:
    print("Pay a fine.")
