{-# LANGUAGE FlexibleContexts #-}
{-# OPTIONS_GHC -fcontext-stack=22 #-}
module Main (main) where

import Control.Applicative
import Control.Monad
import Control.Monad.ST
import Criterion
import Criterion.Main (defaultMain)

import Data.Array.ST
import Data.Tuple.ITuple
import Data.Tuple.ST
import Data.Var.ST

main :: IO ()
main = defaultMain
       [ bench "tuples" $ nf tuples 70000
       , bench "vars" $ nf vars 70000
       , bench "arrays" $ nf arrays 70000
       ]

data Tuple7 s a b c d e f g =
  Tuple7
  {-# UNPACK #-} !(STVar s a)
  {-# UNPACK #-} !(STVar s b)
  {-# UNPACK #-} !(STVar s c)
  {-# UNPACK #-} !(STVar s d)
  {-# UNPACK #-} !(STVar s e)
  {-# UNPACK #-} !(STVar s f)
  {-# UNPACK #-} !(STVar s g)

vars :: Int -> [(Int, Int, Int, Int, Int, Int, Int)]
vars n = runST $ do
  vs <- replicateM (n `div` 7) $
    Tuple7
    <$> newSTVar n
    <*> newSTVar n
    <*> newSTVar n
    <*> newSTVar n
    <*> newSTVar n
    <*> newSTVar n
    <*> newSTVar n
  let n' = n + 1
  forM_ vs $ \ (Tuple7 a b c d e f g) -> do
    writeVar a n'
    writeVar b n'
    writeVar c n'
    writeVar d n'
    writeVar e n'
    writeVar f n'
    writeVar g n'
  forM vs $ \ (Tuple7 a b c d e f g) ->
    (,,,,,,)
    <$> readVar a
    <*> readVar b
    <*> readVar c
    <*> readVar d
    <*> readVar e
    <*> readVar f
    <*> readVar g

newSTVar :: a -> ST s (STVar s a)
newSTVar = newVar

tuples :: Int -> [(Int, Int, Int, Int, Int, Int, Int)]
tuples n = runST $ do
  vs <- replicateM (n `div` 7) $ newSTTuple (n, n, n, n, n, n, n)
  let n' = n + 1
  forM_ vs $ \ v -> do
    write1 v n'
    write2 v n'
    write3 v n'
    write4 v n'
    write5 v n'
    write6 v n'
    write7 v n'
  forM vs $ \ v ->
    (,,,,,,)
    <$> read1 v
    <*> read2 v
    <*> read3 v
    <*> read4 v
    <*> read5 v
    <*> read6 v
    <*> read7 v

newSTTuple :: (ITuple a, ArraySlice (Tuple (ListRep a))) => a -> ST s (STTuple s a)
newSTTuple = thawTuple

arrays :: Int -> [(Int, Int, Int, Int, Int, Int, Int)]
arrays n = runST $ do
  vs <- replicateM (n `div` 7) $ newSTArray (1 :: Int, 7) n
  let n' = n + 1
  forM_ vs $ \ v -> do
    writeArray v 1 n'
    writeArray v 2 n'
    writeArray v 3 n'
    writeArray v 4 n'
    writeArray v 5 n'
    writeArray v 6 n'
    writeArray v 7 n'
  forM vs $ \ v ->
    (,,,,,,)
    <$> readArray v 1
    <*> readArray v 2
    <*> readArray v 3
    <*> readArray v 4
    <*> readArray v 5
    <*> readArray v 6
    <*> readArray v 7

newSTArray :: (Ix i, MArray (STArray s) e (ST s)) => (i, i) -> e -> ST s (STArray s i e)
newSTArray = newArray
