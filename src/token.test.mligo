#import "ligo-test-framework/ligo-test-framework.mligo" "TestFramework"
#import "../src/token.mligo" "Token"

// Configuración inicial para las pruebas
let admin = TestFramework.make_account("admin")
let user1 = TestFramework.make_account("user1")
let user2 = TestFramework.make_account("user2")
let operator = TestFramework.make_account("operator")

let initial_storage : Token.storage = Token.initial_storage(admin.account_address)

// Test pour l'acuñación de tokens (minting)
let test_mint_tokens = (
  TestFramework.set_sender(admin.account_address);
  let _, storage_after_mint = Token.mint((user1.account_address, 100n), initial_storage) in
  let balance_user1 = Big_map.find_opt(user1.account_address, storage_after_mint.ledger) in
  Assert.equal(balance_user1, Some(100n), "Le solde de user1 doit être de 100 après l'acuñación");
  Assert.equal(storage_after_mint.total_supply, 100n, "Le total_supply doit être de 100 après l'acuñación");
  ()
)

// Test pour la quema de tokens (burning)
let test_burn_tokens = (
  TestFramework.set_sender(user1.account_address);
  let initial_storage_with_tokens, _ = Token.mint((user1.account_address, 100n), initial_storage) in
  let _, storage_after_burn = Token.burn((user1.account_address, 50n), initial_storage_with_tokens) in
  let balance_user1 = Big_map.find_opt(user1.account_address, storage_after_burn.ledger) in
  Assert.equal(balance_user1, Some(50n), "Le solde de user1 doit être de 50 après la quema");
  Assert.equal(storage_after_burn.total_supply, 50n, "Le total_supply doit être de 50 après la quema");
  ()
)

let test_transfer_tokens = (
  TestFramework.set_sender(admin.account_address);
  let initial_storage_with_tokens, _ = Token.mint((user1.account_address, 100n), initial_storage) in
  TestFramework.set_sender(user1.account_address);
  let transfer_params : FA2.transfer_params = {
    from_ = user1.account_address;
    txs = [{
      to_ = user2.account_address;
      token_id = 0n;
      amount = 50n;
    }]
  } in
  let _, storage_after_transfer = Token.transfer(transfer_params, initial_storage_with_tokens) in
  let balance_user1 = Big_map.find_opt(user1.account_address, storage_after_transfer.ledger) in
  let balance_user2 = Big_map.find_opt(user2.account_address, storage_after_transfer.ledger) in
  Assert.equal(balance_user1, Some(50n), "Le solde de user1 doit être de 50 après le transfert");
  Assert.equal(balance_user2, Some(50n), "Le solde de user2 doit être de 50 après le transfert");
  ()
)


let test_update_operators = (
  TestFramework.set_sender(admin.account_address);
  let initial_storage_with_tokens, _ = Token.mint((user1.account_address, 100n), initial_storage) in
  // Agregar operador
  let add_operator_params : FA2.update_operators_params = [
    Add_operator({
      owner = user1.account_address;
      operator = operator.account_address;
      token_id = 0n;
    })
  ] in
  let _, storage_with_operator = Token.update_operators(add_operator_params, initial_storage_with_tokens) in
  Assert.is_true(Big_map.mem (user1.account_address, operator.account_address) storage_with_operator.operators, "Le operateur doit etre ajoute correctement");

  // Eliminar operador
  let remove_operator_params : FA2.update_operators_params = [
    Remove_operator({
      owner = user1.account_address;
      operator = operator.account_address;
      token_id = 0n;
    })
  ] in
  let _, storage_without_operator = Token.update_operators(remove_operator_params, storage_with_operator) in
  Assert.is_false(Big_map.mem (user1.account_address, operator.account_address) storage_without_operator.operators, "Le operateur doit etre supprime correctement");
  ()
)

// La fonction principale pour exécuter tous les tests
let main = (
  test_mint_tokens;
  test_burn_tokens;
  test_transfer_tokens;
  test_update_operators;
  // ... Incluir otras pruebas según sea necesario ...
  TestFramework.summary()
)
