/*
  # Ajout des fonctionnalités de carnet d'entretien digital

  1. Nouvelles Tables
    - `maintenance_intervals` : Intervalles d'entretien recommandés
    - `maintenance_tasks` : Tâches d'entretien à effectuer
    - `maintenance_recommendations` : Recommandations basées sur le kilométrage

  2. Modifications
    - Ajout de colonnes à la table `maintenances`
    - Ajout de colonnes à la table `vehicles`

  3. Relations et Contraintes
    - Clés étrangères vers vehicles
    - Contraintes de validation
*/

-- Table des intervalles d'entretien
CREATE TABLE maintenance_intervals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid REFERENCES vehicles(id) ON DELETE CASCADE,
  task_name text NOT NULL,
  kilometers integer,
  months integer,
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table des tâches d'entretien
CREATE TABLE maintenance_tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  maintenance_id uuid REFERENCES maintenances(id) ON DELETE CASCADE,
  task_name text NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CHECK (status IN ('pending', 'completed', 'skipped'))
);

-- Table des recommandations d'entretien
CREATE TABLE maintenance_recommendations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid REFERENCES vehicles(id) ON DELETE CASCADE,
  mileage_threshold integer NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  priority text NOT NULL DEFAULT 'medium',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CHECK (priority IN ('low', 'medium', 'high'))
);

-- Ajout de colonnes à la table maintenances
ALTER TABLE maintenances
ADD COLUMN IF NOT EXISTS odometer_image text,
ADD COLUMN IF NOT EXISTS parts_replaced jsonb DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS warranty_end date,
ADD COLUMN IF NOT EXISTS next_maintenance_date date,
ADD COLUMN IF NOT EXISTS next_maintenance_mileage integer;

-- Ajout de colonnes à la table vehicles
ALTER TABLE vehicles
ADD COLUMN IF NOT EXISTS fuel_capacity integer,
ADD COLUMN IF NOT EXISTS average_consumption numeric(5,2);

-- Activer RLS sur les nouvelles tables
ALTER TABLE maintenance_intervals ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_recommendations ENABLE ROW LEVEL SECURITY;

-- Politiques RLS pour maintenance_intervals
CREATE POLICY "Users can view their own maintenance intervals"
  ON maintenance_intervals FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM vehicles WHERE vehicles.id = maintenance_intervals.vehicle_id
    AND vehicles.user_id = auth.uid()
  ));

CREATE POLICY "Users can insert their own maintenance intervals"
  ON maintenance_intervals FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM vehicles WHERE vehicles.id = maintenance_intervals.vehicle_id
    AND vehicles.user_id = auth.uid()
  ));

CREATE POLICY "Users can update their own maintenance intervals"
  ON maintenance_intervals FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM vehicles WHERE vehicles.id = maintenance_intervals.vehicle_id
    AND vehicles.user_id = auth.uid()
  ));

CREATE POLICY "Users can delete their own maintenance intervals"
  ON maintenance_intervals FOR DELETE
  USING (EXISTS (
    SELECT 1 FROM vehicles WHERE vehicles.id = maintenance_intervals.vehicle_id
    AND vehicles.user_id = auth.uid()
  ));

-- Politiques RLS pour maintenance_tasks
CREATE POLICY "Users can manage their own maintenance tasks"
  ON maintenance_tasks
  USING (EXISTS (
    SELECT 1 FROM maintenances m
    JOIN vehicles v ON v.id = m.vehicle_id
    WHERE m.id = maintenance_tasks.maintenance_id
    AND v.user_id = auth.uid()
  ));

-- Politiques RLS pour maintenance_recommendations
CREATE POLICY "Users can manage their own maintenance recommendations"
  ON maintenance_recommendations
  USING (EXISTS (
    SELECT 1 FROM vehicles
    WHERE vehicles.id = maintenance_recommendations.vehicle_id
    AND vehicles.user_id = auth.uid()
  ));

-- Triggers pour updated_at
CREATE TRIGGER update_maintenance_intervals_updated_at
  BEFORE UPDATE ON maintenance_intervals
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_maintenance_tasks_updated_at
  BEFORE UPDATE ON maintenance_tasks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_maintenance_recommendations_updated_at
  BEFORE UPDATE ON maintenance_recommendations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour calculer la consommation moyenne
CREATE OR REPLACE FUNCTION calculate_average_consumption()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE vehicles v
  SET average_consumption = (
    SELECT CASE
      WHEN COUNT(*) < 2 THEN NULL
      ELSE (
        SUM(quantity) * 100.0 / NULLIF((MAX(mileage) - MIN(mileage)), 0)
      )
    END
    FROM fuel_logs f
    WHERE f.vehicle_id = v.id
    AND f.full_tank = true
  )
  WHERE v.id = NEW.vehicle_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour la consommation moyenne
CREATE TRIGGER update_average_consumption
  AFTER INSERT OR UPDATE ON fuel_logs
  FOR EACH ROW
  EXECUTE FUNCTION calculate_average_consumption();