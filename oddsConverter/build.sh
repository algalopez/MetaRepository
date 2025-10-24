#!/bin/bash

# Odds Conversion Tool - Build Script

echo "=== Building Odds Conversion Tool ==="
echo

echo "Compiling application..."

# Compile the application (library + main)
if ghc -isrc -o convert src/Main.hs; then
    echo "[SUCCESS] Application compiled successfully"
else
    echo "[ERROR] Failed to compile application"
    exit 1
fi

echo "Compiling test suites..."

# Compile the OddsLib test suite
if ghc -isrc -itest -o test-oddslib test/TestOddsLib.hs; then
    echo "[SUCCESS] OddsLib test suite compiled successfully"
else
    echo "[ERROR] Failed to compile OddsLib test suite"
    exit 1
fi

# Compile the Main integration test suite
if ghc -isrc -itest -o test-main test/TestMain.hs; then
    echo "[SUCCESS] Main integration test suite compiled successfully"
else
    echo "[ERROR] Failed to compile Main integration test suite"
    exit 1
fi

echo
echo "=== Running Test Suites ==="

# Run the OddsLib test suite
echo "Running OddsLib tests..."
if ./test-oddslib; then
    echo "[SUCCESS] OddsLib tests passed!"
else
    echo "[ERROR] OddsLib tests failed!"
    exit 1
fi

echo
# Run the Main integration tests
echo "Running Main integration tests..."
if ./test-main; then
    echo "[SUCCESS] Main integration tests passed!"
else
    echo "[ERROR] Main integration tests failed!"
    exit 1
fi

echo
echo "=== Manual Testing ==="

# Test a few conversions manually to demonstrate
echo "Manual Test 1: Decimal to Fraction"
./convert --fromDecimal 1.20 --toFraction

echo
echo "Manual Test 2: Probability to American"  
./convert --fromProbability 83.3 --toAmerican

echo
echo "Manual Test 3: Fraction simplification"
./convert --fromFraction 6/9 --toFraction

echo
echo "=== Build Complete ==="
echo "[SUCCESS] Your odds conversion tool is ready!"
echo
echo "Usage:"
echo "  ./convert --fromDecimal 1.20 --toFraction"
echo "  ./convert --fromProbability 50.0 --toDecimal"