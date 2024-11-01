# SwapGuard
Interest Rate Swap AVS (currently ecdsa based)

![Architecture](https://github.com/user-attachments/assets/bdff4932-2bac-4f29-8c82-fde3ecc7b439)

## User Flow

### Initial Setup
1. Users must have active loan positions:
  - Fixed Rate User: Has a fixed-rate loan on lending protocol
  - Variable Rate User: Has a variable-rate loan on lending protocol

### Creating Swap Requests
1. **Fixed Rate User**
  - Submits swap request with:
    - Notional amount (e.g., 10 ETH)
    - Fixed rate (e.g., 6%)
    - Duration (e.g., 1 year)
    - Required margin
  - Loan position is verified by operators

2. **Variable Rate User**
  - Submits matching swap request with:
    - Same notional amount
    - Agreeable fixed rate
    - Matching duration
    - Required margin
  - Loan position is verified by operators

### Swap Matching & Validation
1. Operators validate:
  - Both loans exist and are active
  - Matching parameters (amount, rate, duration)
  - Sufficient margins provided
2. Once validated, swaps are matched
3. Both parties are now in an active swap

### Settlement Process
1. Monthly settlements:
  - Operators monitor current variable rate
  - Calculate rate differential
  - Validate both loans are still active
  - Execute settlement payments

2. Settlement payments:
  - If variable rate > fixed rate:
    - Variable rate user receives difference
  - If fixed rate > variable rate:
    - Fixed rate user receives difference

### Swap Termination
- Swap continues until duration ends
- Final settlement is executed
- Remaining margins are returned
- Swap positions are closed

## Future Improvements
- Implement better handling when users repay underlying loans early
- Develop automated unwinding process with fair penalty structure
- Better integration with lending protocol rate feeds
