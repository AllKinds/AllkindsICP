/*
Here is the task:

I have a list of users (type Principal). Users can create questions (question type should contain it's author). Every user can answer any questions with yes, no answer or skip the question. Besides yes/no answer user can add a weight (from -100 - not important at all, to 100 - very important, 0 - neutral) that indicates the importance of the question.
Please create all types and several functions. 
The first function takes two users as arguments and returns a cohesion score. Cohesion score is calculated as a percentage of the same answers to the same questions between these two users weighted upon importances of both users for this question. Note that when users reply to questions they can be sorted differently. thus answers sets can be of different length and sorted differently for these two users.
the second function takes a user as an argument and returns a list of users sorted by cohesion score described above.
also functions that create a question (with it's author user), delete it and all answers related to this question, edit the question (available to the author only).
function that takes a question as an argument and return number of yes answers, number of no answers.

also users has a balance. when a new user is created it has initial balance of 100 coins. When a user add a weight to a question - it gives this amount of coins to the author of the question and this amount is subtracted with the balance. the author's balance is also updated.

implement also data structure to store users. and functions on create/edit/delete/suspend user/get user details (Name, Balance, Age, Gender, Picture (image 400 on 600 pixels), Lastknownlocation, List of answered questions with answers).

add a function to get next unanswered question from the list of questions sorted by average importance of questions.

Implement this logic: when a question gets -50 importance in total - this question should be removed from all questions pool and put to Suspended list.
*/

//and this is what it generated:
// Define types

// Define types

type Weight = Int {-100..100};

type Answer = record {
  user: Principal;
  answer: ?Bool;
  weight: Weight;
};

type Question = record {
  author: Principal;
  question: Text;
  answers: [Answer];
  avgImportance: Float;
  totalImportance: Int;
};

type User = record {
  principal: Principal;
  suspended: Bool;
  balance: Nat;
  name: Text;
  age: Nat;
  gender: Text;
  picture: Text;
  lastKnownLocation: Text;
  answeredQuestions: [(Question, ?Bool)];
};

// Define data structures

var allQuestions : [Question] = [];

var suspendedQuestions : [Question] = [];

var allUsers : [User] = [];

// Define functions

public func calculateCohesionScore(user1: Principal, user2: Principal) : Float {
  let questions1 = getAllQuestionsByUser(user1);
  let questions2 = getAllQuestionsByUser(user2);
  
  let commonQuestions = getCommonQuestions(questions1, questions2);
  
  if (commonQuestions.count() == 0) {
    return 0.0;
  }
  
  var sumWeights : Float = 0.0;
  var sumWeights1 : Float = 0.0;
  var sumWeights2 : Float = 0.0;
  
  for (q in commonQuestions) {
    let ans1 = getAnswerByUser(q.answers, user1);
    let ans2 = getAnswerByUser(q.answers, user2);
    if (ans1 != null && ans2 != null && ans1.answer == ans2.answer) {
      let weight = Float(ans1.weight + ans2.weight) / 200.0;
      sumWeights += weight;
      sumWeights1 += weight * Float(ans1.weight) / 100.0;
      sumWeights2 += weight * Float(ans2.weight) / 100.0;
    }
  }
  
  let score1 = sumWeights1 / sumWeights;
  let score2 = sumWeights2 / sumWeights;
  
  return (score1 + score2) / 2.0;
}

public func getUsersSortedByCohesionScore(user: Principal) : [User] {
  var usersWithScores : [(User, Float)] = [];
  
  for (u in allUsers) {
    if (u.principal != user && !u.suspended) {
      let score = calculateCohesionScore(user, u.principal);
      usersWithScores := usersWithScores ++ [(u, score)];
    }
  }
  
  return List.sort(usersWithScores, \(a, b) => a.1 > b.1).map(\.0);
}

public func createQuestion(author: Principal, question: Text) : Question {
  let q = {author = author; question = question; answers = []; avgImportance = 0.0; totalImportance = 0;};
  allQuestions := allQuestions ++ [q];
  return q;
}

public func deleteQuestion(question: Question) {
  allQuestions := List.filter(allQuestions, q => q != question);
  suspendedQuestions := List.filter(suspendedQuestions, q => q != question);
}

public func editQuestion(question: Question, newQuestion: Text) {
  question.question := newQuestion;
}

public func addAnswer(question: Question, user: Principal, answer: ?Bool, weight: Weight) {
  let ans = {user = user; answer = answer; weight = weight;};
  question.answers := question.answers ++ [ans];
  
  if (answer != null) {
    question.totalImportance += weight;
    question.avgImportance = Float(question.totalImportance) / Float(question.answers.count());
    
    if (question.totalImportance <= -50) {
      suspendedQuestions := suspendedQuestions ++ [question];
      allQuestions := List.filter(allQuestions, q => q != question);
    }
  }
  
  let author = getUserByPrincipal(question.author);
  if (author != null) {
    author.balance += weight;
  }
  
  let userAnsweredQuestion = getUserByPrincipal(user)?.answeredQuestions;
  if (userAnsweredQuestion != null) {
    userAnsweredQuestion := userAnsweredQuestion ++ [(question, answer)];
  }
}

public func getAnswerStats(question: Question) : (yesCount: Int, noCount: Int) {
  let yesCount = question.answers.filter(a => a.answer == true).count();
  let noCount = question.answers.filter(a => a.answer == false).count();
  return (yesCount, noCount);
}

public func createUser(principal: Principal, name: Text, age: Nat, gender: Text, picture: Text, lastKnownLocation: Text) : User {
  let newUser : User = {
    principal = principal;
    suspended = false;
    balance = 100;
    name = name;
    age = age;
    gender = gender;
    picture = picture;
    lastKnownLocation = lastKnownLocation;
    answeredQuestions = [];
  };
  allUsers := allUsers ++ [newUser];
  return newUser;
}

public func suspendUser(user: User) {
  user.suspended = true;
}

public func unsuspendUser(user: User) {
  user.suspended = false;
}

public func deleteUser(user: User) {
  allUsers := List.filter(allUsers, u => u != user);
}

public func getUserDetails(user: User) : (Text, Nat, Text, Text, Text, [(Question, ?Bool)]) {
  return (user.name, user.age, user.gender, user.picture, user.lastKnownLocation, user.answeredQuestions);
}

public func getNextUnansweredQuestion(user: Principal) : Question? {
  let userAnsweredQuestions = getUserByPrincipal(user)?.answeredQuestions.map(\.0);
  
  let unansweredQuestions = List.filter(allQuestions, q => !List.contains(userAnsweredQuestions, q));
  
  return List.sort(unansweredQuestions, \(a, b) => a.avgImportance > b.avgImportance).first();
}

// Helper functions

private func getAllQuestionsByUser(user: Principal) : [Question] {
  return List.filter(allQuestions, q => q.author == user);
}

private func getCommonQuestions(questions1: [Question], questions2: [Question]) : [Question] {
  var commonQuestions : [Question] = [];
  
  for (q1 in questions1) {
    for (q2 in questions2) {
      if (q1.question == q2.question) {
        commonQuestions := commonQuestions ++ [q1];
        break;
      }
    }
  }
  
  return commonQuestions;
}

private func getAnswerByUser(answers: [Answer], user: Principal) : Answer? {
  for (ans in answers) {
    if (ans.user == user) {
      return ans;
    }
  }
