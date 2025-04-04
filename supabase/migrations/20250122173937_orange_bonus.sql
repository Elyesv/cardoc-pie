/*
  # Update insurance policies table

  1. Changes
    - Make policy_number optional
    - Add end_date column for better tracking
*/

ALTER TABLE insurance_policies
ALTER COLUMN policy_number DROP NOT NULL;

-- Add end_date column
ALTER TABLE insurance_policies
ADD COLUMN IF NOT EXISTS end_date date;

-- Add function to automatically set end_date
CREATE OR REPLACE FUNCTION set_insurance_end_date()
RETURNS TRIGGER AS $$
BEGIN
  NEW.end_date := (NEW.start_date + interval '1 year')::date;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to set end_date automatically
DROP TRIGGER IF EXISTS set_insurance_end_date_trigger ON insurance_policies;
CREATE TRIGGER set_insurance_end_date_trigger
  BEFORE INSERT OR UPDATE OF start_date
  ON insurance_policies
  FOR EACH ROW
  EXECUTE FUNCTION set_insurance_end_date();