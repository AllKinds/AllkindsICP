import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import List "mo:base/List";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Nat "mo:base/Nat";
import Int8 "mo:base/Int8";
import Int32 "mo:base/Int32";
import Debug "mo:base/Debug";
import Array "mo:base/Array";

actor {
	type User = {
		name : Text;
		balance : Nat;
		age : Nat;
		gender : Text;
		picture : Blob;
		location : Text;
		answeredQuestions : [Answer];
	};

	type Question = {
		author : Principal;
		text : Text;
		importance : Int;
		//answers: [Answer]; -> this seems unnecessary
	};

	type Answer = {
		author : Principal;
		question : Question;
		answer : Text;
		weight : Int;
	};

	public func cohesionScore(user1 : User, user2 : User) : Float {
		let answeredQuestions1 = user1.answeredQuestions;
		let answeredQuestions2 = user2.answeredQuestions;

		var sameAnswers : [Answer] = [];
		for (var i = 0, i < answeredQuestions1.length, i ++) {
			let question1 = answeredQuestions1[i].question;
			let answer1 = answeredQuestions1[i].answer;
			let weight1 = answeredQuestions1[i].weight;

			for (var j = 0, j < answeredQuestions2.length, j ++) {
				let question2 = answeredQuestions2[j].question;
				let answer2 = answeredQuestions2[j].answer;
				let weight2 = answeredQuestions2[j].weight;

				if (question1 == question2 & & answer1 == answer2) {
					sameAnswers := Array.append(sameAnswers, answeredQuestions1[i]);
					break;
				};
			};
		}

		var score : Float = 0.0;
		for (var i = 0, i < sameAnswers.length, i ++) {
			let weight1 = sameAnswers[i].weight;
			let weight2 = sameAnswers[i].question.author == user1 ?user2.answeredQuestions[i].weight : user1.answeredQuestions[i].weight;

			score += (weight1 + weight2) / (2 * sameAnswers.length);
		}

		return score;
	}

	public func sortedUsersByCohesion(user : User, users : [User]) : [User] {
		return Array.sort(
			users,
			(u1, u2) = > {
				let score1 = cohesionScore(user, u1);
				let score2 = cohesionScore(user, u2);

				if (score1 > score2) {
					return -1;
				} else if (score1 < score2) {
					return 1;
				} else {
					return 0;
				};
			}
		);
	};
};
