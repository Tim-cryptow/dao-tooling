# 🧠 DAO Tooling — Low-Friction Governance with Clarity & Stacks

This project provides smart contract tooling for building low-friction DAOs on the Stacks blockchain. It includes on-chain governance, proposal voting, and secure treasury execution, all written in [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-overview).

---

## 📦 Project Structure

```bash
contracts/
├── governance.clar         # Core governance logic (proposals, voting)
├── treasury.clar           # Treasury contract with STX transfer logic
├── governance-trait.clar   # Trait interface for DAO/tokensafe separation
✨ Features
📜 Propose actions for DAO execution

✅ Vote on proposals (for / against)

🔐 Only execute treasury transfers from approved proposals

🧩 Modular contracts using Clarity traits

🔍 Read-only functions for proposal status and balances

🛠 Setup (with Clarinet)
Make sure you have Clarinet installed.

bash
Copy
Edit
# Install dependencies
clarinet check

# Run tests
clarinet test

# Launch REPL to interact with contracts
clarinet console
🧪 Contract Overview
governance.clar
Handles:

propose: Create a proposal

vote: Vote for or against a proposal

execute: Mark a proposal as executed

approved-spends: Details for the treasury to check

treasury.clar
Handles:

deposit: Placeholder for receiving funds

spend: Executes a transfer only if the proposal was approved

get-balance: View the caller’s STX balance

governance-trait.clar
Defines the trait that treasury.clar expects:

proposals

approved-spends

🔐 Security Considerations
Treasury only executes if a proposal is approved and not yet executed

Prevents double-spending via executed flag

Modular design keeps logic separated and auditable

📜 License
MIT License — feel free to fork and build upon it for your DAO.

yaml
Copy
Edit
