#import "ligo-test-framework/ligo-test-framework.mligo" "TestFramework"
#import "../src/vesting_contract.mligo" "VestingContract"

// Définit les comptes pour les tests
let admin = TestFramework.make_account("admin")
let beneficiary = TestFramework.make_account("beneficiary")
let non_beneficiary = TestFramework.make_account("non_beneficiary")

// Information sur le token FA2 utilisé pour les tests
let token_info : VestingContract.fa2_token_info = {
  fa2_address = admin.account_address; // L'adresse du contrat FA2
  token_id = 0n; // L'ID du token FA2
}

// Crée le stockage initial pour le contrat de vesting
let initial_storage : VestingContract.storage = VestingContract.initial_storage(
  admin.account_address,
  token_info
)

// Test pour démarrer le contrat de vesting
let test_start_vesting_contract = (
  let start_params : VestingContract.start_params = {
    beneficiaries_details = Map.literal [(beneficiary.account_address, 100n)];
    vesting_duration = 86400 * 30; // 30 jours exprimés en secondes
    probatory_period = 86400 * 15; // 15 jours exprimés en secondes
  } in
  TestFramework.set_now(TestFramework.timestamp_of_string("2024-01-01T00:00:00Z"));
  TestFramework.set_sender(admin.account_address);
  let _, storage = VestingContract.start(start_params, initial_storage) in
  Assert.equal(storage.vesting_info.start_time, TestFramework.timestamp_of_string("2024-01-01T00:00:00Z"), "Le contrat doit commencer à la date correcte");
  Assert.equal(storage.vesting_info.probatory_period, 86400 * 15, "La période probatoire doit être configurée correctement");
  Assert.equal(storage.vesting_info.vesting_duration, 86400 * 30, "La durée de vesting doit être configurée correctement");
  Assert.equal(Map.size(storage.beneficiaries), 1n, "Il doit y avoir un bénéficiaire enregistré");
  ()
)

// Test pour que les bénéficiaires puissent réclamer leurs tokens avec succès
let test_claim_tokens_success = (
  // Supposons que le contrat a été correctement initié.
  TestFramework.set_now(TestFramework.timestamp_of_string("2024-02-20T00:00:00Z"));
  TestFramework.set_sender(beneficiary.account_address);
  let _, storage = VestingContract.claim(50n, initial_storage) in
  let beneficiary_info = Map.find_opt(beneficiary.account_address, storage.beneficiaries) in
  match beneficiary_info with
  | Some(info) -> Assert.equal(info.claimed_tokens, 50n, "Le bénéficiaire doit pouvoir réclamer 50 tokens");
  | None -> Assert.fail("Le bénéficiaire doit être enregistré dans le stockage")
)

// Test pour échouer la réclamation des tokens pendant la période probatoire
let test_claim_tokens_failure = (
  // Supposons que le contrat a été correctement initié et nous sommes dans la période probatoire.
  TestFramework.set_now(TestFramework.timestamp_of_string("2024-01-05T00:00:00Z"));
  TestFramework.set_sender(beneficiary.account_address);
  let result = TestFramework.run_entrypoint(VestingContract.claim, 50n, initial_storage) in
  Assert.not_successful(result, "Le bénéficiaire ne doit pas pouvoir réclamer de tokens pendant la période probatoire")
)

// exectution des tests
let main = (
  test_start_vesting_contract;
  test_claim_tokens_success;
  test_claim_tokens_failure;
  TestFramework.summary()
)
