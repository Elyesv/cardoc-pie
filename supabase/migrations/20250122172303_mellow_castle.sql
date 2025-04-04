/*
  # Ajout des nouvelles fonctionnalités

  1. Nouvelles Tables
    - `fuel_logs` : Suivi de la consommation de carburant
    - `documents` : Stockage des documents (factures, carte grise, etc.)
    - `insurance_policies` : Gestion des assurances
    - `technical_inspections` : Suivi des contrôles techniques
    - `vehicle_shares` : Partage de véhicules entre utilisateurs
    - `maintenance_reminders` : Rappels d'entretien

  2. Sécurité
    - RLS activé sur toutes les tables
    - Politiques pour l'accès propriétaire et partagé
*/

-- Table pour le suivi de la consommation de carburant
CREATE TABLE fuel_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid REFERENCES vehicles(id) ON DELETE CASCADE,
  date date NOT NULL,
  mileage integer NOT NULL,
  quantity numeric(10,2) NOT NULL,
  cost numeric(10,2) NOT NULL,
  fuel_type text NOT NULL,
  station text,
  full_tank boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table pour les documents
CREATE TABLE documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid REFERENCES vehicles(id) ON DELETE CASCADE,
  name text NOT NULL,
  type text NOT NULL, -- 'registration', 'insurance', 'technical_inspection', 'invoice'
  file_url text NOT NULL,
  expiry_date date,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table pour les polices d'assurance
CREATE TABLE insurance_policies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid REFERENCES vehicles(id) ON DELETE CASCADE,
  provider text NOT NULL,
  policy_number text NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  cost numeric(10,2) NOT NULL,
  type text NOT NULL, -- 'liability', 'comprehensive', 'third_party'
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table pour les contrôles techniques
CREATE TABLE technical_inspections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid REFERENCES vehicles(id) ON DELETE CASCADE,
  date date NOT NULL,
  expiry_date date NOT NULL,
  center text NOT NULL,
  cost numeric(10,2) NOT NULL,
  status text NOT NULL, -- 'pass', 'fail', 'conditional_pass'
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table pour le partage de véhicules
CREATE TABLE vehicle_shares (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid REFERENCES vehicles(id) ON DELETE CASCADE,
  owner_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  shared_with_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  permissions jsonb NOT NULL DEFAULT '{"read": true, "write": false, "manage": false}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(vehicle_id, shared_with_id)
);

-- Table pour les rappels d'entretien
CREATE TABLE maintenance_reminders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid REFERENCES vehicles(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  due_date date NOT NULL,
  due_mileage integer,
  priority text NOT NULL, -- 'low', 'medium', 'high'
  status text NOT NULL DEFAULT 'pending', -- 'pending', 'completed', 'overdue'
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Activer RLS sur toutes les tables
ALTER TABLE fuel_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE insurance_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE technical_inspections ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicle_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_reminders ENABLE ROW LEVEL SECURITY;

-- Politiques pour fuel_logs
CREATE POLICY "Users can manage their own fuel logs"
  ON fuel_logs
  USING (
    EXISTS (
      SELECT 1 FROM vehicles v
      LEFT JOIN vehicle_shares vs ON v.id = vs.vehicle_id
      WHERE v.id = fuel_logs.vehicle_id
      AND (v.user_id = auth.uid() OR vs.shared_with_id = auth.uid())
    )
  );

-- Politiques pour documents
CREATE POLICY "Users can manage their own documents"
  ON documents
  USING (
    EXISTS (
      SELECT 1 FROM vehicles v
      LEFT JOIN vehicle_shares vs ON v.id = vs.vehicle_id
      WHERE v.id = documents.vehicle_id
      AND (v.user_id = auth.uid() OR vs.shared_with_id = auth.uid())
    )
  );

-- Politiques pour insurance_policies
CREATE POLICY "Users can manage their own insurance policies"
  ON insurance_policies
  USING (
    EXISTS (
      SELECT 1 FROM vehicles v
      LEFT JOIN vehicle_shares vs ON v.id = vs.vehicle_id
      WHERE v.id = insurance_policies.vehicle_id
      AND (v.user_id = auth.uid() OR vs.shared_with_id = auth.uid())
    )
  );

-- Politiques pour technical_inspections
CREATE POLICY "Users can manage their own technical inspections"
  ON technical_inspections
  USING (
    EXISTS (
      SELECT 1 FROM vehicles v
      LEFT JOIN vehicle_shares vs ON v.id = vs.vehicle_id
      WHERE v.id = technical_inspections.vehicle_id
      AND (v.user_id = auth.uid() OR vs.shared_with_id = auth.uid())
    )
  );

-- Politiques pour vehicle_shares
CREATE POLICY "Users can manage their own vehicle shares"
  ON vehicle_shares
  USING (owner_id = auth.uid());

-- Politiques pour maintenance_reminders
CREATE POLICY "Users can manage their own maintenance reminders"
  ON maintenance_reminders
  USING (
    EXISTS (
      SELECT 1 FROM vehicles v
      LEFT JOIN vehicle_shares vs ON v.id = vs.vehicle_id
      WHERE v.id = maintenance_reminders.vehicle_id
      AND (v.user_id = auth.uid() OR vs.shared_with_id = auth.uid())
    )
  );

-- Triggers pour updated_at
CREATE TRIGGER update_fuel_logs_updated_at
  BEFORE UPDATE ON fuel_logs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documents_updated_at
  BEFORE UPDATE ON documents
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_insurance_policies_updated_at
  BEFORE UPDATE ON insurance_policies
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_technical_inspections_updated_at
  BEFORE UPDATE ON technical_inspections
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vehicle_shares_updated_at
  BEFORE UPDATE ON vehicle_shares
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_maintenance_reminders_updated_at
  BEFORE UPDATE ON maintenance_reminders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();