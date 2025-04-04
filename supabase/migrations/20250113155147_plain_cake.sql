/*
  # Ajout des colonnes manquantes à la table vehicles

  1. Nouvelles colonnes
    - `type` (text) : Type de véhicule (voiture, moto, etc.)
    - `color` (text) : Couleur du véhicule
    - `energy` (text) : Type d'énergie utilisée
    - `date_of_first_registration` (date) : Date de première mise en circulation
    - `date_of_purchase` (date) : Date d'achat
    - `number_of_owners` (integer) : Nombre de propriétaires précédents
*/

-- Ajout des colonnes manquantes
ALTER TABLE vehicles
ADD COLUMN IF NOT EXISTS type text,
ADD COLUMN IF NOT EXISTS color text,
ADD COLUMN IF NOT EXISTS energy text,
ADD COLUMN IF NOT EXISTS date_of_first_registration date,
ADD COLUMN IF NOT EXISTS date_of_purchase date,
ADD COLUMN IF NOT EXISTS number_of_owners integer DEFAULT 0;