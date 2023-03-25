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
import Float "mo:base/Float";
import Order "mo:base/Order";
import None "mo:base/None";

// TEMPORARY MOTOKO FILE FOR WHTVR

actor {
	//Code ready for moc 0.8.3
	//TODO , put optimized parts or ideas

	func commonQuestionsX(sourceUser : Principal, testUser : Principal) : [CommonQuestion] {
		let buf = Buffer.Buffer<CommonQuestion>(16);
		label l for (hash in questions.keys()) {
			let sourcePQ = hashPrincipalQuestion(sourceUser, hash);
			let testPQ = hashPrincipalQuestion(testUser, hash);
			//check
			let ?sourceAnswer = answers.get(sourcePQ) else continue l;
			let ?testAnswer = answers.get(testPQ) else continue l;
			let sourceWeight = weights.get(sourcePQ);
			let testWeight = weights.get(testPQ);
			//build
			let commonQuestion : CommonQuestion = {
				question = hash;
				sourceAnswer;
				testAnswer;
				sourceWeight;
				testWeight;
			};
			buf.add(commonQuestion);
		};
		buf.toArray();
	};

	func changeUserPoints(p : Principal, value : Nat) : () {
		let ?user = users.get(p) else return;
		user.points := value; //needs to be var for this in user type
		return users.put(p, user);
	};

};
