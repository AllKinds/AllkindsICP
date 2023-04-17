import Hash "mo:base/Hash";

//TODO : integrate more variants (point usages, common errors, etc..)
//TODO : should overall be retyped for more cohesiveness, See type operational expressions

module T {

	public type User = {
		username : Text;
		created : Int;
		about : (?Text, Bool);
		gender : (?Gender, Bool);
		birth : (?Int, Bool);
		connect : (?Text, Bool); //= email or social media link
		points : Nat;
	};

	public type Gender = {
		#Male;
		#Female;
		#Queer;
		#Other;
	};

	//returnable object of a user that caller requested
	public type UserMatch = {
		principal : Principal;
		username : Text;
		about : ?Text;
		gender : ?Gender;
		birth : ?Int;
		connect : ?Text;
		cohesion : Int;
		answered : [(Question, Bool)]; //bool indicates comparison with caller answer
		uncommon : [Question]; //Questions that user has answered but not caller
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
		answer : Bool;
		weight : Int;
	};

	public type Skip = {
		user : Principal;
		question : Hash.Hash;
	};

	public type PrincipalQuestionHash = Hash.Hash;

	public type CommonQuestion = {
		question : Hash.Hash;
		sourceAnswer : Answer;
		testAnswer : Answer;
	};

	public type MatchingFilter = {
		ageRange : (Nat, Nat);
		gender : ?Gender;
		cohesion : Int;
	};

	public type UserWScore = (?Principal, Int);

	public type FriendStatus = {
		#Requested; //status of requested contact in msg.caller friendlist
		#Waiting; //status of msg.caller in the requested contact friendlist
		#Approved; //status of both users after
		//could be added upon and improved (REQ/WAIT might be too confusing, but this makes it ez to track who requested)
		//maybe change req/wait to send/requests (as its similar to ui)
	};

	//obj instead of tuple , bcs it should be expanded in future
	public type Friend = {
		account : Principal;
		status : ?FriendStatus;
	};

	public type FriendList = [Friend];

	//for viewable data of caller's friends
	public type FriendlyUserMatch = UserMatch and { status : FriendStatus };

};
