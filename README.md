# GreenCredit

A decentralized carbon credit marketplace built on Stacks blockchain for transparent and secure trading of verified carbon credits with comprehensive multi-standard verification support and efficient batch operations.

## Overview

GreenCredit enables organizations and individuals to trade verified carbon credits in a transparent, secure, and decentralized manner. The platform supports multiple international verification standards and ensures proper verification, tracking, and retirement of carbon credits while maintaining full transparency on the blockchain.

## Features

- **Multi-Standard Verification**: Support for VCS, Gold Standard, CDM, CAR, and ACR standards
- **Verified Credit Issuance**: Only authorized verifiers can issue carbon credits for their approved standards
- **Batch Operations**: Efficient bulk credit issuance and retirement operations (up to 20 items per batch)
- **Transparent Trading**: All transactions are recorded on-chain for complete transparency
- **Credit Retirement**: Credits can be permanently retired to prevent double-counting
- **Balance Tracking**: Real-time tracking of credit ownership and balances
- **Methodology Tracking**: Full methodology information for each carbon credit project
- **Platform Fee Management**: Configurable platform fees for sustainability
- **Comprehensive Audit Trail**: Full transaction history for compliance and reporting
- **Standard Management**: Admin controls for adding and managing verification standards
- **Batch Operation Tracking**: Complete audit trail for all batch operations with success metrics

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
- `batch-issue-carbon-credits`: Issue multiple carbon credits in a single transaction (up to 20 credits)
- `purchase-credits`: Purchase carbon credits from issuers
- `retire-credits`: Permanently retire credits from circulation
- `batch-retire-credits`: Retire multiple credits in a single transaction (up to 20 credits)
- `authorize-verifier`: Admin function to authorize credit verifiers for specific standards
- `add-verification-standard`: Admin function to add new verification standards
- `deactivate-standard`: Admin function to deactivate verification standards
- `update-platform-fee`: Admin function to update platform fees

### Read-Only Functions

- `get-credit-info`: Retrieve detailed information about a carbon credit including methodology
- `get-user-balance`: Check user's balance for specific credit
- `get-transaction-info`: Retrieve transaction details
- `get-batch-info`: Retrieve batch operation details and metrics
- `is-authorized-verifier`: Check if a principal is an authorized verifier
- `get-verifier-standards`: Get list of standards a verifier is authorized for
- `get-platform-fee`: Get current platform fee percentage
- `get-next-batch-id`: Get next available batch operation ID
- `get-supported-standard-info`: Get information about a verification standard
- `is-standard-supported`: Check if a standard is supported
- `get-credits-by-standard`: Query credits by verification standard

## Batch Operations

### Batch Credit Issuance

Issue multiple carbon credits efficiently in a single transaction:

```clarity
;; Example batch issuance
(batch-issue-carbon-credits 
  (list 
    {
      project-name: "Solar Farm Kenya",
      verification-standard: "VCS",
      vintage-year: u2023,
      total-credits: u10000,
      price-per-credit: u15,
      methodology: "VM0006: Solar Methodology"
    }
    {
      project-name: "Wind Farm Brazil",
      verification-standard: "GOLD",
      vintage-year: u2023,
      total-credits: u5000,
      price-per-credit: u18,
      methodology: "WM0001: Wind Power Methodology"
    }
  ))
```

### Batch Credit Retirement

Retire multiple credits efficiently:

```clarity
;; Example batch retirement
(batch-retire-credits 
  (list 
    { credit-id: u1, amount: u1000 }
    { credit-id: u2, amount: u500 }
    { credit-id: u3, amount: u2000 }
  ))
```

### Batch Operation Benefits

- **Efficiency**: Process multiple operations in a single transaction
- **Cost Savings**: Reduced transaction fees for bulk operations
- **Atomic Operations**: All items in a batch succeed or fail together
- **Audit Trail**: Complete tracking of batch operations with success metrics
- **Validation**: Comprehensive validation ensures all items meet requirements
- **Size Limits**: Maximum 20 items per batch to prevent excessive gas usage

### Batch Operation Tracking

Each batch operation is recorded with:
- Operation type (ISSUE or RETIRE)
- Operator principal
- Timestamp and block height
- Number of items processed
- Total credits affected
- Success count for validation

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
2. Use `issue-carbon-credits` for single credit issuance
3. Use `batch-issue-carbon-credits` for efficient bulk issuance (up to 20 credits)
4. Ensure compliance with the specific standard requirements

#### For Credit Buyers
1. Browse available credits by standard using read-only functions
2. Use `purchase-credits` to buy available credits
3. Check credit information including verification standard and methodology

#### For Credit Retirement
1. Use `retire-credits` for single credit retirement
2. Use `batch-retire-credits` for efficient bulk retirement (up to 20 credits)
3. Maintain records for compliance and reporting purposes

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
clarinet test --filter batch-operations
```

Test batch operations:
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

// Issue single credit with methodology
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

// Batch issue credits
const batchIssueResult = await callContractFunction({
  contractAddress: CONTRACT_ADDRESS,
  contractName: 'greencredit',
  functionName: 'batch-issue-carbon-credits',
  functionArgs: [
    listCV([
      tupleCV({
        'project-name': stringAsciiCV('Solar Farm 1'),
        'verification-standard': stringAsciiCV('VCS'),
        'vintage-year': uintCV(2023),
        'total-credits': uintCV(5000),
        'price-per-credit': uintCV(15),
        'methodology': stringAsciiCV('VM0006: Solar Methodology')
      }),
      tupleCV({
        'project-name': stringAsciiCV('Wind Farm 1'),
        'verification-standard': stringAsciiCV('GOLD'),
        'vintage-year': uintCV(2023),
        'total-credits': uintCV(3000),
        'price-per-credit': uintCV(18),
        'methodology': stringAsciiCV('WM0001: Wind Methodology')
      })
    ])
  ]
});

// Batch retire credits
const batchRetireResult = await callContractFunction({
  contractAddress: CONTRACT_ADDRESS,
  contractName: 'greencredit',
  functionName: 'batch-retire-credits',
  functionArgs: [
    listCV([
      tupleCV({
        'credit-id': uintCV(1),
        'amount': uintCV(1000)
      }),
      tupleCV({
        'credit-id': uintCV(2),
        'amount': uintCV(500)
      })
    ])
  ]
});

// Get batch operation info
const batchInfo = await callReadOnlyFunction({
  contractAddress: CONTRACT_ADDRESS,
  contractName: 'greencredit',
  functionName: 'get-batch-info',
  functionArgs: [uintCV(1)]
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

### Batch Operation Auditing

All batch operations are tracked with:
- Batch ID and operation type
- Operator and timestamp
- Items count and total credits
- Success metrics and validation results

### Reporting Features

- Credit issuance by standard
- Transaction history by standard
- Retirement tracking
- Verifier activity monitoring
- Batch operation analytics
- Success rate metrics

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
- Test batch operations thoroughly
- Validate gas usage for batch operations

## Security Considerations

- All verifiers must be explicitly authorized for specific standards
- Standards can be deactivated if issues arise
- Platform fees are capped at maximum 10%
- All inputs are validated before processing
- Proper error handling prevents undefined behavior
- Batch operations are atomic (all succeed or all fail)
- Batch size is limited to prevent excessive gas usage (max 20 items)
- Comprehensive validation for all batch items

## Performance Optimizations

- Batch operations reduce transaction overhead
- Maximum batch size prevents gas limit issues
- Efficient fold operations for batch processing
- Proper balance tracking with minimal storage overhead
- Optimized validation functions for better performance

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Check the documentation for common questions
- Review the test files for usage examples

## Roadmap

- ✅ **Batch Operations**: Enable bulk credit issuance and retirement for efficiency
- **Price Discovery**: Implement dynamic pricing based on supply and demand
- **Escrow System**: Add escrow functionality for secure large transactions
- **NFT Integration**: Convert credits to NFTs for enhanced ownership tracking
- **Carbon Offset Calculator**: Integrate tools to calculate carbon footprints
- **Staking Rewards**: Implement staking mechanism for credit holders
- **Cross-Chain Bridge**: Enable trading across different blockchain networks
- **API Integration**: Connect with external carbon registries and databases
- **Mobile App**: Develop mobile application for easier credit management
- **Advanced Analytics**: Enhanced reporting and analytics for batch operations
- **Batch Transfer**: Enable batch transfer of credits between users