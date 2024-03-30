module {
  public type Error = {
    #alreadyRegistered;
    #nameNotAvailable;
    #validationError;
    #notRegistered : Principal;
    #notLoggedIn;

    #notInTeam;
    #teamNotFound;
    #invalidInvite;

    #userNotFound;
    #friendRequestAlreadySend;
    #friendAlreadyConnected;
    #notEnoughAnswers;

    #insufficientFunds;
    #tooShort;
    #tooLong;
    #invalidColor;
    #questionNotFound;

    #permissionDenied;
  };
};
