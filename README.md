# 🧠 Smart Contract Security Audits

## 📘 Overview
This repository contains a collection of **smart contract security audits** performed on various Solidity-based projects.  
Each audit includes detailed vulnerability findings, severity classifications, and recommended remediations following industry best practices.  

The goal of this repository is to serve both as:
- A **knowledge base** for common Solidity vulnerabilities and secure coding patterns.  
- A **portfolio** of real-world contract audits demonstrating analysis, exploit reproduction, and secure refactoring.

---

## 🧩 Repository Structure

Each audited contract is organized in its own folder containing:
- **Source code** of the analyzed contract (`.sol` files).  
- **Audit report** (`README.md`) describing vulnerabilities, severity levels, and recommendations.  
- **Test scripts** (`.t.sol` or `.s.sol`) to reproduce vulnerabilities or validate fixes.  

Example structure:
```
/src
├── random/
│ ├── contract.sol
│ ├── slither
│ └── README.md ← detailed audit report
├── retirement/
│ └── ...
└── ...
```


---

## 🧾 Example Audit Report
A sample of one of the audits (the **RetirementFundChallenge** review) can be found here:

- [RetirementFundChallenge Audit Report](./src/retirement/README.md)
- [GuessTheRandomNumberChallenge Audit Report](./src/random/README.md)

This report includes:
- Full vulnerability breakdown by severity.  
- Suggested code improvements.  
- Secure implementation examples.  
- Step-by-step instructions on how to execute the tests and scripts locally using **Foundry**.

---

## ⚙️ Environment & Tools
All contracts and tests are built and audited using the following toolset:
- [**Foundry**](https://book.getfoundry.sh/) (for testing, scripting, and deployment)  
- [**Anvil**](https://book.getfoundry.sh/anvil/) (local Ethereum node)  
- [**Solidity**](https://soliditylang.org/) `^0.8.x`  

---

## 🛡️ Purpose
This repository aims to promote **secure smart contract development** through:
- Demonstrating **real audit methodologies**.  
- Documenting **exploit scenarios** and **fix implementations**.  
- Encouraging best practices aligned with **OpenZeppelin** and **Ethereum security standards**.

---

## 👤 Author
**Lucas Gonçalves de Campos**  
📅 *November 2025*  
🔗 *Blockchain Security Review Collection*

