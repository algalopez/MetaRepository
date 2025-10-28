
# Odds Conversion Tool

A comprehensive Haskell command-line application for converting between different odds formats used in betting and gambling.

## My little non-ai corner

Programming language: Haskell  
AI: Claude Sonnet 4 in agent mode  
IDE: vscode  
    note: Using the devContainer plugin there is no need to install the haskell compiler in the computer


## Features

**Complete 4×4 Conversion Matrix** supporting all 16 conversion combinations between:
- **Decimal Odds** (e.g., 1.20, 5.50)
- **Fractional Odds** (e.g., 1/5, 9/2)  
- **American Odds** (e.g., -500, +450)
- **Implied Probability** (e.g., 83.3%, 18.2%)

### Conversion Matrix
| From ↓ / To → | **Decimal** | **Fraction** | **American** | **Probability** |
|---------------|-------------|--------------|--------------|-----------------|
| **Decimal**   | ✅ Identity  | ✅ Convert   | ✅ Convert   | ✅ Convert      |
| **Fraction**  | ✅ Convert   | ✅ Simplify  | ✅ Convert   | ✅ Convert      |  
| **American**  | ✅ Convert   | ✅ Convert   | ✅ Format    | ✅ Convert      |
| **Probability** | ✅ Convert | ✅ Convert   | ✅ Convert   | ✅ Format       |

## Project Structure

```
odds-conversion-tool/
├── src/
│   ├── OddsLib.hs      # Core conversion library
│   └── Main.hs         # Application entry point
├── test/
│   ├── TestOddsLib.hs  # Library unit tests
│   └── TestMain.hs     # Integration tests
├── build.sh            # Build script
├── demo.sh             # Comprehensive demo script
├── convert             # Compiled executable
└── readme.md           # Documentation
└── test-main           # Compiled main test executable
└── test-oddslib        # Compiled oddslib test executable
```

## Quick Start

```bash
./build.sh              # Build and run all tests
./demo.sh               # Run comprehensive demo (all 16 conversions)
./convert --fromDecimal 2.5 --toFraction  # Manual conversion
```

## Installation & Usage

### Build & Test
```bash
# Build application and run all tests
./build.sh

# Manual build (if needed)
ghc -isrc -o convert src/Main.hs
```

### Usage

```bash
./convert --<fromSource> <value> --<toTarget>
```

**Command Options:**
- `--fromDecimal <decimal>` - Source: decimal odds (e.g., 1.20, 5.50)
- `--fromFraction <fraction>` - Source: fractional odds (e.g., 1/5, 9/2)
- `--fromAmerican <american>` - Source: American odds (e.g., +450, -500)
- `--fromProbability <probability>` - Source: implied probability (e.g., 83.3, 18.2)

**Target Options:**
- `--toDecimal` - Convert to decimal odds
- `--toFraction` - Convert to fractional odds  
- `--toAmerican` - Convert to American odds
- `--toProbability` - Convert to implied probability

### Examples

#### **Complete Conversion Matrix Examples**

```bash
# === DECIMAL CONVERSIONS (4 combinations) ===
./convert --fromDecimal 1.20 --toDecimal      # → 1.2 (identity)
./convert --fromDecimal 1.20 --toFraction     # → 1/5
./convert --fromDecimal 1.20 --toAmerican     # → -500
./convert --fromDecimal 1.20 --toProbability  # → 83.3%

# === FRACTION CONVERSIONS (4 combinations) ===
./convert --fromFraction 1/5 --toDecimal      # → 1.2
./convert --fromFraction 6/9 --toFraction     # → 2/3 (simplified)
./convert --fromFraction 1/5 --toAmerican     # → -500
./convert --fromFraction 1/5 --toProbability  # → 83.3%

# === AMERICAN CONVERSIONS (4 combinations) ===
./convert --fromAmerican -500 --toDecimal     # → 1.2
./convert --fromAmerican -500 --toFraction    # → 1/5
./convert --fromAmerican 450 --toAmerican     # → +450 (formatted)
./convert --fromAmerican -500 --toProbability # → 83.3%

# === PROBABILITY CONVERSIONS (4 combinations) ===
./convert --fromProbability 83.3 --toDecimal     # → 1.2
./convert --fromProbability 25.0 --toFraction    # → 3/1
./convert --fromProbability 83.3 --toAmerican    # → -499
./convert --fromProbability 50.0 --toProbability # → 50.0% (formatted)
```

#### **Common Use Cases**

```bash
# Convert favorite odds (< 2.0 decimal = negative American)
./convert --fromDecimal 1.50 --toAmerican     # → -200
./convert --fromAmerican -200 --toProbability # → 66.7%

# Convert underdog odds (≥ 2.0 decimal = positive American) 
./convert --fromDecimal 3.00 --toAmerican     # → +200
./convert --fromFraction 2/1 --toProbability  # → 33.3%

# Simplify complex fractions
./convert --fromFraction 15/25 --toFraction   # → 3/5
./convert --fromFraction 100/50 --toDecimal   # → 3.0

# Work with probabilities
./convert --fromProbability 20 --toDecimal    # → 5.0
./convert --fromProbability 25 --toFraction   # → 3/1
```

### **Comprehensive Demo Script**

Run `./demo.sh` to see all 16 conversion combinations using equivalent values:

```bash
./demo.sh
```

This script demonstrates the complete conversion matrix using:
- **Decimal: 1.20** ↔ **Fractional: 1/5** ↔ **American: -500** ↔ **Probability: 83.3%**


## Conversion Formulas

### Implied Probability
- **From Decimal**: `(1 / decimal odds) × 100`
- **From Fractional**: `denominator / (denominator + numerator) × 100`
- **From Positive American**: `100 / (american odds + 100) × 100`
- **From Negative American**: `|american odds| / (|american odds| + 100) × 100`

### Between Formats
- **Decimal ↔ Fractional**: `decimal = 1 + (numerator/denominator)`
- **American**: Positive for underdogs (≥2.0 decimal), negative for favorites (<2.0 decimal)
- **Probability ↔ Decimal**: `decimal = 1 / (probability/100)`
- **Probability ↔ American**: Convert via decimal odds as intermediate step

## Test Suites

### Library Tests (`./test-oddslib`)
- ✅ **Core conversion testing** (20 test cases)
- ✅ **Command-line parsing** (3 test cases)  
- ✅ **Error handling** validation
- ✅ **All 16 conversion combinations** verified

### Integration Tests (`./test-main`) 
- ✅ **CLI interface testing** (6 test cases)
- ✅ **End-to-end functionality** validation
- ✅ **Error message** verification

**Total: 29 tests covering complete functionality**

## Architecture Benefits

### Clean Modular Design:
- ✅ **Separation of concerns** - Library logic separated from application entry point
- ✅ **Reusable library** - `OddsLib` can be imported by other projects
- ✅ **Maintainable code** - All conversion logic in focused modules
- ✅ **Type safety** - Leverages Haskell's type system effectively
- ✅ **Comprehensive testing** - Both unit and integration test coverage

### Testing Strategy:
- **Unit Tests** (`TestOddsLib.hs`) - Test core conversion logic directly
- **Integration Tests** (`TestMain.hs`) - Test full CLI functionality end-to-end

## Quick Reference

### Identity/Formatting Conversions
```bash
./convert --fromDecimal 1.20 --toDecimal      # Validate decimal odds
./convert --fromFraction 6/9 --toFraction     # Simplify to 2/3
./convert --fromAmerican 450 --toAmerican     # Format to +450
./convert --fromProbability 50.0 --toProbability # Format probability
```

### Common Odds Examples
| **Event** | **Decimal** | **Fractional** | **American** | **Probability** |
|-----------|-------------|----------------|--------------|-----------------|
| Coin flip | 2.00 | 1/1 (evens) | +100 | 50.0% |
| Heavy favorite | 1.20 | 1/5 | -500 | 83.3% |
| Slight favorite | 1.50 | 1/2 | -200 | 66.7% |
| Slight underdog | 3.00 | 2/1 | +200 | 33.3% |
| Long shot | 5.50 | 9/2 | +450 | 18.2% |

### Error Handling
- Decimal odds must be > 1.0
- Probability must be between 0% and 100% (exclusive)
- Fractions cannot have zero denominator
- American odds cannot be zero

## Requirements

- GHC (Glasgow Haskell Compiler)
- Standard Haskell libraries (System.Environment, Text.Read)




