-- Loading and executing in interactive mode
-- ghci factorial.hs
--
-- Reload a changed module
-- :reload


-- Simple with pattern matching
factorial1 :: (Integral a) => a -> a
factorial1 0 = 1
factorial1 n = n * factorial1 (n - 1)

-- Tail recursion
factorial2 :: (Eq t, Num t) => t -> t
factorial2 x = tailFactorial x 1
  where tailFactorial 0 acc = acc
        tailFactorial n acc = tailFactorial (n - 1) (n * acc)
