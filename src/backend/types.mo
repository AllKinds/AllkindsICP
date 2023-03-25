import Hash "mo:base/Hash";

// DATA TYPES

module T {
	// User type, tuple values contain a bool indicating field public visibility and optional value
	public type User = {
		username : Text;
		created : Int;
		about : (?Text, Bool);
		gender : (?Gender, Bool);
		birth : (?Int, Bool);
		connect : (?Text, Bool); //= email or social media link
		points : Nat; //Nat bcs user points should not go negative
		friendRequests : [Principal]; //could be of type Friends, but might give issues in future
	};

	public type UserMatch = {
		username : Text;
		about : ?Text;
		gender : ?Gender;
		birth : ?Int;
		connect : ?Text;
		//TODO: (cohesion : Nat;) changed into int for testing,  should always be between 0-100 so nat8 better
		cohesion : Int;
		answeredQuestions : [Question];
	};

	public type Gender = {
		#Male;
		#Female;
		#Queer;
		#Other;
	};

	// Color indicates optional background color for the question
	public type Question = {
		created : Int;
		creater : Principal;
		question : Text;
		hash : Hash.Hash;
		color : ?Color;
		points : Int; //int bcs question points should be able to go negative
	};

	// Only one color for now
	public type Color = {
		#Default;
	};

	public type Answer = {
		user : Principal;
		question : Hash.Hash;
		answer : AnswerKind;
	};

	public type Weight = {
		user : Principal;
		question : Hash.Hash;
		weight : WeightKind; //this would need to become an Int
	};

	public type Skip = {
		user : Principal;
		question : Hash.Hash;
	};

	// Only one answer type for now
	public type AnswerKind = {
		#Bool : Bool;
	};

	// Nat indicates a possible amount of tokens / points appointed by the user to to the question
	public type WeightKind = {
		//this would need to be removed
		#Like : Nat;
		#Dislike : Nat;
	};

	public type PrincipalQuestionHash = Hash.Hash;

	public type CommonQuestion = {
		question : Hash.Hash;
		sourceAnswer : Answer;
		testAnswer : Answer;
		sourceWeight : ?Weight;
		testWeight : ?Weight;
	};

	public type MatchingFilter = {
		ageRange : (Nat, Nat);
		gender : ?Gender;
		cohesion : Int;
	};

	public type UserWScore = (Principal, Int);

	public type Friends = [Principal];

	//for viewable data of caller's friends
	public type FriendlyUserMatch = UserMatch and {
		friends : Friends;
	};
}