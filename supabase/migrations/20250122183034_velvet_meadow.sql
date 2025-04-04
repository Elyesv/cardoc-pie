/*
  # Ajout des informations de paiement aux assurances

  1. Modifications
    - Ajout de la colonne `payment_frequency` pour stocker la fréquence de paiement (mensuel, trimestriel, annuel)
    - Ajout de la colonne `payment_day` pour stocker le jour du mois du prélèvement
  
  2. Notes
    - La colonne `payment_frequency` est de type ENUM pour garantir des valeurs valides
    - La colonne `payment_day` est limitée entre 1 et 28 pour éviter les problèmes avec les mois courts
*/

-- Créer le type ENUM pour la fréquence de paiement
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_frequency_type') THEN
    CREATE TYPE payment_frequency_type AS ENUM ('monthly', 'quarterly', 'yearly');
  END IF;
END$$;

-- Ajouter les colonnes pour les informations de paiement
ALTER TABLE insurance_policies
ADD COLUMN IF NOT EXISTS payment_frequency payment_frequency_type NOT NULL DEFAULT 'monthly',
ADD COLUMN IF NOT EXISTS payment_day integer NOT NULL DEFAULT 1
CHECK (payment_day BETWEEN 1 AND 28);

-- Mettre à jour les polices existantes avec des valeurs par défaut
UPDATE insurance_policies
SET 
  payment_frequency = 'monthly',
  payment_day = 1
WHERE payment_frequency IS NULL OR payment_day IS NULL;

-- Ajouter des commentaires pour la documentation
COMMENT ON COLUMN insurance_policies.payment_frequency IS 'Fréquence de paiement de l''assurance (mensuel, trimestriel, annuel)';
COMMENT ON COLUMN insurance_policies.payment_day IS 'Jour du mois pour le prélèvement (1-28)';