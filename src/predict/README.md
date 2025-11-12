# PredictTheFutureChallenge — Audit Report

This document summarizes the findings from an audit of the `PredictTheFutureChallenge` contract (Solidity ^0.8.x).

--- 

## Quick summary

The contract is a simple “guess the number” game where a player locks in a 1 ETH guess and may win 2 ETH if the randomly computed answer matches the guess. The audit reveals **critical vulnerabilities** related to randomness generation and privacy of the `answer` value.

---

## Contract summary

Key elements of the contract analyzed:

* A single-player guess game that requires `1 ether` to enter.
* `lockInGuess(uint8 n)` stores the player address, their guess, and sets `settlementBlockNumber = block.number + 1`.
* `settle()` computes an `answer` as `keccak256(blockhash(block.number - 1), block.timestamp) % 10` and pays out `2 ether` if the guess matches.
* `isComplete()` returns `address(this).balance == 0`.
* No owner/withdraw functions or secure randomness oracle are present.

(For the full source used in this audit, see the project files.)

---

## High severity

* **Predictable**

  * `answer` is derived from on-chain values with limited entropy (block hash + timestamp). Low entropy makes brute-force and prediction feasible. The attacker can wait specific block hash that is equal with the guess to call `settle()`, draining the contract.

* **No administrative withdrawal mechanism**

   * There is no `owner` or `withdraw` function to recover funds in an emergency, migrate funds, or respond to exploitation. Funds may become permanently locked.

## Medium severity

* **Outdated Solidity version risk**

   * Using an old compiler version may expose known compiler bugs or omit language safety features (for example, builtin overflow checks introduced in 0.8.x). Always pin and update the `pragma` to a modern Solidity version and re-run tests.

* **Using `address(this).balance` as logical game state**

   * Relying on the contract balance to determine `isComplete()` or game state is brittle: external sends (including `selfdestruct` from other contracts) can change the balance unexpectedly. Maintain an internal accounting variable to track the game pool.

## Low severity

* **Function visibility**

   * `public` is used where `external` could be cheaper for certain functions (e.g., `lockInGuess`) and avoid unnecessary internal ABI copying.

* **Using `.transfer()` for payouts**

   * `transfer()` forwards a limited gas stipend and can fail in some edge cases. Using `call{value: amount}('')` with appropriate reentrancy protections is recommended.

---

## Proof-of-Concept (high-level)

**Randomness exploitation**

* A simple exploit is to monitor block hashes and compute the same answer locally. If the computed `answer` equals the currently stored `guess`, the attacker (or miner) calls `settle()` and wins 2 ETH.

---

## Recommendations / Remediations

* **Use a secure randomness source**

   * Strong recommendation: use a verifiable randomness oracle (e.g., Chainlink VRF v2) for any on-chain random numbers in production.
   * Alternatively, design a commit–reveal scheme for two-step randomness where appropriate.

* **Add administrative controls**

   * Add `Ownable` from OpenZeppelin and implement `withdraw()` or emergency `pause()` / `circuit breaker` patterns to allow safe fund recovery and emergency response.

* **Pin and update Solidity version**

   * Adopt `pragma solidity ^0.8.0;` (or a more recent 0.8.x release) and lock the compiler version in your build config.

* **Internal prize pool accounting**

   * Maintain a `uint256 prizePool` variable that is increased on deposits and decreased on payouts instead of depending on `address(this).balance`.

* **Safer ETH transfer patterns**

   * Replace `transfer()` with `call{value: amount}('')` and protect payout functions with `ReentrancyGuard` and checks-effects-interactions.

* **Minimize public visibility and gas optimizations**

   * Change functions that are not called internally to `external`. Review and mark state variables as `private` or `internal` when appropriate.

---

## Recommended tools & tests

* **Static analysis**: Slither, Mythril.
* **Fuzzing / property testing**: Echidna, Foundry (forge fuzz).
* **Unit tests**: Foundry (recommended).
* Test scenarios should include: miner/validator manipulation of blockhash, reentrancy, external forced ETH deposits (selfdestruct), and owner-only withdraw attempts.

---

## PoC and tests

The repository includes a Foundry [PoC - code](https://github.com/lucasgcampos/ether-capture-audit/blob/main/test/predict/PredictTheFutureChallengeTest.sol) that demonstrates the exploit via `vm.roll` in the test environment, which is equivalent to waiting a hash equal the guess`. To run:

```solidity
forge t test/predict/PredictTheFutureChallengeTest.sol
```

---

## Quick checklist

* [ ] Replace predictable RNG with Chainlink VRF or commit–reveal design.
* [ ] Add `Ownable` and `withdraw`/`pause` mechanisms.
* [ ] Use `prizePool` internal accounting rather than `address(this).balance`.
* [ ] Pin to a modern Solidity version (0.8.x) and lock compiler config.
* [ ] Replace `transfer()` with `call()` and use `ReentrancyGuard`.
* [ ] Change `public` → `external` where appropriate to save gas.

---

## Conclusion

The contract exhibits clear, exploitable weaknesses in randomness derivation and lacks administrative controls. While such weaknesses may be intended for an educational challenge (capture-the-ether style), they must be addressed before any real-value deployment. The most impactful fix is adopting a verifiable randomness source (Chainlink VRF) and adding owner/emergency withdrawal and internal prize accounting.

---

## 👤 Authors
**Lucas Campos**  
**[Filêmon Santos](https://www.linkedin.com/in/filemoncsantos)**  
📅 *November 2025*  
🔗 *Blockchain Security Review Collection*
