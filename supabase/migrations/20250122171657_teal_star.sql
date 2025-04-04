/*
  # Création des données de test

  1. Données
    - Ajout de 8 véhicules de test avec des caractéristiques variées
    - Ajout d'historiques d'entretien cohérents pour chaque véhicule
    
  2. Notes
    - Les données sont liées à un utilisateur de test
    - Les kilométrages et dates sont cohérents avec l'âge des véhicules
*/

-- Création d'un utilisateur de test s'il n'existe pas déjà
INSERT INTO auth.users (id, email)
VALUES ('d7bed83c-165d-4243-bb88-129f6b53cca7', 'test@example.com')
ON CONFLICT (id) DO NOTHING;

-- Insertion des véhicules
INSERT INTO vehicles (
  id,
  user_id,
  brand,
  model,
  type,
  year,
  license_plate,
  mileage,
  color,
  energy,
  date_of_first_registration,
  date_of_purchase,
  number_of_owners,
  image_url
) VALUES
-- Véhicule récent avec peu d'entretien
(
  '11111111-1111-1111-1111-111111111111',
  'd7bed83c-165d-4243-bb88-129f6b53cca7',
  'Tesla', 'Model 3', 'car', 2023, 'AB123CD', 15000,
  'Blanc', 'Électrique', '2023-03-15', '2023-03-15',
  1, 'https://images.unsplash.com/photo-1560958089-b8a1929cea89'
),
-- Véhicule d'âge moyen
(
  '22222222-2222-2222-2222-222222222222',
  'd7bed83c-165d-4243-bb88-129f6b53cca7',
  'Volkswagen', 'Golf', 'car', 2019, 'DE456FG', 85000,
  'Noir', 'Diesel', '2019-06-20', '2020-01-15',
  2, 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf'
),
-- Véhicule ancien avec beaucoup d'entretien
(
  '33333333-3333-3333-3333-333333333333',
  'd7bed83c-165d-4243-bb88-129f6b53cca7',
  'Peugeot', '205', 'car', 1992, 'GH789IJ', 245000,
  'Rouge', 'Essence', '1992-04-10', '2015-08-22',
  4, 'https://images.unsplash.com/photo-1600706432502-77a0e2e32771'
),
-- Moto récente
(
  '44444444-4444-4444-4444-444444444444',
  'd7bed83c-165d-4243-bb88-129f6b53cca7',
  'Yamaha', 'MT-07', 'motorcycle', 2022, 'KL012MN', 8500,
  'Bleu', 'Essence', '2022-05-01', '2022-05-01',
  1, 'https://images.unsplash.com/photo-1558981806-ec527fa84c39'
),
-- Utilitaire professionnel
(
  '55555555-5555-5555-5555-555555555555',
  'd7bed83c-165d-4243-bb88-129f6b53cca7',
  'Renault', 'Master', 'van', 2018, 'OP345QR', 156000,
  'Blanc', 'Diesel', '2018-02-15', '2018-02-15',
  1, 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d'
),
-- Véhicule familial
(
  '66666666-6666-6666-6666-666666666666',
  'd7bed83c-165d-4243-bb88-129f6b53cca7',
  'Citroën', 'C4 Picasso', 'car', 2016, 'ST678UV', 125000,
  'Gris', 'Diesel', '2016-09-30', '2019-03-15',
  2, 'https://images.unsplash.com/photo-1550355291-bbee04a92027'
),
-- Camion
(
  '77777777-7777-7777-7777-777777777777',
  'd7bed83c-165d-4243-bb88-129f6b53cca7',
  'Mercedes', 'Actros', 'truck', 2020, 'WX901YZ', 180000,
  'Blanc', 'Diesel', '2020-01-15', '2020-01-15',
  1, 'https://images.unsplash.com/photo-1586191582056-b5d6b911dd93'
),
-- Moto classique
(
  '88888888-8888-8888-8888-888888888888',
  'd7bed83c-165d-4243-bb88-129f6b53cca7',
  'Harley-Davidson', 'Sportster', 'motorcycle', 2015, 'AA111BB', 45000,
  'Noir', 'Essence', '2015-07-01', '2018-04-22',
  2, 'https://images.unsplash.com/photo-1558981359-219d6364c9c8'
);

-- Insertion des entretiens
INSERT INTO maintenances (
  vehicle_id,
  date,
  mileage,
  description,
  cost,
  garage,
  type,
  invoices
) VALUES
-- Tesla Model 3 (peu d'entretien)
(
  '11111111-1111-1111-1111-111111111111',
  '2023-09-15',
  10000,
  'Révision annuelle et mise à jour logiciel',
  250,
  'Tesla Service Center',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
-- Volkswagen Golf (entretiens réguliers)
(
  '22222222-2222-2222-2222-222222222222',
  '2021-06-20',
  30000,
  'Révision complète + changement filtres',
  450,
  'Volkswagen Paris',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '22222222-2222-2222-2222-222222222222',
  '2022-03-15',
  45000,
  'Changement plaquettes de frein',
  350,
  'Volkswagen Paris',
  'repair',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '22222222-2222-2222-2222-222222222222',
  '2023-01-10',
  70000,
  'Changement courroie de distribution',
  850,
  'Volkswagen Paris',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
-- Peugeot 205 (nombreux entretiens)
(
  '33333333-3333-3333-3333-333333333333',
  '2020-02-15',
  200000,
  'Réparation boîte de vitesses',
  1200,
  'Garage de la Place',
  'repair',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '33333333-3333-3333-3333-333333333333',
  '2021-05-20',
  215000,
  'Changement embrayage',
  800,
  'Garage de la Place',
  'repair',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '33333333-3333-3333-3333-333333333333',
  '2022-08-10',
  230000,
  'Révision générale et contrôle technique',
  350,
  'Garage de la Place',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '33333333-3333-3333-3333-333333333333',
  '2023-01-05',
  240000,
  'Réparation démarreur',
  400,
  'Garage de la Place',
  'repair',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
-- Yamaha MT-07 (entretiens basiques)
(
  '44444444-4444-4444-4444-444444444444',
  '2022-12-15',
  5000,
  'Première révision',
  200,
  'Yamaha Store',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '44444444-4444-4444-4444-444444444444',
  '2023-06-20',
  8000,
  'Changement pneus',
  450,
  'Yamaha Store',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
-- Renault Master (utilisation intensive)
(
  '55555555-5555-5555-5555-555555555555',
  '2020-03-15',
  50000,
  'Révision complète',
  600,
  'Renault Pro+',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '55555555-5555-5555-5555-555555555555',
  '2021-04-20',
  90000,
  'Changement injecteurs',
  1500,
  'Renault Pro+',
  'repair',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '55555555-5555-5555-5555-555555555555',
  '2022-06-10',
  130000,
  'Révision + courroie distribution',
  1200,
  'Renault Pro+',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
-- Citroën C4 (entretiens réguliers)
(
  '66666666-6666-6666-6666-666666666666',
  '2020-05-15',
  80000,
  'Révision générale',
  400,
  'Citroën Service',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '66666666-6666-6666-6666-666666666666',
  '2021-07-20',
  95000,
  'Changement freins + pneus',
  850,
  'Citroën Service',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '66666666-6666-6666-6666-666666666666',
  '2022-09-10',
  110000,
  'Réparation climatisation',
  600,
  'Citroën Service',
  'repair',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
-- Mercedes Actros (entretiens professionnels)
(
  '77777777-7777-7777-7777-777777777777',
  '2021-02-15',
  60000,
  'Révision complète',
  1500,
  'Mercedes Trucks',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '77777777-7777-7777-7777-777777777777',
  '2022-03-20',
  120000,
  'Changement embrayage',
  2500,
  'Mercedes Trucks',
  'repair',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
-- Harley-Davidson (entretiens spécialisés)
(
  '88888888-8888-8888-8888-888888888888',
  '2020-08-15',
  25000,
  'Révision annuelle',
  500,
  'Harley-Davidson Store',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '88888888-8888-8888-8888-888888888888',
  '2021-09-20',
  35000,
  'Changement pneus et chaîne',
  800,
  'Harley-Davidson Store',
  'maintenance',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
),
(
  '88888888-8888-8888-8888-888888888888',
  '2022-10-10',
  42000,
  'Réglage injection',
  400,
  'Harley-Davidson Store',
  'repair',
  ARRAY['https://images.unsplash.com/photo-1628177142898-93e36e4e3a50']
);