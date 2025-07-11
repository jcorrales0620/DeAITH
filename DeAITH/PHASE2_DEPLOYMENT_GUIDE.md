# DeAITH Phase 2 Deployment Guide

## Overview
Phase 2 implementation is complete! This guide will help you deploy and test the new features:
- Researcher Dashboard for submitting AI training jobs
- Automatic timer-based reward distribution (30 seconds)
- Real-time balance updates in Patient Dashboard

## Prerequisites
- dfx SDK installed
- Node.js and npm installed
- Internet Computer local replica or mainnet access

## Deployment Steps

### 1. Start Local Replica (for local testing)
```bash
cd DeAITH
dfx start --clean
```

### 2. Deploy Backend Canisters
In a new terminal:
```bash
cd DeAITH
dfx deploy UserData
dfx deploy RewardToken
dfx deploy TrainingManager
```

### 3. Initialize Canister References
Make the initialization script executable and run it:
```bash
chmod +x scripts/init-canisters.sh
./scripts/init-canisters.sh
```

This script will:
- Set UserData and RewardToken canister IDs in TrainingManager
- Set TrainingManager as a minter in RewardToken

### 4. Build and Deploy Frontend
```bash
cd src/DeAITH_frontend
npm install
npm run build
cd ../..
dfx deploy DeAITH_frontend
```

### 5. Access the Application
```bash
# Get the frontend URL
echo "Frontend URL: http://$(dfx canister id DeAITH_frontend).localhost:4943"
```

## Testing Phase 2 Features

### Test Flow:

1. **Login as Patient**
   - Click "Login with Internet Identity"
   - Select "I'm a Patient"
   - Upload some health data (any test data)
   - Note your current token balance (should be 0)

2. **Login as Researcher** (use different browser/incognito)
   - Login with a different Internet Identity
   - Select "I'm a Researcher"
   - Submit a training job with any name
   - You'll see a message that the job is submitted

3. **Wait for Rewards**
   - Wait 30 seconds for the timer to trigger
   - The Patient Dashboard will automatically update every 5 seconds
   - After 30 seconds, you should see the balance increase by 10 DTH

4. **Verify Results**
   - Patient: Check updated token balance (should show 10.00 DEAITH)
   - Researcher: Check job status (should show "Completed")

## Troubleshooting

### If balance doesn't update:
1. Check browser console for errors
2. Ensure all canisters are deployed: `dfx canister status --all`
3. Verify initialization was successful: Check the output of init-canisters.sh

### If training job fails:
1. Check that canister IDs are properly set
2. Look at canister logs: `dfx canister logs TrainingManager`

### Common Issues:
- **"Unauthorized" error**: Run the initialization script again
- **"Canister not found"**: Ensure all canisters are deployed
- **Frontend not loading**: Clear browser cache and reload

## Architecture Overview

```
Patient Dashboard ──┐
                    ├──> UserData (stores encrypted health data)
                    └──> RewardToken (checks balance)
                    
Researcher Dashboard ──> TrainingManager (submits jobs)
                              │
                              ├──> Timer (30 seconds)
                              │
                              └──> Distributes Rewards
                                    ├──> UserData.getContributorList()
                                    └──> RewardToken.mint()
```

## Next Steps (Phase 3)
- Implement real vetKeys encryption
- Add actual AI model training simulation
- Implement data marketplace features
- Add more sophisticated reward algorithms

## Support
If you encounter any issues, check:
1. Canister logs: `dfx canister logs <canister_name>`
2. Browser console for frontend errors
3. Network tab for failed API calls
