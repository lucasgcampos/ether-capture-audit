# Audit — GuessTheRandomNumberChallenge

This document summarizes the findings from an audit of the `GuessTheRandomNumberChallenge` contract (Solidity ^0.8.x).

---

## Quick summary

The contract implements a simple game where a `uint8 answer` is generated in the constructor and players pay 1 ETH to guess; if they guess correctly they receive 2 ETH. The audit reveals **critical vulnerabilities** related to randomness generation and privacy of the `answer` value.

---

## High severity

* **Low entropy for the secret number**

  * `answer` is derived from on-chain values with limited entropy (block hash + timestamp). Low entropy makes brute-force and prediction feasible.

* **False sense of randomness (block-based data)**

  * `keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))` depends on `block.timestamp` and `blockhash`, which are predictable / manipulable by miners/validators — not a secure randomness source.

* **Answer stored on-chain (readable from storage)**

  * Even if `answer` is not declared `public`, any data stored in contract storage is **publicly readable** (via `eth_getStorageAt`). An attacker can read the storage slot and discover `answer` instantly.

---

## Medium severity

* **Using contract balance to determine completion**

  * Using `address(this).balance == 0` as the `isComplete()` condition is brittle. The contract balance can be affected by external transfers, donations, or unexpected behaviors — this can break the logical invariants expected by the app.

---

## Best practices & code notes

* **Functions could be `external`**

  * Public functions that are not called internally (e.g., `guess`) may be marked `external` to reduce call surface and save gas.

* **`answer` could be `immutable`**

  * If `answer` is only set in the constructor, marking it `immutable` clarifies intent and reduces gas. Note: `immutable` does not prevent storage reading; it only helps readability and gas usage.

* **Use Pull over Push for payments**

  * Instead of sending ETH inline with `transfer`/`call` in the game flow, credit prizes and let winners `withdraw` to reduce risks and improve resilience.

* **Replace `transfer` with `call` and protect with `ReentrancyGuard`**

  * `transfer` may fail in some cases; the modern pattern is `call` with return checking and `ReentrancyGuard` for withdrawals.

* **Add events**

  * Emit `GuessSubmitted`, `Winner`, `Funded` events to facilitate monitoring and post-deployment forensics.

---

## Mitigation recommendations

1. **Use Chainlink VRF (recommended)**

   * Use an off-chain verifiable random function (VRF) to ensure unpredictability and miner resistance.

2. **Or: adopt Commit–Reveal**

   * Store `commitment = keccak256(secret)` at deploy time and reveal the `secret` in a later step. Combine with rules to prevent abuse from the revealer.

3. **Avoid storing secrets on-chain**

   * Always assume storage is public. Redesign the logic to not rely on an on-chain private secret.

4. **Implement Pull-Payment and ReentrancyGuard**

   * Credit prizes and enable `withdraw` protected with `nonReentrant`.

5. **Improve completion criteria**

   * Use explicit state variables (e.g., `bool solved`) instead of checking `balance`.

---

## Small code improvements (sketch)

* Mark `guess` as `external` if it is not called internally.
* Declare `answer` as `uint8 public immutable answer;` if appropriate.
* Replace `transfer` with `call` inside a `withdraw` function, protected by `ReentrancyGuard`.

> Note: these changes reduce some risks and improve clarity, but they do not fix the core problem (insecure randomness / on-chain secret). For that, a VRF or redesign is necessary.

---

## PoC and tests

The repository includes a Foundry PoC that demonstrates the exploit via `vm.load` in the test environment, which is equivalent to reading storage in production via `provider.getStorageAt`.

```solidity
forge t
```

---

## Conclusion

The core issue is conceptual: **on-chain secrets + block-derived randomness is insecure**. The recommended fix is to re-design the random number generation using a trusted randomness source (Chainlink VRF) or a well-designed commit-reveal protocol, and to adopt pull payments and reentrancy protection.

---

## 👤 Author
**Lucas Gonçalves de Campos**  
📅 *November 2025*  
🔗 *Blockchain Security Review Collection*
