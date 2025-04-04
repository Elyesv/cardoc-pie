/*
  # Ajout de la politique de suppression des véhicules

  1. Sécurité
    - Ajoute une politique permettant aux utilisateurs de supprimer leurs propres véhicules
*/

-- Politique pour permettre aux utilisateurs de supprimer leurs propres véhicules
CREATE POLICY "Users can delete their own vehicles"
  ON vehicles
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);