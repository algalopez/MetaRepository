-- | Odds conversion library with all core functionality
module OddsLib 
    ( ConversionMode(..)
    , ConversionRequest(..)
    , parseArgs
    , convertDecimalToFraction
    , convertFractionToDecimal
    , convertDecimalToAmerican
    , convertAmericanToDecimal
    , convertFractionToAmerican
    , convertAmericanToFraction
    , convertDecimalToProbability
    , convertFractionToProbability
    , convertAmericanToProbability
    , convertProbabilityToDecimal
    , convertProbabilityToFraction
    , convertProbabilityToAmerican
    , convertDecimalToDecimal
    , convertFractionToFraction
    , convertAmericanToAmerican
    , convertProbabilityToProbability
    , printUsage
    ) where

import Text.Read (readMaybe)

-- | All possible conversion modes (4x4 matrix)
data ConversionMode 
    = DecimalToDecimal | DecimalToFraction | DecimalToAmerican | DecimalToProbability
    | FractionToDecimal | FractionToFraction | FractionToAmerican | FractionToProbability
    | AmericanToDecimal | AmericanToFraction | AmericanToAmerican | AmericanToProbability
    | ProbabilityToDecimal | ProbabilityToFraction | ProbabilityToAmerican | ProbabilityToProbability
    deriving (Show, Eq)

-- | A conversion request with mode and value
data ConversionRequest = ConversionRequest
    { mode :: ConversionMode
    , value :: String
    } deriving (Show, Eq)

data TargetFormat = ToDecimal | ToFraction | ToAmerican | ToProbability

-- | Parse command-line arguments
parseArgs :: [String] -> Maybe ConversionRequest
parseArgs args = parseArgs' args Nothing Nothing
  where
    parseArgs' [] (Just mode) (Just val) = Just $ ConversionRequest mode val
    parseArgs' [] _ _ = Nothing
    parseArgs' ("convert":xs) mode val = parseArgs' xs mode val
    parseArgs' ("--fromDecimal":x:xs) _ val = 
        case parseTargetFormat xs of
            Just ToDecimal -> parseArgs' (dropTarget xs) (Just DecimalToDecimal) (Just x)
            Just ToFraction -> parseArgs' (dropTarget xs) (Just DecimalToFraction) (Just x)
            Just ToAmerican -> parseArgs' (dropTarget xs) (Just DecimalToAmerican) (Just x)
            Just ToProbability -> parseArgs' (dropTarget xs) (Just DecimalToProbability) (Just x)
            Nothing -> Nothing
    parseArgs' ("--fromFraction":x:xs) _ val = 
        case parseTargetFormat xs of
            Just ToDecimal -> parseArgs' (dropTarget xs) (Just FractionToDecimal) (Just x)
            Just ToFraction -> parseArgs' (dropTarget xs) (Just FractionToFraction) (Just x)
            Just ToAmerican -> parseArgs' (dropTarget xs) (Just FractionToAmerican) (Just x)
            Just ToProbability -> parseArgs' (dropTarget xs) (Just FractionToProbability) (Just x)
            Nothing -> Nothing
    parseArgs' ("--fromAmerican":x:xs) _ val = 
        case parseTargetFormat xs of
            Just ToDecimal -> parseArgs' (dropTarget xs) (Just AmericanToDecimal) (Just x)
            Just ToFraction -> parseArgs' (dropTarget xs) (Just AmericanToFraction) (Just x)
            Just ToAmerican -> parseArgs' (dropTarget xs) (Just AmericanToAmerican) (Just x)
            Just ToProbability -> parseArgs' (dropTarget xs) (Just AmericanToProbability) (Just x)
            Nothing -> Nothing
    parseArgs' ("--fromProbability":x:xs) _ val = 
        case parseTargetFormat xs of
            Just ToDecimal -> parseArgs' (dropTarget xs) (Just ProbabilityToDecimal) (Just x)
            Just ToFraction -> parseArgs' (dropTarget xs) (Just ProbabilityToFraction) (Just x)
            Just ToAmerican -> parseArgs' (dropTarget xs) (Just ProbabilityToAmerican) (Just x)
            Just ToProbability -> parseArgs' (dropTarget xs) (Just ProbabilityToProbability) (Just x)
            Nothing -> Nothing
    parseArgs' ("--toFraction":xs) mode val = parseArgs' xs mode val
    parseArgs' ("--toDecimal":xs) mode val = parseArgs' xs mode val
    parseArgs' ("--toAmerican":xs) mode val = parseArgs' xs mode val
    parseArgs' ("--toProbability":xs) mode val = parseArgs' xs mode val
    parseArgs' (_:xs) mode val = parseArgs' xs mode val

dropTarget :: [String] -> [String]
dropTarget ("--toDecimal":xs) = xs
dropTarget ("--toFraction":xs) = xs
dropTarget ("--toAmerican":xs) = xs
dropTarget ("--toProbability":xs) = xs
dropTarget (x:xs) = dropTarget xs
dropTarget [] = []

parseTargetFormat :: [String] -> Maybe TargetFormat
parseTargetFormat ("--toDecimal":_) = Just ToDecimal
parseTargetFormat ("--toFraction":_) = Just ToFraction
parseTargetFormat ("--toAmerican":_) = Just ToAmerican
parseTargetFormat ("--toProbability":_) = Just ToProbability
parseTargetFormat (_:xs) = parseTargetFormat xs
parseTargetFormat [] = Nothing

-- ============================================================================
-- CONVERSION FUNCTIONS
-- ============================================================================

-- Identity conversion: decimal to decimal (validation)
convertDecimalToDecimal :: String -> Maybe String
convertDecimalToDecimal str = do
    decimal <- readMaybe str :: Maybe Double
    if decimal <= 1.0
        then Nothing
        else Just (show decimal)

-- Convert decimal odds to fractional odds
convertDecimalToFraction :: String -> Maybe String
convertDecimalToFraction str = do
    decimal <- readMaybe str :: Maybe Double
    if decimal <= 1.0
        then Nothing
        else let profit = decimal - 1.0
                 fraction = simplifyFraction profit
             in Just fraction

-- Convert fractional odds to decimal odds
convertFractionToDecimal :: String -> Maybe String
convertFractionToDecimal str = do
    (numerator, denominator) <- parseFraction str
    if denominator == 0
        then Nothing
        else let decimal = 1.0 + (fromIntegral numerator / fromIntegral denominator)
             in Just (show decimal)

-- Identity conversion: fraction to fraction (simplification)
convertFractionToFraction :: String -> Maybe String
convertFractionToFraction str = do
    (numerator, denominator) <- parseFraction str
    if denominator == 0
        then Nothing
        else let simplified = simplifyRatio numerator denominator
             in Just (show (fst simplified) ++ "/" ++ show (snd simplified))

-- Convert decimal odds to American odds
convertDecimalToAmerican :: String -> Maybe String
convertDecimalToAmerican str = do
    decimal <- readMaybe str :: Maybe Double
    if decimal <= 1.0
        then Nothing
        else if decimal >= 2.0
            then Just ("+" ++ show (round ((decimal - 1.0) * 100) :: Int))
            else Just (show (round (-100.0 / (decimal - 1.0)) :: Int))

-- Convert American odds to decimal odds
convertAmericanToDecimal :: String -> Maybe String
convertAmericanToDecimal str = do
    let cleanStr = if head str == '+' then tail str else str
    american <- readMaybe cleanStr :: Maybe Int
    if american > 0
        then Just (show (1.0 + fromIntegral american / 100.0))
        else if american < 0
            then Just (show (1.0 - 100.0 / fromIntegral american))
            else Nothing

-- Convert fractional odds to American odds
convertFractionToAmerican :: String -> Maybe String
convertFractionToAmerican str = do
    decimal <- convertFractionToDecimal str
    convertDecimalToAmerican decimal

-- Convert American odds to fractional odds
convertAmericanToFraction :: String -> Maybe String
convertAmericanToFraction str = do
    decimal <- convertAmericanToDecimal str
    convertDecimalToFraction decimal

-- Identity conversion: American to American (formatting)
convertAmericanToAmerican :: String -> Maybe String
convertAmericanToAmerican str = do
    let cleanStr = if head str == '+' then tail str else str
    american <- readMaybe cleanStr :: Maybe Int
    if american > 0
        then Just ("+" ++ show american)
        else if american < 0
            then Just (show american)
            else Nothing

-- Format probability to one decimal place
formatProbability :: Double -> String
formatProbability prob = show (fromIntegral (round (prob * 10)) / (10.0 :: Double))

-- Convert decimal odds to implied probability
convertDecimalToProbability :: String -> Maybe String
convertDecimalToProbability str = do
    decimal <- readMaybe str :: Maybe Double
    if decimal <= 1.0
        then Nothing
        else let probability = (1.0 / decimal) * 100.0
             in Just (formatProbability probability)

-- Convert fractional odds to implied probability
convertFractionToProbability :: String -> Maybe String
convertFractionToProbability str = do
    (numerator, denominator) <- parseFraction str
    if denominator == 0
        then Nothing
        else let probability = (fromIntegral denominator / fromIntegral (denominator + numerator)) * 100.0
             in Just (formatProbability probability)

-- Convert American odds to implied probability
convertAmericanToProbability :: String -> Maybe String
convertAmericanToProbability str = do
    let cleanStr = if head str == '+' then tail str else str
    american <- readMaybe cleanStr :: Maybe Int
    if american > 0
        then let probability = (100.0 / (fromIntegral american + 100.0)) * 100.0
             in Just (formatProbability probability)
        else if american < 0
            then let absAmerican = fromIntegral (abs american)
                     probability = (absAmerican / (absAmerican + 100.0)) * 100.0
                 in Just (formatProbability probability)
            else Nothing

-- Convert probability to decimal odds
convertProbabilityToDecimal :: String -> Maybe String
convertProbabilityToDecimal str = do
    prob <- readMaybe str :: Maybe Double
    if prob <= 0 || prob >= 100
        then Nothing
        else let decimal = 1.0 / (prob / 100.0)
             in Just (show decimal)

-- Convert probability to fractional odds
convertProbabilityToFraction :: String -> Maybe String
convertProbabilityToFraction str = do
    decimal <- convertProbabilityToDecimal str
    convertDecimalToFraction decimal

-- Convert probability to American odds
convertProbabilityToAmerican :: String -> Maybe String
convertProbabilityToAmerican str = do
    decimal <- convertProbabilityToDecimal str
    convertDecimalToAmerican decimal

-- Identity conversion: probability to probability (formatting)
convertProbabilityToProbability :: String -> Maybe String
convertProbabilityToProbability str = do
    prob <- readMaybe str :: Maybe Double
    if prob <= 0 || prob >= 100
        then Nothing
        else Just (formatProbability prob)

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Parse fraction string like "1/5" or "3/4"
parseFraction :: String -> Maybe (Int, Int)
parseFraction str = case break (== '/') str of
    (numStr, '/':denStr) -> do
        num <- readMaybe numStr
        den <- readMaybe denStr
        return (num, den)
    _ -> Nothing

-- Simplify a decimal to its fractional representation
simplifyFraction :: Double -> String
simplifyFraction d = 
    let precision = 1000000  -- Handle up to 6 decimal places
        numerator = round (d * fromIntegral precision)
        simplified = simplifyRatio numerator precision
    in show (fst simplified) ++ "/" ++ show (snd simplified)

-- Simplify a ratio using GCD
simplifyRatio :: Int -> Int -> (Int, Int)
simplifyRatio num den = 
    let g = gcd num den
    in (num `div` g, den `div` g)

-- Print usage information
printUsage :: IO ()
printUsage = do
    putStrLn "Usage:"
    putStrLn "  convert --fromDecimal <decimal> --to[Decimal|Fraction|American|Probability]"
    putStrLn "  convert --fromFraction <fraction> --to[Decimal|Fraction|American|Probability]"
    putStrLn "  convert --fromAmerican <american> --to[Decimal|Fraction|American|Probability]"
    putStrLn "  convert --fromProbability <probability> --to[Decimal|Fraction|American|Probability]"
    putStrLn ""
    putStrLn "Examples:"
    putStrLn "  convert --fromDecimal 1.20 --toFraction"
    putStrLn "  convert --fromDecimal 5.50 --toProbability"
    putStrLn "  convert --fromFraction 9/2 --toProbability"
    putStrLn "  convert --fromAmerican +450 --toProbability"
    putStrLn "  convert --fromAmerican -500 --toDecimal"
    putStrLn "  convert --fromProbability 18.2 --toDecimal"
    putStrLn "  convert --fromProbability 83.3 --toAmerican"