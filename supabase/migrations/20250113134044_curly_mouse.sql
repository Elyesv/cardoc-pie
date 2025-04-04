/*
  # Initial schema for car maintenance app

  1. New Tables
    - `vehicles`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to auth.users)
      - `brand` (text)
      - `model` (text)
      - `year` (integer)
      - `license_plate` (text)
      - `mileage` (integer)
      - `image_url` (text)
      - `created_at` (timestamp with time zone)
      - `updated_at` (timestamp with time zone)

  2. Security
    - Enable RLS on `vehicles` table
    - Add policies for authenticated users to manage their own vehicles
*/

-- Create vehicles table
CREATE TABLE vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users NOT NULL,
  brand text NOT NULL,
  model text NOT NULL,
  year integer NOT NULL,
  license_plate text NOT NULL,
  mileage integer NOT NULL DEFAULT 0,
  image_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own vehicles"
  ON vehicles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own vehicles"
  ON vehicles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own vehicles"
  ON vehicles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_vehicles_updated_at
  BEFORE UPDATE ON vehicles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();