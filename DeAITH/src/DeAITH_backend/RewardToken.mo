import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Result "mo:base/Result";

actor RewardToken {

  // Tipe data untuk error, agar lebih jelas
  type Error = {
    #InsufficientBalance;
    #Unauthorized;
  };

  // --- STATE CANISTER ---
  // Variabel-variabel ini menyimpan kondisi token kita

  // Pemilik canister, yang punya hak spesial (misal: untuk minting awal)
  private stable var owner : Principal = Principal.fromText("aaaaa-aa");
  
  // Minter yang juga bisa mint token (untuk TrainingManager)
  private stable var minter : Principal = Principal.fromText("aaaaa-aa");

  // Menyimpan saldo setiap pengguna
  // Key: Principal ID, Value: Jumlah Token
  private var balances = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);

  // Total pasokan token yang beredar
  private stable var totalTokenSupply : Nat = 0;

  // Metadata Token
  private stable let tokenName : Text = "DeAITH Token";
  private stable let tokenSymbol : Text = "DTH";
  private stable let tokenDecimals : Nat = 8;

  // --- INITIALIZATION ---
  // Fungsi ini berjalan sekali saat canister pertama kali dibuat
  public shared(msg) func init() : async Result.Result<Text, Text> {
    owner := msg.caller;
    #ok("Token initialized with owner: " # Principal.toText(owner))
  };

  // --- FUNGSI QUERY ---

  // Mengembalikan nama token
  public query func name() : async Text {
    return tokenName;
  };

  // Mengembalikan simbol token
  public query func symbol() : async Text {
    return tokenSymbol;
  };

  // Mengembalikan total pasokan token
  public query func totalSupply() : async Nat {
    return totalTokenSupply;
  };

  // Mengembalikan saldo dari principal tertentu
  public query func balanceOf(who: Principal) : async Nat {
    // Jika principal tidak ada di map, kembalikan 0. Jika ada, kembalikan saldonya.
    switch (balances.get(who)) {
      case (null) { 0 };
      case (?balance) { balance };
    }
  };

  // --- FUNGSI UPDATE ---

  // Mengirim token dari pemanggil ke penerima
  public shared(msg) func transfer(to: Principal, amount: Nat) : async Result.Result<Nat, Error> {
    let from = msg.caller; // 'caller' adalah Principal ID yang memanggil fungsi ini
    let from_balance = await balanceOf(from);

    // Pastikan pengirim punya saldo yang cukup
    if (from_balance < amount) {
      return #err(#InsufficientBalance);
    };

    // Kurangi saldo pengirim
    balances.put(from, from_balance - amount);

    // Tambah saldo penerima
    let to_balance = await balanceOf(to);
    balances.put(to, to_balance + amount);

    return #ok(amount);
  };

  // Mencetak token baru. Ini adalah fungsi yang sangat sensitif.
  public shared(msg) func mint(to: Principal, amount: Nat) : async Result.Result<Nat, Error> {
    // Owner ATAU minter yang bisa menjalankan fungsi ini.
    if (msg.caller != owner and msg.caller != minter) {
      return #err(#Unauthorized);
    };

    // Tambah saldo penerima
    let to_balance = await balanceOf(to);
    balances.put(to, to_balance + amount);

    // Tambah total pasokan
    totalTokenSupply += amount;

    return #ok(amount);
  };

  // Get token info (additional function for compatibility)
  public query func getTokenInfo() : async {name: Text; symbol: Text; decimals: Nat; totalSupply: Nat} {
    {
      name = tokenName;
      symbol = tokenSymbol;
      decimals = tokenDecimals;
      totalSupply = totalTokenSupply;
    }
  };

  // Get owner (for debugging)
  public query func getOwner() : async Principal {
    owner
  };
  
  // --- NEW PHASE 2 FUNCTIONS ---
  
  // Function to set minter (only owner can call)
  public shared(msg) func setMinter(new_minter: Principal) : async Result.Result<Text, Text> {
    if (msg.caller != owner) { 
      return #err("Unauthorized: Only owner can set minter");
    };
    minter := new_minter;
    #ok("Minter set to: " # Principal.toText(new_minter))
  };
}
