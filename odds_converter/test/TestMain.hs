-- | Integration tests for Main module CLI functionality
import System.Process
import System.Exit
import Control.Exception (try, IOException)
import System.IO.Unsafe (unsafePerformIO)

-- Simple test framework
data TestResult = Pass | Fail String deriving (Show, Eq)

runTest :: String -> Bool -> TestResult
runTest _ True = Pass
runTest name False = Fail name

-- Test the CLI executable directly
testCLI :: String -> [String] -> String -> TestResult
testCLI testName args expectedOutput =
    case unsafePerformIO (runCLITest args) of
        Just output -> runTest testName (expectedOutput `elem` lines output)
        Nothing -> Fail testName
  where
    -- Note: This is a simplified approach for testing
    -- In production, you'd want more sophisticated process handling
    runCLITest :: [String] -> IO (Maybe String)
    runCLITest cmdArgs = do
        result <- try $ readProcess "./convert" cmdArgs ""
        case result of
            Left (_ :: IOException) -> return Nothing
            Right output -> return (Just output)

-- Note: unsafePerformIO is imported above for testing purposes only

-- Test Main module functionality
testMainModule :: [TestResult]  
testMainModule =
    [ -- Basic conversion tests
      runTest "CLI decimal to fraction conversion" 
        (case unsafePerformIO (runCLICommand ["--fromDecimal", "2.5", "--toFraction"]) of
            Just output -> "Converting decimal odds 2.5 to fractional odds: 3/2" `elem` lines output
            Nothing -> False)
    , runTest "CLI fraction to decimal conversion"
        (case unsafePerformIO (runCLICommand ["--fromFraction", "1/2", "--toDecimal"]) of
            Just output -> "Converting fractional odds 1/2 to decimal odds: 1.5" `elem` lines output
            Nothing -> False)
    , runTest "CLI American odds conversion"
        (case unsafePerformIO (runCLICommand ["--fromAmerican", "+200", "--toDecimal"]) of
            Just output -> "Converting American odds +200 to decimal odds: 3.0" `elem` lines output
            Nothing -> False)
    , runTest "CLI probability conversion"
        (case unsafePerformIO (runCLICommand ["--fromProbability", "50.0", "--toDecimal"]) of
            Just output -> "Converting probability 50.0% to decimal odds: 2.0" `elem` lines output
            Nothing -> False)
    -- Error handling tests
    , runTest "CLI invalid arguments show usage"
        (case unsafePerformIO (runCLICommand ["--invalid"]) of
            Just output -> "Usage:" `elem` words output
            Nothing -> False)
    , runTest "CLI no arguments show usage"
        (case unsafePerformIO (runCLICommand []) of
            Just output -> "Usage:" `elem` words output
            Nothing -> False)
    ]
  where
    runCLICommand :: [String] -> IO (Maybe String)
    runCLICommand args = do
        result <- try $ readProcess "./convert" args ""
        case result of
            Left (_ :: IOException) -> return Nothing  
            Right output -> return (Just output)

-- Run all tests
main :: IO ()
main = do
    putStrLn "Running Main Module Integration Tests..."
    putStrLn ""
    putStrLn "NOTE: These tests require the './convert' executable to be built first."
    putStrLn "Run './build.sh' if you haven't already."
    putStrLn ""
    
    putStrLn "=== CLI INTEGRATION TESTS ==="
    let mainResults = testMainModule
    let mainPassed = length $ filter (== Pass) mainResults
    mapM_ printTestResult mainResults
    putStrLn $ "\nCLI tests: " ++ show mainPassed ++ "/" ++ show (length mainResults) ++ " passed"
    putStrLn ""
    
    putStrLn "==============================="
    putStrLn $ "TOTAL RESULTS: " ++ show mainPassed ++ "/" ++ show (length mainResults) ++ " tests passed"
    
    if mainPassed == length mainResults
        then do
            putStrLn "[SUCCESS] All Main module integration tests PASSED!"
            exitSuccess
        else do
            putStrLn "[ERROR] Some integration tests FAILED:"
            let failures = filter (/= Pass) mainResults
            mapM_ printFailure failures
            putStrLn ""
            putStrLn "Make sure the './convert' executable is built and working properly."
            exitFailure

-- Print individual test result
printTestResult :: TestResult -> IO ()
printTestResult Pass = putStr "[PASS] "
printTestResult (Fail name) = putStr $ "[FAIL] " ++ name ++ " "

-- Print failure details
printFailure :: TestResult -> IO ()
printFailure (Fail name) = putStrLn $ "  - " ++ name
printFailure Pass = return ()