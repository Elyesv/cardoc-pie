/*
  # Configuration du stockage pour les images des véhicules

  1. Création
    - Bucket 'vehicle-images' pour stocker les images des véhicules (si n'existe pas déjà)
  
  2. Sécurité
    - Politique permettant aux utilisateurs authentifiés de télécharger des images (max 5MB)
    - Politique permettant à tout le monde de lire les images
    - Politique permettant aux utilisateurs de supprimer leurs propres images
*/

-- Création du bucket pour les images des véhicules
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'vehicle-images'
  ) THEN
    INSERT INTO storage.buckets (id, name, public)
    VALUES ('vehicle-images', 'vehicle-images', true);
  END IF;
END $$;

-- Politique pour permettre aux utilisateurs authentifiés de télécharger des images
DROP POLICY IF EXISTS "Users can upload vehicle images" ON storage.objects;
CREATE POLICY "Users can upload vehicle images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'vehicle-images'
  AND (octet_length(bucket_id) + octet_length(name)) < 5242880
);

-- Politique pour permettre à tout le monde de lire les images
DROP POLICY IF EXISTS "Anyone can view vehicle images" ON storage.objects;
CREATE POLICY "Anyone can view vehicle images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'vehicle-images');

-- Politique pour permettre aux utilisateurs de supprimer leurs images
DROP POLICY IF EXISTS "Users can delete their own vehicle images" ON storage.objects;
CREATE POLICY "Users can delete their own vehicle images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'vehicle-images' AND auth.uid() = owner);