-- Loading and executing
-- ghc monads.hs
-- ./monads
--

speakTo :: (String -> String) -> IO String
speakTo fSentence = fmap fSentence getLine

main :: IO()
main = 
    do  
        putStrLn "Hello, what's your name?"  
        name <- speakTo (\name -> "Mr. " ++ name ++ "!")  
        putStrLn ("Hey " ++ name)  
