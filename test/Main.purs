{- Test file to visually assess syntax highlighting. -}
module Main.App where
module Main.App
  ( main
  ) where


import Prelude

import Data.String as String
import Data.String (Pattern)
import Data.String (Pattern(..), split)


-- Foreign import
foreign
foreign import
foreign import data
foreign import calculateInterest :: Number -> Number
foreign import data F :: Type


-- Containers


data D a = D1 a | D2 String


type T = { a :: String }
type T a = { n :: N a, b :: String }


newtype N a = N a


-- infix -- TODO: as


infixr 0 apply as <|
infixl 0 applyFlipped as |>


-- Type class


class Functor v <= Mountable vnode where
  mount :: ∀ m. Element -> T Void (v m)
  unmount :: ∀ m. v m -> v m -> T Void E


derive instance newtypeMySub :: Newtype (MySub vnode msg) _


derive instance genericCmd :: Generic PhonerCmd _
instance encodeCmd :: EncodeJson PhonerCmd where
  encodeJson a = genericEncodeJson a


instance functorA :: Functor A where
   map = split


instance functorA :: Functor A where
   map = split


-- chained instances


class MyShow a where
  myShow :: a -> String


instance showString :: MyShow String where
  myShow s = s


else instance showBoolean :: MyShow Boolean where
  myShow true = "true"
  myShow false = "false"
else instance showA :: MyShow a where
  myShow _ = "Invalid"


-- Records with fields that are reserved words


type Rec =
  { module :: String
  , import :: String
  , data :: String
  , newtype :: String
  }


-- https://github.com/purescript/purescript-in-purescript/blob/master/src/Language/PureScript/Keywords.purs
rec =
  { data: "data"
  , type: "type"
  , foreign: "foreign"
  , import: "import"
  , infixl: "infixl"
  , infixr: "infixr"
  , infix: "infix"
  , class: "class"
  , instance: "instance"
  , case: case some of _ -> 1
  , of: "of"
  , if: "if"
  , then: "then"
  , else: "else"
  , do: "do"
  , let: "let"
  -- no big reason to strive to make true/false not highlighted here
  , true: "true"
  , false: "false"
  , in: "in"
  , where: "where"
  , forall: "forall"
  , module: "module"
  }


updateRec = rec
  { data = "data"
  , type ="type"
  , foreign = "foreign"
  , import = "import"
  , infixl = "infixl"
  , infixr = "infixr"
  , infix = "infix"
  , class = "class"
  , instance = "instance"
  , case = case some of _ -> 1
  , of = "of"
  , if = if true then "true" else "false"
  , then = "then"
  , else = "else"
  , do = "do"
  , let = "let"
  , true = true
  , false = false
  , in = "in"
  , where = "where"
  , forall = "forall"
  , module = "module"
  }


-- quoted row type
type QuotedRow =
  ( "A" :: Int
  , "B" :: Number
  )

-- quoted record type
type Quoted =
  { "A" :: Int
  , "B" :: Number
  }


-- quoted row type
quoted =
  { "A": "a"
  , "B": 1
  }


-- Function, forall


-- do, where
toStr :: forall a. a -> Effect Unit
toStr x = do
  log $ show num
  log $ show str
  where
  num = 1
  str = "Str"


addIf true = singleton
addIf false = const []


-- let in, case of
fn
  :: forall a. a -> String
fn a =
  let b = "str"
  in case a of
    "1" -> b + "1"
    _ -> b + a


-- if' fn and if statement with
if' = if true then "false" else "true"


-- true'
true' = if false then "false" else "true"


-- false'
false' = if false then true' else "false"


case' = if true
  then if'
  else "true"


--
type Schema
  = {
    , widgets :: { id :: Int } ==> Array Widget
    }
