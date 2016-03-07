module Lib
    ( someFunc
    ) where

import Foo.First
import Foo.Second

someFunc :: IO ()
someFunc = putStrLn "someFunc"
