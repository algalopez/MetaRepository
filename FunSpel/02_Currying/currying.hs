
-- Loading and executing in interactive mode
-- ghci currying.hs
-- *Main> suma 2 3
--
-- Reload a changed module
-- :reload
--
-- Show function signature
-- :info <variable name>

add :: Int -> Int -> Int
add x y = x + y

multiply :: Int -> Int -> Int
multiply x y = x * y

sumAndMultiply:: Int -> Int -> Int -> Int
sumAndMultiply a b c = multiply (add a b) c

-- let multiplyBy11 = sumAndMultiply 7 4
-- multiplyBy11 3
