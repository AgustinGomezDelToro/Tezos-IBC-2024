type beneficiary = {
  address : address;
  total_tokens : nat;
  claimed_tokens : nat;
}


type vesting_details = {
  start_time : timestamp;
  probatory_period : int; // en segundos
  vesting_duration : int; // en segundos
}

type fa2_token_info = {
  fa2_address : address;
  token_id : nat;
}

type storage = {
  admin : address;
  beneficiaries : map address beneficiary;
  vesting_info : vesting_details;
  token_info : fa2_token_info;
}

// Function to initialize the contract with the admin and token info
let initial_storage (admin : address; token_info : fa2_token_info) : storage = {
  admin = admin;
  beneficiaries = Map.empty;
  vesting_info = {start_time = Tezos.now; probatory_period = 0; vesting_duration = 0};
  token_info = token_info;
}

// Parameters to start the contract with the vesting details and beneficiaries
type start_params = {
  beneficiaries_details : map address nat;
  vesting_duration : int;
  probatory_period : int;
}

// Entry point to start the contract with the vesting details and beneficiaries
[@entry]
let start (params : start_params) (s : storage) : operation list * storage =
  if Tezos.sender = s.admin then
    let now = Tezos.now in
    let new_beneficiaries = Map.map (fun total_tokens -> {address = Tezos.sender; total_tokens = total_tokens; claimed_tokens = 0n}) params.beneficiaries_details in
    let new_vesting_info = {start_time = now; probatory_period = params.probatory_period; vesting_duration = params.vesting_duration} in
    [], { s with beneficiaries = new_beneficiaries; vesting_info = new_vesting_info }
  else
    failwith "Only admin can start the contract"



// Entrypoint pour reclamer tokens
[@entry]
let claim (requested_tokens : nat) (s : storage) : operation list * storage =
  let caller = Tezos.sender in
  match Map.find caller s.beneficiaries with
    | Some beneficiary ->
      let now = Tezos.now in
      let elapsed_time = now - s.vesting_info.start_time in
      let vesting_complete = elapsed_time >= s.vesting_info.vesting_duration in
      let total_vestable_tokens = if vesting_complete then beneficiary.total_tokens else ((elapsed_time * beneficiary.total_tokens) / s.vesting_info.vesting_duration) in
      let available_tokens = min (total_vestable_tokens - beneficiary.claimed_tokens) requested_tokens in
      let updated_beneficiary = { beneficiary with claimed_tokens = beneficiary.claimed_tokens + available_tokens } in
      let updated_storage = { s with beneficiaries = Map.add caller updated_beneficiary s.beneficiaries } in
      [], updated_storage
    | None -> failwith "You are not a beneficiary"

// Entrypoint pour récupérer les tokens non réclamés
[@entry]
let kill (unit : unit) (s : storage) : operation list * storage =
  if Tezos.sender = s.admin then
    [], s
  else failwith "Only admin can kill the contract"
