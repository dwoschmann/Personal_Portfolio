import random
import time

def deal_card(cards):
    # This function randomly selects a card from the given list of cards (deck).
    return random.choice(cards)

def calculate_score(hand):
    # This function calculates the score of a given hand based on the Blackjack rules.
    # If the sum of the hand is exactly 21 and it consists of only two cards, it's a Blackjack, and the function returns 0.
    if sum(hand) == 21 and len(hand) == 2:
        return 0
    # If the hand contains an Ace (with a value of 11), and the total score exceeds 21,
    # it converts the Ace's value from 11 to 1 by removing 11 and appending 1.
    if 11 in hand and sum(hand) > 21:
        hand.remove(11)
        hand.append(1)
    # The function returns the total sum of the hand's values.
    return sum(hand)

# Define the main Blackjack game function
def blackjack():
    cards = [11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]
    user_hand = []
    dealer_hand = []

    # Initialize the deck of cards and hands for both the user and the dealer.
    # The deck is represented as a list of card values where 11 is an Ace, and 10 represents the 10-point cards (10, Jack, Queen, King).
    # The user and dealer hands are initially empty.

    # Deal two cards to the user and the dealer.
    user_hand.extend([deal_card(cards), deal_card(cards)])  # Add two cards to the user's hand
    dealer_hand.extend([deal_card(cards), deal_card(cards)])  # Add two cards to the dealer's hand

    user_score = calculate_score(user_hand)
    dealer_score = calculate_score(dealer_hand)

    # Calculate the initial scores for the user and dealer based on the card values in their hands.

    print(f"Your cards: {user_hand}, Score: {user_score}")
    print(f"Dealer's cards: [{dealer_hand[0]}, Face Down]")

    # Check for Blackjack (21 with two cards) for the user or dealer.
    # If the user's or dealer's initial hand value is exactly 21, and it consists of only two cards, it's a Blackjack, and this is printed to the screen.
    if user_score == 0 or dealer_score == 0:
        print("Blackjack!")

    # If the user's score is not 21, start the user's turn
    if user_score != 21:
        while True:
            # Start a loop for the user's turn. It keeps asking the user whether they want to "hit" (draw another card) or "stand."
            hit = input("Do you want to hit? Type 'y' for yes or 'n' for no: ")
            if hit == 'y':
                # If the user chooses to hit, draw a new card for the user, add it to their hand, and recalculate their score.
                new_user_card = deal_card(cards)
                user_hand.append(new_user_card)
                user_score = calculate_score(user_hand)
                print(f"New card: {new_user_card}")
                print(f"Your cards: {user_hand}, current score: {user_score}")
                if user_score == 21:
                    break
                elif user_score > 21:
                    break
            elif hit == 'n':
                break
                
    # Print the dealer's hand after the user's turn before the dealer's turn starts.
    print(f"Dealer's cards: {dealer_hand}")
    # Add a small pause in time (e.g., 1 second) to create a delay before the dealer's turn.
    time.sleep(1)
    
    # Start the dealer's turn, where the dealer automatically follows a simple rule:
    # If the dealer's score is less than 17, they keep drawing cards.
    # This loop ensures the dealer's hand is at least 17 points or as close to 21 as possible.
    for _ in range(2):
        if dealer_score != 21 and dealer_score < 17:
            new_dealer_card = deal_card(cards)
            dealer_hand.append(new_dealer_card)
            dealer_score = calculate_score(dealer_hand)
            if dealer_score > 21:
                break

    print(f"Your final hand: {user_hand}, final score: {user_score}")
    print(f"Dealer's final hand: {dealer_hand}, final score: {dealer_score}")

    if user_score > 21:
        print("You went over. You lose")
    elif dealer_score > 21:
        print("Opponent went over. You win")
    elif user_score == dealer_score:
        print("Draw")
    elif user_score == 0 and dealer_score == 0:
        print("Blackjack!")
    elif user_score > dealer_score:
        print("You win")
    else:
        print("You lose")

keep_playing = True
while keep_playing:
    blackjack()
    play_again = input("Do you want to play again? Type 'y' for yes or 'n' for no: ")
    if play_again != "y":
        keep_playing = False
