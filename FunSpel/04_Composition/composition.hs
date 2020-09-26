-- Loading and executing in interactive mode
-- ghci composition.hs
--
-- Reload a changed module
-- :reload
--
-- Notes:
-- (.)      :: (b->c) -> (a->b) -> (a->c)
-- f . g    = \ x -> f (g x)

sum1:: Integer -> Integer
sum1 x = x + 1

mult10:: Integer -> Integer
mult10 x = x * 10

composeFunctions:: Integer -> Integer
composeFunctions = \x -> (sum1.sum1.mult10) x

composeFunctions2:: Integer -> Integer
composeFunctions2 = \x -> ((+1).(+1).(*10)) x
