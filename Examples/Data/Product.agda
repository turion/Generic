module Generic.Examples.Data.Product where

open import Generic.Main as Main hiding (Σ; proj₁; proj₂) renaming (_,_ to _,′_)

infixr 4 _,_

Σ : ∀ {α β} -> (A : Set α) -> (A -> Set β) -> Set (α ⊔ β)
Σ = readData Main.Σ

pattern _,_ x y = !#₀ (x ,′ y ,′ lrefl)

proj₁ : ∀ {α β} {A : Set α} {B : A -> Set β} -> Σ A B -> A
proj₁ (x , y) = x

proj₂ : ∀ {α β} {A : Set α} {B : A -> Set β} -> (p : Σ A B) -> B (proj₁ p)
proj₂ (x , y) = y

ηo : ∀ {α β} {A : Set α} {B : A -> Set β} -> (p : Σ A B) -> p ≡ proj₁ p , proj₂ p
ηo (x , y) = refl
