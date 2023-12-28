
help:
	cat makefile

test-data:
	# create a team
	dfx canister call backend createTeam '("sandbox", "test-invite-code", record {about="Temporary test data"; logo=vec {}; name="Test data"; listed=false})'
	dfx canister call backend joinTeam '("sandbox", "test-invite-code")'
	# create 20 questions and 30 users
	dfx canister call backend createTestData '("sandbox", 20, 30)'