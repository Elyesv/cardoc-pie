/*
  # Création de la table des entretiens

  1. Nouvelle Table
    - `maintenances`
      - `id` (uuid, clé primaire)
      - `vehicle_id` (uuid, clé étrangère vers vehicles)
      - `date` (date)
      - `mileage` (integer)
      - `description` (text)
      - `cost` (numeric)
      - `garage` (text)
      - `type` (text)
      - `invoices` (text[])
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Sécurité
    - Active RLS sur la table `maintenances`
    - Ajoute des politiques pour:
      - Lecture des entretiens par le propriétaire du véhicule
      - Création d'entretiens par le propriétaire du véhicule
      - Mise à jour d'entretiens par le propriétaire du véhicule
      - Suppression d'entretiens par le propriétaire du véhicule
*/

-- Création de la table des entretiens
CREATE TABLE maintenances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid REFERENCES vehicles(id) ON DELETE CASCADE NOT NULL,
  date date NOT NULL,
  mileage integer NOT NULL,
  description text NOT NULL,
  cost numeric(10,2) NOT NULL,
  garage text NOT NULL,
  type text NOT NULL,
  invoices text[] DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Active RLS
ALTER TABLE maintenances ENABLE ROW LEVEL SECURITY;

-- Politiques de sécurité
CREATE POLICY "Users can view their vehicle maintenances"
  ON maintenances
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM vehicles
      WHERE vehicles.id = maintenances.vehicle_id
      AND vehicles.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create maintenances for their vehicles"
  ON maintenances
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM vehicles
      WHERE vehicles.id = maintenances.vehicle_id
      AND vehicles.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their vehicle maintenances"
  ON maintenances
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM vehicles
      WHERE vehicles.id = maintenances.vehicle_id
      AND vehicles.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM vehicles
      WHERE vehicles.id = maintenances.vehicle_id
      AND vehicles.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their vehicle maintenances"
  ON maintenances
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM vehicles
      WHERE vehicles.id = maintenances.vehicle_id
      AND vehicles.user_id = auth.uid()
    )
  );

-- Trigger pour mettre à jour updated_at
CREATE TRIGGER update_maintenances_updated_at
  BEFORE UPDATE ON maintenances
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();