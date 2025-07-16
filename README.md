# GreenCredit

A decentralized carbon credit marketplace built on Stacks blockchain for transparent and secure trading of verified carbon credits.

## Overview

GreenCredit enables organizations and individuals to trade verified carbon credits in a transparent, secure, and decentralized manner. The platform ensures proper verification, tracking, and retirement of carbon credits while maintaining full transparency on the blockchain.

## Features

- **Verified Credit Issuance**: Only authorized verifiers can issue carbon credits
- **Transparent Trading**: All transactions are recorded on-chain for complete transparency
- **Credit Retirement**: Credits can be permanently retired to prevent double-counting
- **Balance Tracking**: Real-time tracking of credit ownership and balances
- **Platform Fee Management**: Configurable platform fees for sustainability
- **Comprehensive Audit Trail**: Full transaction history for compliance and reporting

## Smart Contract Functions

### Core Functions

- `issue-carbon-credits`: Issue new verified carbon credits
- `purchase-credits`: Purchase carbon credits from issuers
- `retire-credits`: Permanently retire credits from circulation
- `authorize-verifier`: Admin function to authorize credit verifiers
- `update-platform-fee`: Admin function to update platform fees

### Read-Only Functions

- `get-credit-info`: Retrieve detailed information about a carbon credit
- `get-user-balance`: Check user's balance for specific credit
- `get-transaction-info`: Retrieve transaction details
- `is-authorized-verifier`: Check if a principal is an authorized verifier
- `get-platform-fee`: Get current platform fee percentage

## Getting Started

### Prerequisites

- Clarinet CLI installed
- Stacks wallet for testing
- Basic understanding of Clarity smart contracts

### Installation

1. Clone the repository
2. Install dependencies with `clarinet install`
3. Run tests with `clarinet test`
4. Deploy to testnet with `clarinet deploy`

### Usage

1. **For Verifiers**: Use `authorize-verifier` to get authorized, then `issue-carbon-credits` to create new credits
2. **For Buyers**: Use `purchase-credits` to buy available credits
3. **For Retirement**: Use `retire-credits` to permanently remove credits from circulation

## Testing

Run the test suite with:
```bash
clarinet test
```

## Deployment

Deploy to testnet:
```bash
clarinet deploy --testnet
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request