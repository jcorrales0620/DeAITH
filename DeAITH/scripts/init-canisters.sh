#!/bin/bash

# Script to initialize canister references after deployment
# This script should be run after deploying all canisters

echo "Initializing DeAITH canisters..."

# Get canister IDs
USER_DATA_ID=$(dfx canister id UserData)
REWARD_TOKEN_ID=$(dfx canister id RewardToken)
TRAINING_MANAGER_ID=$(dfx canister id TrainingManager)

echo "UserData canister ID: $USER_DATA_ID"
echo "RewardToken canister ID: $REWARD_TOKEN_ID"
echo "TrainingManager canister ID: $TRAINING_MANAGER_ID"

# Initialize TrainingManager with references to other canisters
echo "Setting canister IDs in TrainingManager..."
dfx canister call TrainingManager setCanisterIds "(principal \"$USER_DATA_ID\", principal \"$REWARD_TOKEN_ID\")"

# Set TrainingManager as minter in RewardToken
echo "Setting TrainingManager as minter in RewardToken..."
dfx canister call RewardToken setMinter "(principal \"$TRAINING_MANAGER_ID\")"

echo "Initialization complete!"
echo ""
echo "You can now test the system by:"
echo "1. Login as a patient and upload some health data"
echo "2. Login as a researcher and submit a training job"
echo "3. Wait 30 seconds for the timer to trigger reward distribution"
echo "4. Check the patient dashboard to see the updated token balance"
