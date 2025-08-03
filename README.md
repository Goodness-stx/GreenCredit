# GreenCredit

A decentralized carbon credit marketplace built on Stacks blockchain for transparent and secure trading of verified carbon credits with comprehensive multi-standard verification support.

## Overview

GreenCredit enables organizations and individuals to trade verified carbon credits in a transparent, secure, and decentralized manner. The platform supports multiple international verification standards and ensures proper verification, tracking, and retirement of carbon credits while maintaining full transparency on the blockchain.

## Features

- **Multi-Standard Verification**: Support for VCS, Gold Standard, CDM, CAR, and ACR standards
- **Verified Credit Issuance**: Only authorized verifiers can issue carbon credits for their approved standards
- **Transparent Trading**: All transactions are recorded on-chain for complete transparency
- **Credit Retirement**: Credits can be permanently retired to prevent double-counting
- **Balance Tracking**: Real-time tracking of credit ownership and balances
- **Methodology Tracking**: Full methodology information for each carbon credit project
- **Platform Fee Management**: Configurable platform fees for sustainability
- **Comprehensive Audit Trail**: Full transaction history for compliance and reporting
- **Standard Management**: Admin controls for adding and managing verification standards

## Supported Verification Standards

### Currently Supported

- **VCS (Verified Carbon Standard)**: World's most used GHG program
- **Gold Standard**: Premium quality carbon credits with sustainable development co-benefits
- **CDM (Clean Development Mechanism)**: UN framework for emission reduction projects
- **CAR (Climate Action Reserve)**: North American carbon offset standard
- **ACR (American Carbon Registry)**: US-focused carbon offset standard

### Standard Features

- Each verifier is authorized for specific standards
- Standards can be activated/deactivated by admin
- Minimum project size requirements per standard
- Detailed standard descriptions and requirements

## Smart Contract Functions

### Core Functions

- `issue-carbon-credits`: Issue new verified carbon credits with methodology information
- `purchase-credits`: Purchase carbon credits from issuers
- `retire-credits`: Permanently retire credits from circulation
- `authorize-verifier`: Admin function to authorize credit verifiers for specific standards
- `add-verification-standard`: Admin function to add new verification standards
- `deactivate-standard`: Admin function to deactivate verification standards
- `update-platform-fee`: Admin function to update platform fees

### Read-Only Functions

- `get-credit-info`: Retrieve detailed information about a carbon credit including methodology
- `get-user-balance`: Check user's balance for specific credit
- `get-transaction-info`: Retrieve transaction details
- `is-authorized-verifier`: Check if a principal is an authorized verifier
- `get-verifier-standards`: Get list of standards a verifier is authorized for
- `get-platform-fee`: Get current platform fee percentage
- `get-supported-standard-info`: Get information about a verification standard
- `is-standard-supported`: Check if a standard is supported
- `get-credits-by-standard`: Query credits by verification standard

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

#### For Platform Administrators
1. Use `add-verification-standard` to add new standards if needed
2. Use `authorize-verifier` to authorize verifiers for specific standards
3. Use `update-platform-fee` to adjust platform fees
4. Use `deactivate-standard` to disable standards if needed

#### For Verifiers
1. Get authorized for specific standards via admin
2. Use `issue-carbon-credits` to create new credits with methodology information
3. Ensure compliance with the specific standard requirements

#### For Credit Buyers
1. Browse available credits by standard using read-only functions
2. Use `purchase-credits` to buy available credits
3. Check credit information including verification standard and methodology

#### For Credit Retirement
1. Use `retire-credits` to permanently remove credits from circulation
2. Maintain records for compliance and reporting purposes

## Verification Standards Integration

### Standard Requirements

Each verification standard has specific requirements:

- **Project Size**: Minimum project size requirements
- **Methodology**: Approved methodologies for each standard
- **Verification**: Third-party verification requirements
- **Monitoring**: Ongoing monitoring and reporting requirements

### Verifier Authorization

Verifiers must be specifically authorized for each standard they wish to issue credits for:

```clarity
;; Example: Authorize verifier for VCS and Gold Standard
(authorize-verifier 'SP123...ABC (list "VCS" "GOLD"))
```

### Adding New Standards

Platform administrators can add new verification standards:

```clarity
;; Example: Add new standard
(add-verification-standard "NEW-STANDARD" u1000 "Description of new standard")
```

## Testing

Run the comprehensive test suite:
```bash
clarinet test
```

Test specific functionality:
```bash
clarinet test --filter multi-standard
```

## Deployment

Deploy to testnet:
```bash
clarinet deploy --testnet
```

Deploy to mainnet:
```bash
clarinet deploy --mainnet
```

## API Integration

### Example Usage

```javascript
// Check supported standards
const standardInfo = await callReadOnlyFunction({
  contractAddress: CONTRACT_ADDRESS,
  contractName: 'greencredit',
  functionName: 'get-supported-standard-info',
  functionArgs: [stringAsciiCV('VCS')]
});

// Issue credits with methodology
const issueResult = await callContractFunction({
  contractAddress: CONTRACT_ADDRESS,
  contractName: 'greencredit',
  functionName: 'issue-carbon-credits',
  functionArgs: [
    stringAsciiCV('Solar Project Kenya'),
    stringAsciiCV('VCS'),
    uintCV(2023),
    uintCV(10000),
    uintCV(15),
    stringAsciiCV('VM0006: Methodology for Carbon Accounting')
  ]
});
```

## Compliance and Auditing

### Audit Trail

All transactions are recorded with:
- Credit ID and verification standard
- Transaction parties
- Amount and pricing
- Timestamp and block height
- Methodology information

### Reporting Features

- Credit issuance by standard
- Transaction history by standard
- Retirement tracking
- Verifier activity monitoring

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

### Development Guidelines

- Follow Clarity best practices
- Add comprehensive tests for new features
- Update documentation for any new functionality
- Ensure proper error handling and validation

## Security Considerations

- All verifiers must be explicitly authorized for specific standards
- Standards can be deactivated if issues arise
- Platform fees are capped at maximum 10%
- All inputs are validated before processing
- Proper error handling prevents undefined behavior

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Check the documentation for common questions
- Review the test files for usage examples

## Roadmap

- Batch Operations: Enable bulk credit issuance and retirement for efficiency
- Price Discovery: Implement dynamic pricing based on supply and demand
- Escrow System: Add escrow functionality for secure large transactions
- NFT Integration: Convert credits to NFTs for enhanced ownership tracking
- Carbon Offset Calculator: Integrate tools to calculate carbon footprints
- Staking Rewards: Implement staking mechanism for credit holders
- Cross-Chain Bridge: Enable trading across different blockchain networks
- API Integration: Connect with external carbon registries and databases
- Mobile App: Develop mobile application for easier credit management