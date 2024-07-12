from question_model import Question
from data import question_data
from quiz_brain import QuizBrain
from ui import QuizInterface

# Creating an empty list to store Question objects
question_bank = []

# Converting question_data into Question objects and adding them to the question_bank list
for question in question_data:
    question_text = question["question"]
    question_answer = question["correct_answer"]
    new_question = Question(question_text, question_answer)
    question_bank.append(new_question)

# Creating an instance of QuizBrain with the question_bank
quiz = QuizBrain(question_bank)

# Creating an instance of QuizInterface with the quiz instance
quiz_ui = QuizInterface(quiz)

# Running the quiz loop until there are no more questions
while quiz.still_has_questions():
    quiz.next_question()

print("You've completed the quiz")
print(f"Your final score was: {quiz.score}/{quiz.question_number}")
