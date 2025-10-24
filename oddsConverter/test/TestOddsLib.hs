-- | Test suite for OddsLib module
import System.FilePath ((</>))
import System.Environment (withArgs)
import OddsLib
import System.Exit (exitFailure, exitSuccess)

-- Simple test framework
data TestResult = Pass | Fail String deriving (Show, Eq)

runTest :: String -> Bool -> TestResult
runTest _ True = Pass
runTest name False = Fail name

-- Test all conversion functions
testAllConversions :: [TestResult]
testAllConversions = 
    [ -- Decimal conversions
      runTest "Decimal to decimal identity" (convertDecimalToDecimal "1.20" == Just "1.2")
    , runTest "Decimal 1.20 to fraction 1/5" (convertDecimalToFraction "1.20" == Just "1/5")
    , runTest "Decimal 1.20 to American -500" (convertDecimalToAmerican "1.20" == Just "-500")
    , runTest "Decimal 5.50 to probability 18.2%" (convertDecimalToProbability "5.50" == Just "18.2")
    
    -- Fraction conversions
    , runTest "Fraction 1/5 to decimal 1.2" (convertFractionToDecimal "1/5" == Just "1.2")
    , runTest "Fraction 6/9 simplified to 2/3" (convertFractionToFraction "6/9" == Just "2/3")
    , runTest "Fraction 1/5 to American -500" (convertFractionToAmerican "1/5" == Just "-500")
    , runTest "Fraction 1/5 to probability 83.3%" (convertFractionToProbability "1/5" == Just "83.3")
    
    -- American conversions
    , runTest "American -500 to decimal 1.2" (convertAmericanToDecimal "-500" == Just "1.2")
    , runTest "American -500 to fraction 1/5" (convertAmericanToFraction "-500" == Just "1/5")
    , runTest "American 450 formatted to +450" (convertAmericanToAmerican "450" == Just "+450")
    , runTest "American -500 to probability 83.3%" (convertAmericanToProbability "-500" == Just "83.3")
    
    -- Probability conversions
    , runTest "Probability 50.0% to decimal 2.0" (convertProbabilityToDecimal "50.0" == Just "2.0")
    , runTest "Probability 25.0% to fraction 3/1" (convertProbabilityToFraction "25.0" == Just "3/1")
    , runTest "Probability 50.0% to American +100" (convertProbabilityToAmerican "50.0" == Just "+100")
    , runTest "Probability 50.0% formatted" (convertProbabilityToProbability "50.0" == Just "50.0")
    
    -- Error cases
    , runTest "Invalid decimal odds" (convertDecimalToDecimal "0.5" == Nothing)
    , runTest "Invalid fraction" (convertFractionToDecimal "1/0" == Nothing)
    , runTest "Invalid American odds" (convertAmericanToDecimal "0" == Nothing)
    , runTest "Invalid probability" (convertProbabilityToDecimal "100" == Nothing)
    ]

-- Test command-line parsing
testArgParsing :: [TestResult]
testArgParsing = 
    [ runTest "Parse decimal to fraction" 
        (case parseArgs ["convert", "--fromDecimal", "1.20", "--toFraction"] of
            Just (ConversionRequest DecimalToFraction "1.20") -> True
            _ -> False)
    , runTest "Parse probability to American"
        (case parseArgs ["convert", "--fromProbability", "83.3", "--toAmerican"] of
            Just (ConversionRequest ProbabilityToAmerican "83.3") -> True
            _ -> False)
    , runTest "Parse invalid arguments"
        (parseArgs ["invalid"] == Nothing)
    ]

-- Run all tests
main :: IO ()
main = do
    putStrLn "Running OddsLib Test Suite..."
    putStrLn ""
    
    putStrLn "=== CONVERSION TESTS ==="
    let conversionResults = testAllConversions
    let conversionPassed = length $ filter (== Pass) conversionResults
    mapM_ printTestResult conversionResults
    putStrLn $ "\nConversion tests: " ++ show conversionPassed ++ "/" ++ show (length conversionResults) ++ " passed"
    putStrLn ""
    
    putStrLn "=== ARGUMENT PARSING TESTS ==="
    let parsingResults = testArgParsing
    let parsingPassed = length $ filter (== Pass) parsingResults
    mapM_ printTestResult parsingResults
    putStrLn $ "\nParsing tests: " ++ show parsingPassed ++ "/" ++ show (length parsingResults) ++ " passed"
    putStrLn ""
    
    let totalPassed = conversionPassed + parsingPassed
    let totalTests = length conversionResults + length parsingResults
    
    putStrLn "==============================="
    putStrLn $ "TOTAL RESULTS: " ++ show totalPassed ++ "/" ++ show totalTests ++ " tests passed"
    
    if totalPassed == totalTests
        then do
            putStrLn "[SUCCESS] All OddsLib tests PASSED!"
            exitSuccess
        else do
            putStrLn "[ERROR] Some tests FAILED:"
            let failures = filter (/= Pass) (conversionResults ++ parsingResults)
            mapM_ printFailure failures
            exitFailure

-- Print individual test result
printTestResult :: TestResult -> IO ()
printTestResult Pass = putStr "[PASS] "
printTestResult (Fail name) = putStr $ "[FAIL] " ++ name ++ " "

-- Print failure details
printFailure :: TestResult -> IO ()
printFailure (Fail name) = putStrLn $ "  - " ++ name
printFailure Pass = return ()