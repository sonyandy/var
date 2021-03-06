{-# LANGUAGE CPP #-}
#ifdef LANGUAGE_DataKinds
{-# LANGUAGE DataKinds #-}
#endif
{-# LANGUAGE
    DeriveDataTypeable
  , FlexibleContexts
  , FlexibleInstances
  , GADTs
  , MultiParamTypeClasses #-}
#ifdef LANGUAGE_Trustworthy
{-# LANGUAGE Trustworthy #-}
#endif
{-# LANGUAGE
    TypeFamilies
  , TypeOperators #-}
{- |
Copyright   :  (c) Andy Sonnenburg 2013
License     :  BSD3
Maintainer  :  andy22286@gmail.com
-}
module Data.Tuple.Array
       ( ArrayTuple
       , ArraySlice
       ) where

import Control.Applicative
import Control.Monad.Prim

import Data.Prim.Array
import Data.Tuple.ITuple
import Data.Tuple.ITuple.Proxy
import Data.Tuple.MTuple
import Data.Typeable (Typeable)

import GHC.Exts (Any)

import Unsafe.Coerce (unsafeCoerce)

newtype ArrayTuple s a = ArrayTuple (MutableArray s Any) deriving (Eq, Typeable)

instance ( MonadPrim m
         , s ~ World m
         , ITuple t
         , ArraySlice (Tuple (ListRep t))
         ) => MTuple (ArrayTuple s) t m where
  thawTuple a = runPrim $ do
    array <- newArray (sizeOf a) undefined
    writeTuple array 0 (toTuple a)
    return $ ArrayTuple array
  freezeTuple (ArrayTuple array) = runPrim $ fromTuple <$> readTuple array 0

instance ( MonadPrim m
         , s ~ World m
         , ITuple t
         , ArraySlice (Tuple (ListRep t))
         ) => MField1 (ArrayTuple s) t m where
  read1 = unsafeRead 0
  write1 = unsafeWrite 0

instance ( MonadPrim m
         , s ~ World m
         , ITuple t
         , ArraySlice (Tuple (ListRep t))
         ) => MField2 (ArrayTuple s) t m where
  read2 = unsafeRead 1
  write2 = unsafeWrite 1

instance ( MonadPrim m
         , s ~ World m
         , ITuple t
         , ArraySlice (Tuple (ListRep t))
         ) => MField3 (ArrayTuple s) t m where
  read3 = unsafeRead 2
  write3 = unsafeWrite 2

instance ( MonadPrim m
         , s ~ World m
         , ITuple t
         , ArraySlice (Tuple (ListRep t))
         ) => MField4 (ArrayTuple s) t m where
  read4 = unsafeRead 3
  write4 = unsafeWrite 3

instance ( MonadPrim m
         , s ~ World m
         , ITuple t
         , ArraySlice (Tuple (ListRep t))
         ) => MField5 (ArrayTuple s) t m where
  read5 = unsafeRead 4
  write5 = unsafeWrite 4

instance ( MonadPrim m
         , s ~ World m
         , ITuple t
         , ArraySlice (Tuple (ListRep t))
         ) => MField6 (ArrayTuple s) t m where
  read6 = unsafeRead 5
  write6 = unsafeWrite 5

instance ( MonadPrim m
         , s ~ World m
         , ITuple t
         , ArraySlice (Tuple (ListRep t))
         ) => MField7 (ArrayTuple s) t m where
  read7 = unsafeRead 6
  write7 = unsafeWrite 6

instance ( MonadPrim m
         , s ~ World m
         , ITuple t
         , ArraySlice (Tuple (ListRep t))
         ) => MField8 (ArrayTuple s) t m where
  read8 = unsafeRead 7
  write8 = unsafeWrite 7

instance ( MonadPrim m
         , s ~ World m
         , ITuple t
         , ArraySlice (Tuple (ListRep t))
         ) => MField9 (ArrayTuple s) t m where
  read9 = unsafeRead 8
  write9 = unsafeWrite 8

sizeOf :: (ITuple t, ArraySlice (Tuple (ListRep t))) => t -> Int
sizeOf = size . proxyTuple

class ArraySlice a where
  size :: t a -> Int
  readTuple :: MutableArray s Any -> Int -> Prim s a
  writeTuple :: MutableArray s Any -> Int -> a -> Prim s ()

instance ArraySlice (Tuple Nil) where
  size _ = 0
  readTuple _ _ = return U
  writeTuple _ _ _ = return ()

instance ArraySlice (Tuple xs) => ArraySlice (Tuple (x :| xs)) where
  size xs = 1 + size (reproxyTail xs)
  readTuple array i = do
    x <- unsafeCoerce <$> readArray array i
    xs <- readTuple array (i + 1)
    return $ x :* xs
  writeTuple array i (x :* xs) = do
    writeArray array i (unsafeCoerce x)
    writeTuple array (i + 1) xs

unsafeRead :: MonadPrim m => Int -> ArrayTuple (World m) t -> m a
unsafeRead i (ArrayTuple array) = runPrim $ unsafeCoerce <$> readArray array i

unsafeWrite :: MonadPrim m => Int -> ArrayTuple (World m) t -> a -> m ()
unsafeWrite i (ArrayTuple array) = runPrim . writeArray array i . unsafeCoerce
