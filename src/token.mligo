#import "@ligo/fa2-lib/fa2_interface.mligo" "FA2"

type storage = FA2.fa2_storage

let initial_storage (admin : address) : storage = {
  ledger = Big_map.empty;
  total_supply = 0n; 
  metadata = Big_map.empty; 
  operators = Big_map.empty; 
  admin = admin; 
}

// Entrypoint pour la création de tokens (minting)
[@entry]
let mint (params : (address * nat)) (s : storage) : operation list * storage =
  let (recipient, amount) = params in
  let new_balance = match Big_map.find_opt recipient s.ledger with
    | Some(balance) -> balance + amount
    | None -> amount
  in
  let new_ledger = Big_map.update recipient (Some(new_balance)) s.ledger in
  ([], { s with ledger = new_ledger; total_supply = s.total_supply + amount })

// Entrypoint pour le burn 
[@entry]
let burn (params : (address * nat)) (s : storage) : operation list * storage =
  let (holder, amount) = params in
  let new_balance = match Big_map.find_opt holder s.ledger with
    | Some(balance) when balance >= amount -> balance - amount
    | _ -> (failwith "Insufficient balance" : nat)
  in
  let new_ledger = Big_map.update holder (Some(new_balance)) s.ledger in
  ([], { s with ledger = new_ledger; total_supply = s.total_supply - amount })

// Entrypoint pour l'approbation de dépenses
[@entry]
let transfer (params : FA2.transfer_params) (s : storage) : operation list * storage =
  FA2.transfer params s

// Entrypoint pour l'ajout d'opérateurs
[@entry]
let update_operators (params : FA2.update_operators_params) (s : storage) : operation list * storage =
  FA2.update_operators params s

