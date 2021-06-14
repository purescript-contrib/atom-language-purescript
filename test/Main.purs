{- Test file to visually assess syntax highlighting. -}
module Main.App where
module Main.App
  ( main
  ) where


import Prelude -- can comment
import Prelude hiding (div)

import Data.String as String
-- comment
import Data.String (Pattern) -- comment
import Data.String (Pattern(..), split) as String -- comment


-- multi-line import
import Data.String
  ( Pattern(..), split -- comment

  ) as String -- comment
import Something (fd)


-- Foreign import
foreign
foreign import --comment
foreign import data --comment
foreign import calculateInterest :: Number -> Number --comment
foreign import data F :: Type -> Type --comment



-- Containers


data D a = D1 a | D2 (Array a) --comment


-- some issues with proper highlighting inside parens
data D1 a
  = D1 a
  | D2 (Array Some.Type)
  | D3 (Either Aff.Error Db.Client)
  | D4
    (Array Some.Type) --comment
  | D5 String
      Int -- not proper
  | S1 (forall f. f String -> f a)


type T = { a :: String } --comment
type T a = { n :: N a, b :: String }


newtype N a = N a


data Proxy :: forall k. k -> Type
data Proxy a = Proxy


-- newtype with multi-line kind signature
newtype MySub ::
  forall k. (k -> Type) -> k -> Type --comment
newtype MySub vnode msg =
  MySub (SubRec vnode msg)


-- infix operators
infixr 0 apply as <| -- comment as <|
infixl 0 applyFlipped as |>


---
data Sum a b
  = Inl a
  | Inr b --comment


data Product a b = Product a b


-- Type operators
infixl 6 type Sum as :+: -- comment
infixl 7 type Product as :*:



-- type class signatures


class Category :: forall k. (k -> k -> Type) -> Constraint
class Semigroupoid a <= Category a where
  identity :: forall t. a t t


-- type class without where
class ListToRow :: forall k. RowList k -> Row k -> Constraint
class ListToRow list row | list -> row


class Functor v <= Mountable vnode where
  mount :: ∀ m. Element -> T Void (v m)
  unmount :: ∀ m. v m -> v m -> T Void E


--orphan keyword
class


-- multi-line type def
class Functor v
  <= Mountable vnode where --comment
  mount :: ∀ m. Element -> T Void (v m)
  unmount :: ∀ m. v m -> v m -> T Void E


instance


instance listToRowCons
  :: ( ListToRow tail tailRow
     , Row.Cons label ty tailRow row ) --comment
  => ListToRow (Cons label ty tail) row


--orphan keyword
derive
derive instance newtypeMySub :: Newtype (MySub vnode msg) _ --comment
derive newtype
derive newtype instance semiringScore :: Semiring Score


-- instance without name
derive newtype instance Semiring Score


-- multi-line derive
derive instance genericCmd
  :: Generic PhonerCmd _


-- TODO: multi-line, double-colons
derive instance genericCmd ::
  Generic PhonerCmd _


-- multi-line instance
instance encodeCmd
  :: EncodeJson PhonerCmd where --comment
  encodeJson a = genericEncodeJson a


instance functorA :: Functor A where
   map = split


instance functorA :: Functor A where
   map = split -- comment



-- chained instances


class MyShow a where
  myShow :: a -> String


instance showString :: MyShow String where
  myShow s = s


-- chained instances
else instance showBoolean :: MyShow Boolean where
  myShow true = "true" --comment
  myShow false = "false"
else  instance showA :: MyShow a where
  myShow _ = "Invalid"
else newtype instance showA :: MyShow a where



-- Records with fields that are reserved words


type Rec =
  { module :: String -- comment
  , import :: Either Error (Array String)
  -- comment
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
  , type ="type" -- comment
  , foreign = "foreign"
  , import = "import"
  , infixl = "infixl" -- comment
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


-- row type parens are not highlighted as it doesn't seem necessary
type RowLine a = ( name :: String, age :: { nested :: Number } | a )


type RowRecord a
  = Record
      ( RowLine ( some :: Either Error (Array a) )
      )


type RowRecordLine = Record ( RowLine ( some :: String ) )


type EntireRecordCodec = T "Str" ( a :: String , "B" :: Boolean)


-- quoted row type
type QuotedRow a =
  ( "A" :: Int
  -- comment
  , "B" :: { nested :: Number }
  , a :: Some.Int -- comment
  | a
  ) --som


type NotRow a = Either Error (Array Int)


-- record with quoted fields
type Quoted =
  { "A" :: Int -- comment
  , a :: Boolean
  , "B" :: Number
  , b :: Int -- comment
  , "x" :: SmallCap
  }


-- inlined type def
quoted ::
  { "A" :: Int -- comment
  , a :: Boolean
  , "B" :: Number
  , b :: Int -- comment
  , "x" :: SmallCap
  }
quoted =
  { "A": "a" -- comment
  , "B": fn (1 :: Int) x 2 -- typed param in parens
  , "C": 1 :: Int -- typed param without parens
  , a: 2
  }


-- proxy
proxy = Proxy :: Proxy Int -- k is Type


intAtFoo :: forall r. Variant (foo :: Int | r)
intAtFoo = inj (Proxy :: Proxy "foo") 42


-- typed hole
foo :: List Int -> List Int
foo = map ?myHole



-- Function, forall


-- infix functions
infixFun = 1 `add` 2


-- function declaration, do, where
toStr :: forall a. Functor a => a -> Effect Unit --comment
toStr x = do
  log $ show num
  log $ show $ 1 `add` 2
  where
  -- indented type signature
  num :: Int
  num = ((something :: Int) :: Int)
  str = "Str"


addIf true = singleton
addIf false = const []


-- double colon inside quoted string
text = (" ::" + global)


-- fn type signature without :: in the same line lacks highlighting
-- it seems to be a bit harder case for proper handling
-- maybe it's also a sign that it is better not to have it in the code :-)
fn
  -- line orphan signature
  :: forall a. a -> String
fn a =
  -- let in, case of
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


-- operators inside type signature ==>
type Schema
  = { widgets :: { id :: Int } ==> Array Widget --comment
    }



-- constants


int = 1


decimal = 41.0


hex = 0xE0


multiString = """
WOW
"""
