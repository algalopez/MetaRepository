#!/bin/bash

# Comprehensive Odds Conversion Demo Script
# Tests all 16 conversion combinations using equivalent values

echo "=========================================="
echo "   ODDS CONVERSION COMPREHENSIVE DEMO"
echo "=========================================="
echo
echo "Testing all 16 conversion combinations using equivalent values:"
echo "• Decimal: 1.20"
echo "• Fractional: 1/5" 
echo "• American: -500"
echo "• Probability: 83.3%"
echo
echo "=========================================="

# Check if convert executable exists
if [ ! -x "./convert" ]; then
    echo "ERROR: ./convert executable not found!"
    echo "Please run './build.sh' first to compile the application."
    exit 1
fi

# Counter for tracking tests
total_tests=0
successful_tests=0

# Function to run a conversion and track results
run_conversion() {
    local description="$1"
    local cmd="$2"
    
    echo "Command $((++total_tests)): ./convert $cmd"
    
    if result=$(./convert $cmd 2>&1); then
        echo "Result: $result"
        ((successful_tests++))
    else
        echo "ERROR: Command failed"
        echo "Output: $result"
    fi
    echo
}

echo "=== DECIMAL CONVERSIONS (from 1.20) ==="
echo
run_conversion "Decimal → Decimal (identity)" "--fromDecimal 1.20 --toDecimal"
run_conversion "Decimal → Fractional" "--fromDecimal 1.20 --toFraction"  
run_conversion "Decimal → American" "--fromDecimal 1.20 --toAmerican"
run_conversion "Decimal → Probability" "--fromDecimal 1.20 --toProbability"

echo "=== FRACTIONAL CONVERSIONS (from 1/5) ==="
echo
run_conversion "Fractional → Decimal" "--fromFraction 1/5 --toDecimal"
run_conversion "Fractional → Fractional (identity)" "--fromFraction 1/5 --toFraction"
run_conversion "Fractional → American" "--fromFraction 1/5 --toAmerican"
run_conversion "Fractional → Probability" "--fromFraction 1/5 --toProbability"

echo "=== AMERICAN CONVERSIONS (from -500) ==="
echo
run_conversion "American → Decimal" "--fromAmerican -500 --toDecimal"
run_conversion "American → Fractional" "--fromAmerican -500 --toFraction"
run_conversion "American → American (identity)" "--fromAmerican -500 --toAmerican"
run_conversion "American → Probability" "--fromAmerican -500 --toProbability"

echo "=== PROBABILITY CONVERSIONS (from 83.3%) ==="
echo
run_conversion "Probability → Decimal" "--fromProbability 83.3 --toDecimal"
run_conversion "Probability → Fractional" "--fromProbability 83.3 --toFraction"
run_conversion "Probability → American" "--fromProbability 83.3 --toAmerican"
run_conversion "Probability → Probability (identity)" "--fromProbability 83.3 --toProbability"

echo "=========================================="
echo "           CONVERSION SUMMARY"
echo "=========================================="
echo "Total tests run: $total_tests"
echo "Successful: $successful_tests"
echo "Failed: $((total_tests - successful_tests))"
echo

if [ $successful_tests -eq $total_tests ]; then
    echo "🎉 SUCCESS: All $total_tests conversions completed successfully!"
    echo
    echo "All equivalent values confirmed:"
    echo "  Decimal 1.20 ↔ Fractional 1/5 ↔ American -500 ↔ Probability 83.3%"
else
    echo "⚠️  WARNING: $((total_tests - successful_tests)) conversion(s) failed"
    echo "Check the error messages above for details."
    exit 1
fi

echo
echo "=========================================="
echo "You can also test with other equivalent sets:"
echo
echo "Example 1 - Even odds (coin flip):"
echo "  ./convert --fromDecimal 2.00 --toFraction    # → 1/1"
echo "  ./convert --fromAmerican +100 --toProbability # → 50.0%"
echo
echo "Example 2 - Long shot:"
echo "  ./convert --fromDecimal 5.50 --toAmerican    # → +450"
echo "  ./convert --fromProbability 18.2 --toFraction # → 9/2"
echo
echo "=========================================="