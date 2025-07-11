#!/bin/bash

# Test script for Phase 2 functionality
# This script demonstrates the complete flow of Phase 2

echo "=== DeAITH Phase 2 Test Script ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get canister IDs
USER_DATA_ID=$(dfx canister id UserData)
REWARD_TOKEN_ID=$(dfx canister id RewardToken)
TRAINING_MANAGER_ID=$(dfx canister id TrainingManager)

echo -e "${YELLOW}Step 1: Creating test identities${NC}"
dfx identity new patient1 --storage-mode=plaintext 2>/dev/null || true
dfx identity new researcher1 --storage-mode=plaintext 2>/dev/null || true

echo -e "${GREEN}✓ Test identities created${NC}"
echo ""

echo -e "${YELLOW}Step 2: Patient uploads health data${NC}"
dfx identity use patient1
PATIENT_PRINCIPAL=$(dfx identity get-principal)
echo "Patient Principal: $PATIENT_PRINCIPAL"

# Initialize patient profile
dfx canister call UserData initProfile

# Upload some test health data
dfx canister call UserData uploadData '("Encrypted health data: Heart rate 75bpm, Blood pressure 120/80")'
echo -e "${GREEN}✓ Health data uploaded${NC}"
echo ""

echo -e "${YELLOW}Step 3: Check initial token balance${NC}"
INITIAL_BALANCE=$(dfx canister call RewardToken balanceOf "(principal \"$PATIENT_PRINCIPAL\")")
echo "Initial balance: $INITIAL_BALANCE"
echo ""

echo -e "${YELLOW}Step 4: Researcher submits training job${NC}"
dfx identity use researcher1
RESEARCHER_PRINCIPAL=$(dfx identity get-principal)
echo "Researcher Principal: $RESEARCHER_PRINCIPAL"

# Submit training job
dfx canister call TrainingManager submitTrainingJob '("Heart Disease Analysis Model")'
echo -e "${GREEN}✓ Training job submitted${NC}"
echo ""

echo -e "${YELLOW}Step 5: Waiting 30 seconds for timer to trigger...${NC}"
echo "Timer will distribute rewards to all contributors"
for i in {30..1}; do
    echo -ne "\rTime remaining: $i seconds "
    sleep 1
done
echo ""
echo ""

echo -e "${YELLOW}Step 6: Check updated token balance${NC}"
dfx identity use patient1
FINAL_BALANCE=$(dfx canister call RewardToken balanceOf "(principal \"$PATIENT_PRINCIPAL\")")
echo "Final balance: $FINAL_BALANCE"
echo ""

# Parse and compare balances
INITIAL=$(echo $INITIAL_BALANCE | grep -o '[0-9]*' | head -1)
FINAL=$(echo $FINAL_BALANCE | grep -o '[0-9]*' | head -1)

if [ "$FINAL" -gt "$INITIAL" ]; then
    echo -e "${GREEN}✓ SUCCESS! Patient received reward tokens!${NC}"
    echo "Tokens earned: $((FINAL - INITIAL))"
else
    echo -e "${YELLOW}⚠ Balance unchanged. Check canister logs for errors.${NC}"
fi

echo ""
echo -e "${YELLOW}Step 7: Check job status${NC}"
dfx identity use researcher1
dfx canister call TrainingManager getResearcherJobs "(principal \"$RESEARCHER_PRINCIPAL\")"

# Cleanup
echo ""
echo -e "${YELLOW}Cleaning up test identities...${NC}"
dfx identity use default
dfx identity remove patient1 2>/dev/null || true
dfx identity remove researcher1 2>/dev/null || true

echo ""
echo -e "${GREEN}=== Phase 2 Test Complete ===${NC}"
