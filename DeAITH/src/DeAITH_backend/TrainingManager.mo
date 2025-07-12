import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Error "mo:base/Error";

actor TrainingManager {
    // Define error type for RewardToken
    type TokenError = {
        #InsufficientBalance;
        #Unauthorized;
    };
    
    // Define interfaces for other canisters
    type UserData = actor {
      getContributorList: query () -> async [Principal];
    };

    type RewardToken = actor {
      mint: (Principal, Nat) -> async Result.Result<Nat, TokenError>;
    };

    // --- STATE ---
    private stable var owner : Principal = Principal.fromText("aaaaa-aa");
    private var userDataCanister : UserData = actor("aaaaa-aa");
    private var rewardTokenCanister : RewardToken = actor("aaaaa-aa");
    
    // Training job structure
    public type TrainingJob = {
        id: Text;
        name: Text;
        description: Text;
        researcher: Principal;
        status: JobStatus;
        createdAt: Int;
        completedAt: ?Int;
        dataContributors: [Principal];
    };
    
    public type JobStatus = {
        #Pending;
        #Running;
        #Completed;
        #Failed;
    };
    
    // Storage for training jobs
    private stable var jobCounter : Nat = 0;
    private var jobs = HashMap.HashMap<Text, TrainingJob>(10, Text.equal, Text.hash);
    private var researcherJobs = HashMap.HashMap<Principal, [Text]>(10, Principal.equal, Principal.hash);
    
    // --- INITIALIZATION ---
    public func init(init_owner: Principal) : async () {
        owner := init_owner;
    };
    
    // --- CONFIGURATION ---
    public shared(msg) func setCanisterIds(userDataId: Principal, rewardTokenId: Principal) : async () {
        if (msg.caller != owner) { return }; // Security check
        userDataCanister := actor(Principal.toText(userDataId)) : UserData;
        rewardTokenCanister := actor(Principal.toText(rewardTokenId)) : RewardToken;
    };
    
    // Submit a new training job
    public shared(msg) func submitJob(name: Text, description: Text) : async Result.Result<Text, Text> {
        let researcher = msg.caller;
        jobCounter += 1;
        let jobId = "JOB-" # Nat.toText(jobCounter);
        
        let newJob : TrainingJob = {
            id = jobId;
            name = name;
            description = description;
            researcher = researcher;
            status = #Pending;
            createdAt = Time.now();
            completedAt = null;
            dataContributors = [];
        };
        
        jobs.put(jobId, newJob);
        
        // Update researcher's job list
        switch (researcherJobs.get(researcher)) {
            case (?existingJobs) {
                researcherJobs.put(researcher, Array.append(existingJobs, [jobId]));
            };
            case null {
                researcherJobs.put(researcher, [jobId]);
            };
        };
        
        #ok("Job submitted with ID: " # jobId)
    };
    
    // Get all jobs for a researcher
    public query func getResearcherJobs(researcher: Principal) : async [TrainingJob] {
        switch (researcherJobs.get(researcher)) {
            case (?jobIds) {
                Array.mapFilter<Text, TrainingJob>(jobIds, func(jobId) {
                    jobs.get(jobId)
                })
            };
            case null { [] };
        }
    };
    
    // Update job status (in production, this would be called by the training process)
    public shared(_msg) func updateJobStatus(jobId: Text, status: JobStatus) : async Result.Result<Text, Text> {
        switch (jobs.get(jobId)) {
            case (?job) {
                let updatedJob : TrainingJob = {
                    id = job.id;
                    name = job.name;
                    description = job.description;
                    researcher = job.researcher;
                    status = status;
                    createdAt = job.createdAt;
                    completedAt = switch (status) {
                        case (#Completed) { ?Time.now() };
                        case (_) { job.completedAt };
                    };
                    dataContributors = job.dataContributors;
                };
                jobs.put(jobId, updatedJob);
                #ok("Job status updated")
            };
            case null { #err("Job not found") };
        }
    };
    
    // Simulate running a training job (for demo purposes)
    public shared(_msg) func simulateTraining(jobId: Text, contributors: [Principal]) : async Result.Result<Text, Text> {
        switch (jobs.get(jobId)) {
            case (?job) {
                // Update status to Running
                let runningJob : TrainingJob = {
                    id = job.id;
                    name = job.name;
                    description = job.description;
                    researcher = job.researcher;
                    status = #Running;
                    createdAt = job.createdAt;
                    completedAt = null;
                    dataContributors = contributors;
                };
                jobs.put(jobId, runningJob);
                
                // In a real implementation, this would trigger the actual AI training
                // For now, we'll just mark it as completed
                let completedJob : TrainingJob = {
                    id = job.id;
                    name = job.name;
                    description = job.description;
                    researcher = job.researcher;
                    status = #Completed;
                    createdAt = job.createdAt;
                    completedAt = ?Time.now();
                    dataContributors = contributors;
                };
                jobs.put(jobId, completedJob);
                
                #ok("Training simulation completed")
            };
            case null { #err("Job not found") };
        }
    };
    
    // Get job details
    public query func getJob(jobId: Text) : async ?TrainingJob {
        jobs.get(jobId)
    };
    
    // Get all jobs (for admin purposes)
    public query func getAllJobs() : async [TrainingJob] {
        Array.mapFilter<(Text, TrainingJob), TrainingJob>(
            Iter.toArray(jobs.entries()),
            func((_, job)) { ?job }
        )
    };
    
    // --- NEW PHASE 2 FUNCTIONS ---
    
    // Submit training job with timer (Phase 2 implementation)
    public shared(msg) func submitTrainingJob(jobName: Text) : async () {
        // In real app, there would be validation and payment logic here
        Debug.print("Job '" # jobName # "' received. Starting 30 second timer...");
        
        // Store the job first
        let researcher = msg.caller;
        jobCounter += 1;
        let jobId = "JOB-" # Nat.toText(jobCounter);
        
        let newJob : TrainingJob = {
            id = jobId;
            name = jobName;
            description = "Auto-submitted job with timer";
            researcher = researcher;
            status = #Running;
            createdAt = Time.now();
            completedAt = null;
            dataContributors = [];
        };
        
        jobs.put(jobId, newJob);
        
        // Update researcher's job list
        switch (researcherJobs.get(researcher)) {
            case (?existingJobs) {
                researcherJobs.put(researcher, Array.append(existingJobs, [jobId]));
            };
            case null {
                researcherJobs.put(researcher, [jobId]);
            };
        };
        
        // Set timer to run onTimer after 30 seconds
        let _timerId = Timer.setTimer<system>(#seconds 30, func() : async () {
            await onTimer(jobId);
        });
    };
    
    // Private function called when timer expires
    private func onTimer(jobId: Text) : async () {
        Debug.print("Timer finished for job " # jobId # ". Starting reward distribution...");
        await distributeRewards(jobId);
    };
    
    // Private function to distribute rewards with enhanced error handling
    private func distributeRewards(jobId: Text) : async () {
        try {
            // 1. Get list of contributors from UserData canister
            let contributors : [Principal] = await userDataCanister.getContributorList();
            Debug.print("Found " # Nat.toText(contributors.size()) # " contributors.");
            
            // 2. Loop and mint tokens for each contributor
            let rewardAmount : Nat = 10_00000000; // 10 DTH with 8 decimals
            var failedMints : [Principal] = [];
            
            for (contributor in contributors.vals()) {
                try {
                    Debug.print("Minting " # Nat.toText(rewardAmount) # " DTH for " # Principal.toText(contributor));
                    let mintResult = await rewardTokenCanister.mint(contributor, rewardAmount);
                    switch (mintResult) {
                        case (#ok(_)) {
                            Debug.print("Successfully minted for " # Principal.toText(contributor));
                        };
                        case (#err(e)) {
                            Debug.print("Failed to mint for " # Principal.toText(contributor) # ": " # debug_show(e));
                            failedMints := Array.append(failedMints, [contributor]);
                        };
                    };
                } catch (e) {
                    Debug.print("Failed to mint for " # Principal.toText(contributor) # ": " # Error.message(e));
                    failedMints := Array.append(failedMints, [contributor]);
                };
            };
            
            // 3. Update job status to completed (even if some mints failed)
            switch (jobs.get(jobId)) {
                case (?job) {
                    let completedJob : TrainingJob = {
                        id = job.id;
                        name = job.name;
                        description = job.description;
                        researcher = job.researcher;
                        status = #Completed;
                        createdAt = job.createdAt;
                        completedAt = ?Time.now();
                        dataContributors = contributors;
                    };
                    jobs.put(jobId, completedJob);
                    
                    // Log failed mints if any
                    if (failedMints.size() > 0) {
                        Debug.print("Job " # jobId # " completed with " # Nat.toText(failedMints.size()) # " failed reward distributions");
                    };
                };
                case null {};
            };
            
            Debug.print("Reward distribution completed for job " # jobId);
        } catch (e) {
            Debug.print("Error during reward distribution: " # Error.message(e));
            
            // Update job status to failed
            switch (jobs.get(jobId)) {
                case (?job) {
                    let failedJob : TrainingJob = {
                        id = job.id;
                        name = job.name;
                        description = job.description;
                        researcher = job.researcher;
                        status = #Failed;
                        createdAt = job.createdAt;
                        completedAt = ?Time.now();
                        dataContributors = [];
                    };
                    jobs.put(jobId, failedJob);
                };
                case null {};
            };
        };
    };
}
