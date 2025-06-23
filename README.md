# Food Supply Chain Tracker

A Clarity smart contract for tracking food products through the entire supply chain, from farm to consumer, ensuring transparency and authenticity.

## Overview

This smart contract enables food producers, distributors, retailers, and consumers to track the journey of food products through various stages of the supply chain. Each product gets a unique ID and maintains a complete history of its movement through different handlers and locations.

## Features

- **Product Creation**: Producers can register new food products with origin details
- **Stage Tracking**: Authorized handlers can update product stages (harvested, processed, shipped, delivered, etc.)
- **History Preservation**: Complete audit trail of all product movements and handlers
- **Access Control**: Owner can authorize/revoke handlers who can update product stages
- **Transparency**: Anyone can verify product information and history

## Contract Functions

### Public Functions

- `create-product(name, origin-location)` - Create a new product entry
- `update-product-stage(product-id, new-stage, location, notes)` - Update product to next stage
- `authorize-handler(handler)` - Authorize a new supply chain handler (owner only)
- `revoke-handler(handler)` - Revoke handler authorization (owner only)

### Read-Only Functions

- `get-product(product-id)` - Get product details
- `get-product-history(product-id, stage-id)` - Get specific stage information
- `get-product-stage-count(product-id)` - Get total number of stages for a product
- `is-handler-authorized(handler)` - Check if handler is authorized
- `get-next-product-id()` - Get the next available product ID

## Usage Example

1. **Producer creates product**: `(contract-call? .food-supply-chain create-product "Organic Tomatoes" "Farm A, California")`
2. **Authorize distributor**: `(contract-call? .food-supply-chain authorize-handler 'SP2DISTRIBUTOR...)`
3. **Update stage**: `(contract-call? .food-supply-chain update-product-stage u1 "harvested" "Farm A" "Harvested on sunny day")`
4. **Track product**: `(contract-call? .food-supply-chain get-product u1)`

## Security Features

- Only contract owner can authorize handlers
- Only authorized handlers or original producer can update product stages
- All actions are permanently recorded on blockchain
- Complete audit trail prevents fraud and ensures accountability

## Development

This contract is built using Clarity and can be deployed on the Stacks blockchain. It provides a foundation for building comprehensive food traceability applications.

## License
