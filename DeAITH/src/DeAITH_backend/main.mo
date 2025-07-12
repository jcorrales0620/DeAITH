import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";

actor UserData {
    // User health data structure
    public type HealthData = {
        id: Text;
        owner: Principal;
        encryptedData: Text; // Data encrypted on client-side
        timestamp: Int;
        dataType: Text; // e.g., "smartwatch", "lab_results", etc.
        isShared: Bool; // Whether data is available for training
    };
    
    // User profile
    public type UserProfile = {
        principal: Principal;
        dataCount: Nat;
        totalRewards: Nat;
        joinedAt: Int;
    };
    
    // Storage
    private stable var dataCounter : Nat = 0;
    private var userData = HashMap.HashMap<Text, HealthData>(10, Text.equal, Text.hash);
    private var userProfiles = HashMap.HashMap<Principal, UserProfile>(10, Principal.equal, Principal.hash);
    private var userDataIds = HashMap.HashMap<Principal, [Text]>(10, Principal.equal, Principal.hash);
    
    // Initialize user profile
    public shared(msg) func initProfile() : async Result.Result<UserProfile, Text> {
        let caller = msg.caller;
        
        switch (userProfiles.get(caller)) {
            case (?_profile) { #err("Profile already exists") };
            case null {
                let newProfile : UserProfile = {
                    principal = caller;
                    dataCount = 0;
                    totalRewards = 0;
                    joinedAt = Time.now();
                };
                userProfiles.put(caller, newProfile);
                #ok(newProfile)
            };
        }
    };
    
    // Store encrypted health data
    public shared(msg) func storeHealthData(encryptedData: Text, dataType: Text) : async Result.Result<Text, Text> {
        let owner = msg.caller;
        
        // Ensure user has a profile
        switch (userProfiles.get(owner)) {
            case null { return #err("Please initialize your profile first") };
            case (?profile) {
                dataCounter += 1;
                let dataId = "DATA-" # Nat.toText(dataCounter);
                
                let newData : HealthData = {
                    id = dataId;
                    owner = owner;
                    encryptedData = encryptedData;
                    timestamp = Time.now();
                    dataType = dataType;
                    isShared = true; // Default to sharing for rewards
                };
                
                userData.put(dataId, newData);
                
                // Update user's data list
                switch (userDataIds.get(owner)) {
                    case (?existingIds) {
                        userDataIds.put(owner, Array.append(existingIds, [dataId]));
                    };
                    case null {
                        userDataIds.put(owner, [dataId]);
                    };
                };
                
                // Update profile data count
                let updatedProfile : UserProfile = {
                    principal = profile.principal;
                    dataCount = profile.dataCount + 1;
                    totalRewards = profile.totalRewards;
                    joinedAt = profile.joinedAt;
                };
                userProfiles.put(owner, updatedProfile);
                
                #ok("Data stored with ID: " # dataId)
            };
        }
    };
    
    // Get user's own data
    public query func getUserData(user: Principal) : async [HealthData] {
        switch (userDataIds.get(user)) {
            case (?dataIds) {
                Array.mapFilter<Text, HealthData>(dataIds, func(dataId) {
                    userData.get(dataId)
                })
            };
            case null { [] };
        }
    };
    
    // Get user profile
    public query func getProfile(user: Principal) : async ?UserProfile {
        userProfiles.get(user)
    };
    
    // Toggle data sharing for a specific data entry
    public shared(msg) func toggleDataSharing(dataId: Text) : async Result.Result<Bool, Text> {
        let caller = msg.caller;
        
        switch (userData.get(dataId)) {
            case (?data) {
                if (data.owner == caller) {
                    let updatedData : HealthData = {
                        id = data.id;
                        owner = data.owner;
                        encryptedData = data.encryptedData;
                        timestamp = data.timestamp;
                        dataType = data.dataType;
                        isShared = not data.isShared;
                    };
                    userData.put(dataId, updatedData);
                    #ok(updatedData.isShared)
                } else {
                    #err("You don't own this data")
                }
            };
            case null { #err("Data not found") };
        }
    };
    
    // Get available data for training (only shared data)
    public query func getAvailableDataForTraining() : async [(Principal, Text)] {
        // Returns list of (owner, dataId) pairs for shared data
        Array.mapFilter<(Text, HealthData), (Principal, Text)>(
            Iter.toArray(userData.entries()),
            func((dataId, data)) {
                if (data.isShared) {
                    ?(data.owner, dataId)
                } else {
                    null
                }
            }
        )
    };
    
    // Update user rewards (called by TrainingManager after training)
    public shared(_msg) func updateUserRewards(user: Principal, rewardAmount: Nat) : async Result.Result<Text, Text> {
        switch (userProfiles.get(user)) {
            case (?profile) {
                let updatedProfile : UserProfile = {
                    principal = profile.principal;
                    dataCount = profile.dataCount;
                    totalRewards = profile.totalRewards + rewardAmount;
                    joinedAt = profile.joinedAt;
                };
                userProfiles.put(user, updatedProfile);
                #ok("Rewards updated")
            };
            case null { #err("User profile not found") };
        }
    };
    
    // Get statistics
    public query func getStats() : async {totalUsers: Nat; totalData: Nat} {
        {
            totalUsers = userProfiles.size();
            totalData = userData.size();
        }
    };

    // Additional functions as per Langkah 2 document
    
    // Simple upload function as described in the document
    public shared(msg) func uploadData(encryptedText: Text) : async () {
        let patientPrincipal = msg.caller;
        
        // Store the encrypted data
        dataCounter += 1;
        let dataId = "DATA-" # Nat.toText(dataCounter);
        
        let newData : HealthData = {
            id = dataId;
            owner = patientPrincipal;
            encryptedData = encryptedText;
            timestamp = Time.now();
            dataType = "general"; // Default type for simple upload
            isShared = true;
        };
        
        userData.put(dataId, newData);
        
        // Update user's data list
        switch (userDataIds.get(patientPrincipal)) {
            case (?existingIds) {
                userDataIds.put(patientPrincipal, Array.append(existingIds, [dataId]));
            };
            case null {
                userDataIds.put(patientPrincipal, [dataId]);
            };
        };
        
        // Update profile if exists
        switch (userProfiles.get(patientPrincipal)) {
            case (?profile) {
                let updatedProfile : UserProfile = {
                    principal = profile.principal;
                    dataCount = profile.dataCount + 1;
                    totalRewards = profile.totalRewards;
                    joinedAt = profile.joinedAt;
                };
                userProfiles.put(patientPrincipal, updatedProfile);
            };
            case null {
                // Create profile if doesn't exist
                let newProfile : UserProfile = {
                    principal = patientPrincipal;
                    dataCount = 1;
                    totalRewards = 0;
                    joinedAt = Time.now();
                };
                userProfiles.put(patientPrincipal, newProfile);
            };
        };
    };
    
    // Get my data function as described in the document
    public query(msg) func getMyData() : async ?Text {
        let patientPrincipal = msg.caller;
        
        // Get the most recent data for the caller
        switch (userDataIds.get(patientPrincipal)) {
            case (?dataIds) {
                if (dataIds.size() > 0) {
                    let lastDataId = dataIds[dataIds.size() - 1];
                    switch (userData.get(lastDataId)) {
                        case (?data) { ?data.encryptedData };
                        case null { null };
                    }
                } else {
                    null
                }
            };
            case null { null };
        }
    };

    // --- FUNGSI FASAD VETKEYS ---
    
    // Ini adalah fungsi placeholder untuk mendemonstrasikan arsitektur vetKeys.
    // Dalam implementasi nyata, ini akan menjadi 'update call' yang aman
    // dan memanggil API sistem vetKD.
    public query func getKeyForResearcher(researcherId: Principal) : async Text {
        
        // Pesan debug untuk kita di terminal
        Debug.print("Simulasi permintaan kunci dari researcher: " # Principal.toText(researcherId));
        
        // Di dunia nyata, di sinilah kita akan:
        // 1. Memeriksa apakah 'caller' (pasien) sudah memberikan izin untuk 'researcherId'.
        // 2. Membuat 'transport_public_key' dan memanggil API sistem vetKD.
        // 3. Mengembalikan hasilnya, yaitu kunci yang sudah terenkripsi.
        
    // Untuk hackathon, kita kembalikan sebuah string dummy yang meyakinkan.
    return "SIMULATED_ENCRYPTED_KEY_FOR_" # Principal.toText(researcherId);
  };
  
  // --- NEW PHASE 2 FUNCTIONS ---
  
  // Get list of contributors (for reward distribution)
  public query func getContributorList() : async [Principal] {
    // Return all unique principals who have contributed data
    let principals = Buffer.Buffer<Principal>(userProfiles.size());
    
    for ((principal, profile) in userProfiles.entries()) {
      if (profile.dataCount > 0) {
        principals.add(principal);
      };
    };
    
    Buffer.toArray(principals)
  };
}
