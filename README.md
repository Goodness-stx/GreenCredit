# GreenCredit

A decentralized carbon credit marketplace built on Stacks blockchain for transparent and secure trading of verified carbon credits with comprehensive multi-standard verification support, dynamic pricing, and efficient batch operations.

## Overview

GreenCredit enables organizations and individuals to trade verified carbon credits in a transparent, secure, and decentralized manner. The platform supports multiple international verification standards and ensures proper verification, tracking, and retirement of carbon credits while maintaining full transparency on the blockchain. With dynamic pricing based on supply and demand, the marketplace automatically adjusts prices to reflect real-time market conditions.

## Features

### Core Features
- **Multi-Standard Verification**: Support for VCS, Gold Standard, CDM, CAR, and ACR standards
- **Verified Credit Issuance**: Only authorized verifiers can issue carbon credits for their approved standards
- **Dynamic Pricing**: Automatic price adjustments based on supply/demand utilization rates
- **Price Floor Protection**: Ensures credits never sell below issuer-defined minimum prices
- **Batch Operations**: Efficient bulk credit issuance and retirement operations (up to 20 items per batch)
- **Transparent Trading**: All transactions are recorded on-chain for complete transparency
- **Credit Retirement**: Credits can be permanently retired to prevent double-counting
- **Balance Tracking**: Real-time tracking of credit ownership and balances
- **STX Payment Integration**: Automatic STX transfers with platform fee distribution

### Advanced Features
- **Utilization-Based Pricing**: Prices increase when demand is high (>80% sold), decrease when low (<20% sold)
- **Price History Tracking**: Complete historical record of prices, utilization rates, and demand multipliers
- **Methodology Tracking**: Full methodology information for each carbon credit project
- **Platform Fee Management**: Configurable platform fees (capped at 10%) for sustainability
- **Comprehensive Audit Trail**: Full transaction history for compliance and reporting
- **Standard Management**: Admin controls for adding and managing verification standards
- **Batch Operation Tracking**: Complete audit trail for all batch operations with success metrics

## Dynamic Pricing System

### How It Works

GreenCredit implements a sophisticated dynamic pricing mechanism that adjusts prices based on real-time supply and demand:

#### Price Components
- **Base Price**: Set by the credit issuer when creating the credit
- **Price Floor**: Minimum price that cannot be breached, even with low demand
- **Current Price**: Dynamically calculated based on utilization rate

#### Utilization-Based Adjustments

```
Utilization Rate = (Total Credits - Available Credits) / Total Credits × 100%
```

**High Demand (>80% utilization)**
- Prices increase up to 500% of base price
- Encourages supply and rewards early adopters
- 5% price increase per percentage point above 80%

**Normal Demand (20-80% utilization)**
- Prices remain at base price
- Stable market conditions

**Low Demand (<20% utilization)**
- Prices decrease to minimum 50% of base price
- Never falls below price floor
- Incentivizes buyers during low demand periods

#### Example Pricing Scenarios

```clarity
Project: Solar Farm Kenya
Base Price: 15 STX
Price Floor: 12 STX
Total Credits: 10,000

Scenario 1 - High Demand (85% sold):
- Utilization: 85%
- Price Multiplier: 125% (base + 5% per point above 80%)
- Current Price: 18.75 STX

Scenario 2 - Normal Demand (50% sold):
- Utilization: 50%
- Price Multiplier: 100%
- Current Price: 15 STX (base price)

Scenario 3 - Low Demand (10% sold):
- Utilization: 10%
- Price Multiplier: 50% (minimum)
- Current Price: 12 STX (price floor prevents going lower)
```

### Dynamic Pricing Benefits

- **Fair Market Discovery**: Prices reflect actual supply and demand
- **Issuer Protection**: Price floors prevent undervaluation
- **Buyer Incentives**: Lower prices during oversupply periods
- **Market Transparency**: All pricing components visible on-chain
- **Automatic Adjustments**: No manual intervention required

### Disabling Dynamic Pricing

Platform administrators can toggle dynamic pricing on/off:
- When disabled, credits sell at base price
- Useful for fixed-price scenarios or testing
- Can be re-enabled at any time

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

#### Credit Issuance
- `issue-carbon-credits`: Issue new verified carbon credits with base price and price floor
- `batch-issue-carbon-credits`: Issue multiple carbon credits in a single transaction (up to 20 credits)

#### Trading & Retirement
- `purchase-credits`: Purchase carbon credits at dynamic prices with automatic STX transfers
- `retire-credits`: Permanently retire credits from circulation
- `batch-retire-credits`: Retire multiple credits in a single transaction (up to 20 credits)

#### Administration
- `authorize-verifier`: Admin function to authorize credit verifiers for specific standards
- `add-verification-standard`: Admin function to add new verification standards
- `deactivate-standard`: Admin function to deactivate verification standards
- `update-platform-fee`: Admin function to update platform fees (max 10%)
- `toggle-dynamic-pricing`: Admin function to enable/disable dynamic pricing

### Read-Only Functions

#### Credit Information
- `get-credit-info`: Retrieve detailed information about a carbon credit including methodology
- `get-current-credit-price`: Get the current dynamic price for a credit
- `get-price-components`: Get detailed breakdown of base price, floor, current price, and utilization
- `get-price-history-at`: Retrieve historical price data for a specific timestamp
- `get-user-balance`: Check user's balance for specific credit

#### Transaction & Batch Information
- `get-transaction-info`: Retrieve transaction details including price paid
- `get-batch-info`: Retrieve batch operation details and metrics

#### Verifier & Platform Information
- `is-authorized-verifier`: Check if a principal is an authorized verifier
- `get-verifier-standards`: Get list of standards a verifier is authorized for
- `get-platform-fee`: Get current platform fee percentage
- `is-dynamic-pricing-enabled`: Check if dynamic pricing is currently enabled
- `get-next-credit-id`: Get next available credit ID
- `get-next-batch-id`: Get next available batch operation ID

#### Standards Information
- `get-supported-standard-info`: Get information about a verification standard
- `is-standard-supported`: Check if a standard is supported

## Batch Operations

### Batch Credit Issuance

Issue multiple carbon credits efficiently in a single transaction:

```clarity
;; Example batch issuance with price floors
(batch-issue-carbon-credits 
  (list 
    {
      project-name: "Solar Farm Kenya",
      verification-standard: "VCS",
      vintage-year: u2023,
      total-credits: u10000,
      base-price: u15,
      price-floor: u12,
      methodology: "VM0006: Solar Methodology"
    }
    {
      project-name: "Wind Farm Brazil",
      verification-standard: "GOLD",
      vintage-year: u2023,
      total-credits: u5000,
      base-price: u18,
      price-floor: u15,
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
3. Use `update-platform-fee` to adjust platform fees (max 10%)
4. Use `toggle-dynamic-pricing` to enable/disable dynamic pricing
5. Use `deactivate-standard` to disable standards if needed

#### For Verifiers
1. Get authorized for specific standards via admin
2. Use `issue-carbon-credits` for single credit issuance with base price and price floor
3. Use `batch-issue-carbon-credits` for efficient bulk issuance (up to 20 credits)
4. Ensure compliance with the specific standard requirements
5. Set appropriate price floors to protect against undervaluation

#### For Credit Buyers
1. Browse available credits by standard using read-only functions
2. Check current prices with `get-current-credit-price` to see dynamic pricing
3. Use `get-price-components` to understand pricing breakdown
4. Use `purchase-credits` to buy available credits (STX automatically transferred)
5. Check credit information including verification standard and methodology

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
clarinet test --filter dynamic-pricing
clarinet test --filter batch-operations
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
// Check current dynamic price
const currentPrice = await callReadOnlyFunction({
  contractAddress: CONTRACT_ADDRESS,
  contractName: 'greencredit',
  functionName: 'get-current-credit-price',
  functionArgs: [uintCV(1)]
});

// Get detailed price breakdown
const priceComponents = await callReadOnlyFunction({
  contractAddress: CONTRACT_ADDRESS,
  contractName: 'greencredit',
  functionName: 'get-price-components',
  functionArgs: [uintCV(1)]
});
// Returns: base-price, price-floor, current-price, utilization-rate, 
//          demand-multiplier, dynamic-pricing-enabled

// Issue credit with dynamic pricing support
const issueResult = await callContractFunction({
  contractAddress: CONTRACT_ADDRESS,
  contractName: 'greencredit',
  functionName: 'issue-carbon-credits',
  functionArgs: [
    stringAsciiCV('Solar Project Kenya'),
    stringAsciiCV('VCS'),
    uintCV(2023),
    uintCV(10000),
    uintCV(15),        // base-price
    uintCV(12),        // price-floor
    stringAsciiCV('VM0006: Methodology for Carbon Accounting')
  ]
});

// Purchase credits at current dynamic price
const purchaseResult = await callContractFunction({
  contractAddress: CONTRACT_ADDRESS,
  contractName: 'greencredit',
  functionName: 'purchase-credits',
  functionArgs: [
    uintCV(1),         // credit-id
    uintCV(100)        // amount
  ],
  // Note: STX will be automatically transferred based on dynamic price
  postConditions: [
    makeStandardSTXPostCondition(
      userAddress,
      FungibleConditionCode.LessEqual,
      new BN(expectedMaxCost)
    )
  ]
});

// Batch issue credits with price floors
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
        'base-price': uintCV(15),
        'price-floor': uintCV(12),
        'methodology': stringAsciiCV('VM0006: Solar Methodology')
      }),
      tupleCV({
        'project-name': stringAsciiCV('Wind Farm 1'),
        'verification-standard': stringAsciiCV('GOLD'),
        'vintage-year': uintCV(2023),
        'total-credits': uintCV(3000),
        'base-price': uintCV(18),
        'price-floor': uintCV(15),
        'methodology': stringAsciiCV('WM0001: Wind Methodology')
      })
    ])
  ]
});

// Get price history for analytics
const priceHistory = await callReadOnlyFunction({
  contractAddress: CONTRACT_ADDRESS,
  contractName: 'greencredit',
  functionName: 'get-price-history-at',
  functionArgs: [uintCV(1), uintCV(blockHeight)]
});
```

## Compliance and Auditing

### Audit Trail

All transactions are recorded with:
- Credit ID and verification standard
- Transaction parties
- Amount and **dynamic price paid**
- Timestamp and block height
- Methodology information

### Price History Tracking

The platform maintains complete price history:
- Current price at time of transaction
- Utilization rate when price was calculated
- Demand multiplier applied
- Block height for temporal tracking

### Batch Operation Auditing

All batch operations are tracked with:
- Batch ID and operation type
- Operator and timestamp
- Items count and total credits
- Success metrics and validation results

### Reporting Features

- Credit issuance by standard
- Transaction history by standard with prices paid
- Price trends and utilization analytics
- Retirement tracking
- Verifier activity monitoring
- Batch operation analytics
- Success rate metrics
- Dynamic pricing effectiveness analysis

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
- Test dynamic pricing scenarios across different utilization rates
- Ensure price floor protection works correctly

## Security Considerations

- All verifiers must be explicitly authorized for specific standards
- Standards can be deactivated if issues arise
- Platform fees are capped at maximum 10%
- All inputs are validated before processing
- Proper error handling prevents undefined behavior
- Batch operations are atomic (all succeed or all fail)
- Batch size is limited to prevent excessive gas usage (max 20 items)
- Comprehensive validation for all batch items
- **Price floor protection** prevents credits from being undervalued
- **STX transfers** are executed atomically with credit transfers
- **Dynamic pricing bounds** prevent extreme price manipulation (50%-500% range)

## Performance Optimizations

- Batch operations reduce transaction overhead
- Maximum batch size prevents gas limit issues
- Efficient fold operations for batch processing
- Proper balance tracking with minimal storage overhead
- Optimized validation functions for better performance
- Price calculations cached during transaction execution
- Utilization rate computed efficiently without iteration

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Check the documentation for common questions
- Review the test files for usage examples

## Roadmap

- ✅ **Multi-Standard Support**: Five major verification standards integrated
- ✅ **Batch Operations**: Enable bulk credit issuance and retirement for efficiency
- ✅ **Dynamic Pricing**: Automatic price discovery based on supply and demand
- ✅ **Price Floor Protection**: Issuer-defined minimum prices
- ✅ **STX Payment Integration**: Automatic payment transfers with platform fees
- **Escrow System**: Add escrow functionality for secure large transactions
- **NFT Integration**: Convert credits to NFTs for enhanced ownership tracking
- **Carbon Offset Calculator**: Integrate tools to calculate carbon footprints
- **Staking Rewards**: Implement staking mechanism for credit holders
- **Cross-Chain Bridge**: Enable trading across different blockchain networks
- **API Integration**: Connect with external carbon registries and databases
- **Mobile App**: Develop mobile application for easier credit management
- **Advanced Analytics Dashboard**: Enhanced reporting and analytics for price trends
- **Batch Transfer**: Enable batch transfer of credits between users
- **Automated Market Maker (AMM)**: Liquidity pools for instant trading
- **Oracle Integration**: Real-world carbon price feeds for reference pricing

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     GreenCredit Platform                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Issuance   │  │   Trading    │  │  Retirement  │     │
│  │   Engine     │  │   Engine     │  │   Engine     │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │              │
│         └──────────────────┼──────────────────┘              │
│                            │                                 │
│                   ┌────────▼────────┐                       │
│                   │ Dynamic Pricing  │                       │
│                   │     System       │                       │
│                   └────────┬────────┘                       │
│                            │                                 │
│         ┌──────────────────┼──────────────────┐             │
│         │                  │                  │             │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐    │
│  │ Verification │  │   Payment    │  │    Audit     │    │
│  │   Standards  │  │   Processor  │  │    Trail     │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```
