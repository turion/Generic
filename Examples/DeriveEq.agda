module Generic.Examples.DeriveEq where

open import Generic.Main
open import Generic.Property.Eq
open import Generic.Function.Elim

open import Data.Vec as Vec using (Vec) renaming ([] to []ᵥ; _∷_ to _∷ᵥ_)

module DeriveEqVec where
  module _ where
    private
      Vec′ : TypeOf Vec
      Vec′ = readData Vec

    unquoteDecl foldVec = deriveFoldTo foldVec (quote Vec)

    VecInj : ∀ {n α} {A : Set α} -> Vec A n ↦ Vec′ A n
    VecInj {A = A} = record { R } where
      module R where
        to : ∀ {n} -> Vec A n -> Vec′ A n
        to = gcoerce foldVec

        from : ∀ {n} -> Vec′ A n -> Vec A n
        from xs = uncoerce xs

        from-to : ∀ {n} -> from ∘ to ≗ id {A = Vec A n}
        from-to  []ᵥ      = refl
        from-to (x ∷ᵥ xs) = cong (_ ∷ᵥ_) (from-to xs)

  instance
    VecEq : ∀ {n α} {A : Set α} {{aEq : Eq A}} -> Eq (Vec A n)
    VecEq = viaInj VecInj

  xs : Vec ℕ 3
  xs = 2 ∷ᵥ 4 ∷ᵥ 1 ∷ᵥ []ᵥ

  test : xs ≟ xs ≡ yes refl
  test = refl

  module _ where
    private open module Dummy {n α A} = _↦_ (VecInj {n} {α} {A})

    elimVec : ∀ {n α π} {A : Set α}
            -> (P : ∀ {n} -> Vec A n -> Set π)
            -> (∀ {n} {xs : Vec A n} x -> P xs -> P (x ∷ᵥ xs))
            -> P []ᵥ
            -> (xs : Vec A n)
            -> P xs
    elimVec P f z xs = subst P (from-to xs)
                     $ elim (P ∘ from) (lift z , λ x r -> lift (f x r)) (to xs)

module DeriveEqD where
  data D {α β} (A : Set α) (B : A -> Set β) : ∀ {n x} -> Vec (B x) n -> ℕ -> Set (α ⊔ β) where
    c₁ : ∀ {x n} (ys : Vec (B x) n) m -> A -> D A B ys m
    c₂ : ∀ {x n m y} {ys zs : Vec (B x) n}
       -> D A B (y ∷ᵥ ys) 0 -> D A B ys (suc n) -> Vec A m -> D A B zs n

  private
    D′ : TypeOf D
    D′ = readData D

    unquoteDecl foldD = deriveFoldTo foldD (quote D)

  --   module _ {α β} {A : Set α} {B : A -> Set β} where
  --     DInj : ∀ {n m x} {ys : Vec (B x) n} -> D A B ys m ↦ D′ A B ys m
  --     DInj = record
  --       { to      = gcoerce foldD
  --       ; from    = λ d -> uncoerce d
  --       ; from-to = {!!}
  --       }

    module _ {α β} {A : Set α} {B : A -> Set β} where
      DInj : ∀ {n m x} {ys : Vec (B x) n} -> D A B ys m ↦ D′ A B ys m
      DInj = record { R } where
        module R where
          -- For tests.
          -- to : ∀ {n m x} {ys : Vec (B x) n} -> D A B ys m -> D′ A B ys m
          -- to = foldD (D′ A B) (readCons c₁) (readCons c₂)

          to : ∀ {n m x} {ys : Vec (B x) n} -> D A B ys m -> D′ A B ys m
          to = gcoerce foldD

          from : ∀ {n m x} {ys : Vec (B x) n} -> D′ A B ys m -> D A B ys m
          from d = uncoerce d

          from-to : ∀ {n m x} {ys : Vec (B x) n} -> from ∘ to ≗ id {A = D A B ys m}
          from-to (c₁ ys m x) = refl
          from-to (c₂ d e xs) = cong₂ (λ d e -> c₂ d e xs) (from-to d) (from-to e)

  -- `VecEq` is in scope.
  instance
    DEq : ∀ {α β} {A : Set α} {B : A -> Set β} {n m x} {ys : Vec (B x) n}
            {{aEq : Eq A}} {{bEq : ∀ {x} -> Eq (B x)}} -> Eq (D A B ys m)
    DEq = viaInj DInj
