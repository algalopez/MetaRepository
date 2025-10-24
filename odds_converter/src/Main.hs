-- | Simple main entry point for odds conversion tool
import System.Environment (getArgs)
import OddsLib

main :: IO ()
main = do
    args <- getArgs
    case parseArgs args of
        Just request -> printConversionResult request
        Nothing -> printUsage

-- | Print the result of a conversion
printConversionResult :: ConversionRequest -> IO ()
printConversionResult (ConversionRequest DecimalToDecimal val) = do
    case convertDecimalToDecimal val of
        Just result -> putStrLn $ "Decimal odds " ++ val ++ " remains: " ++ result
        Nothing -> putStrLn $ "Error: Invalid decimal odds format: " ++ val

printConversionResult (ConversionRequest DecimalToFraction val) = do
    case convertDecimalToFraction val of
        Just result -> putStrLn $ "Converting decimal odds " ++ val ++ " to fractional odds: " ++ result
        Nothing -> putStrLn $ "Error: Invalid decimal odds format: " ++ val

printConversionResult (ConversionRequest FractionToDecimal val) = do
    case convertFractionToDecimal val of
        Just result -> putStrLn $ "Converting fractional odds " ++ val ++ " to decimal odds: " ++ result
        Nothing -> putStrLn $ "Error: Invalid fractional odds format: " ++ val

printConversionResult (ConversionRequest FractionToFraction val) = do
    case convertFractionToFraction val of
        Just result -> putStrLn $ "Fractional odds " ++ val ++ " simplified: " ++ result
        Nothing -> putStrLn $ "Error: Invalid fractional odds format: " ++ val

printConversionResult (ConversionRequest DecimalToAmerican val) = do
    case convertDecimalToAmerican val of
        Just result -> putStrLn $ "Converting decimal odds " ++ val ++ " to American odds: " ++ result
        Nothing -> putStrLn $ "Error: Invalid decimal odds format: " ++ val

printConversionResult (ConversionRequest AmericanToDecimal val) = do
    case convertAmericanToDecimal val of
        Just result -> putStrLn $ "Converting American odds " ++ val ++ " to decimal odds: " ++ result
        Nothing -> putStrLn $ "Error: Invalid American odds format: " ++ val

printConversionResult (ConversionRequest FractionToAmerican val) = do
    case convertFractionToAmerican val of
        Just result -> putStrLn $ "Converting fractional odds " ++ val ++ " to American odds: " ++ result
        Nothing -> putStrLn $ "Error: Invalid fractional odds format: " ++ val

printConversionResult (ConversionRequest AmericanToFraction val) = do
    case convertAmericanToFraction val of
        Just result -> putStrLn $ "Converting American odds " ++ val ++ " to fractional odds: " ++ result
        Nothing -> putStrLn $ "Error: Invalid American odds format: " ++ val

printConversionResult (ConversionRequest AmericanToAmerican val) = do
    case convertAmericanToAmerican val of
        Just result -> putStrLn $ "American odds " ++ val ++ " formatted: " ++ result
        Nothing -> putStrLn $ "Error: Invalid American odds format: " ++ val

printConversionResult (ConversionRequest DecimalToProbability val) = do
    case convertDecimalToProbability val of
        Just result -> putStrLn $ "Converting decimal odds " ++ val ++ " to implied probability: " ++ result ++ "%"
        Nothing -> putStrLn $ "Error: Invalid decimal odds format: " ++ val

printConversionResult (ConversionRequest FractionToProbability val) = do
    case convertFractionToProbability val of
        Just result -> putStrLn $ "Converting fractional odds " ++ val ++ " to implied probability: " ++ result ++ "%"
        Nothing -> putStrLn $ "Error: Invalid fractional odds format: " ++ val

printConversionResult (ConversionRequest AmericanToProbability val) = do
    case convertAmericanToProbability val of
        Just result -> putStrLn $ "Converting American odds " ++ val ++ " to implied probability: " ++ result ++ "%"
        Nothing -> putStrLn $ "Error: Invalid American odds format: " ++ val

printConversionResult (ConversionRequest ProbabilityToDecimal val) = do
    case convertProbabilityToDecimal val of
        Just result -> putStrLn $ "Converting probability " ++ val ++ "% to decimal odds: " ++ result
        Nothing -> putStrLn $ "Error: Invalid probability format: " ++ val

printConversionResult (ConversionRequest ProbabilityToFraction val) = do
    case convertProbabilityToFraction val of
        Just result -> putStrLn $ "Converting probability " ++ val ++ "% to fractional odds: " ++ result
        Nothing -> putStrLn $ "Error: Invalid probability format: " ++ val

printConversionResult (ConversionRequest ProbabilityToAmerican val) = do
    case convertProbabilityToAmerican val of
        Just result -> putStrLn $ "Converting probability " ++ val ++ "% to American odds: " ++ result
        Nothing -> putStrLn $ "Error: Invalid probability format: " ++ val

printConversionResult (ConversionRequest ProbabilityToProbability val) = do
    case convertProbabilityToProbability val of
        Just result -> putStrLn $ "Probability " ++ val ++ "% formatted: " ++ result ++ "%"
        Nothing -> putStrLn $ "Error: Invalid probability format: " ++ val