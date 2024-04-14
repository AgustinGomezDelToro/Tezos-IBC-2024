# Variables
LIGO = ligo
SRC_DIR = src
OUT_DIR = compiled
MAIN_CONTRACT = vesting_contract.mligo
MAIN_CONTRACT_OUT = vesting_contract.tz
TEST_FILE = vesting_contract.test.mligo

.PHONY: compile test

compile:
	mkdir -p $(OUT_DIR)
	$(LIGO) compile contract $(SRC_DIR)/$(MAIN_CONTRACT) -o $(OUT_DIR)/$(MAIN_CONTRACT_OUT)

test:
	$(LIGO) run test $(SRC_DIR)/$(TEST_FILE)
