-- Local seed for ADMIN-AUTH-001 manual testing.
-- Execute in the postgres container:
--   docker cp scripts/seed-local-admin.sql motodigo-postgres-1:/tmp/seed-local-admin.sql
--   docker exec -it motodigo-postgres-1 psql -U motodigo -d motodigo -f /tmp/seed-local-admin.sql
--
-- Login credentials:
--   phone:    +237686833006
--   password: MotodiAdmin123!

BEGIN;

WITH upsert_user AS (
  INSERT INTO users (
    phone_number,
    password_hash,
    full_name,
    email,
    locale,
    cgu_accepted,
    status,
    phone_verified_at
  )
  VALUES (
    '+237686833006',
    crypt('MotodiAdmin123!', gen_salt('bf', 10)),
    'Joan MELONG',
    'joantsayem@gmail.com',
    'fr-CM',
    true,
    'ACTIVE',
    now()
  )
  ON CONFLICT (phone_number) DO UPDATE
  SET
    password_hash = EXCLUDED.password_hash,
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    locale = EXCLUDED.locale,
    cgu_accepted = true,
    status = 'ACTIVE',
    phone_verified_at = COALESCE(users.phone_verified_at, now()),
    updated_at = now()
  RETURNING id
),
deactivate_profiles AS (
  UPDATE profiles
  SET active = false, updated_at = now()
  WHERE user_id = (SELECT id FROM upsert_user)
  RETURNING id
),
upsert_profile AS (
  INSERT INTO profiles (
    user_id,
    type,
    validation_status,
    display_name,
    active
  )
  VALUES (
    (SELECT id FROM upsert_user),
    'ADMIN',
    'VALIDATED',
    'Joan MELONG',
    true
  )
  ON CONFLICT (user_id, type) DO UPDATE
  SET
    validation_status = 'VALIDATED',
    display_name = EXCLUDED.display_name,
    active = true,
    updated_at = now()
  RETURNING id
)
INSERT INTO admin_profiles (
  profile_id,
  admin_role,
  permissions
)
VALUES (
  (SELECT id FROM upsert_profile),
  'PLATFORM_ADMIN',
  ARRAY[
    'PROFILE_READ',
    'PROFILE_UPDATE',
    'PROFILE_SWITCH',
    'KYC_REVIEW_READ',
    'KYC_DECIDE',
    'MODERATION_READ',
    'MODERATION_WRITE',
    'OPERATIONS_READ',
    'PRICING_READ',
    'PRICING_WRITE',
    'GIS_READ',
    'GIS_WRITE',
    'KPI_READ'
  ]::text[]
)
ON CONFLICT (profile_id) DO UPDATE
SET
  admin_role = EXCLUDED.admin_role,
  permissions = EXCLUDED.permissions;

COMMIT;

SELECT
  u.phone_number,
  u.full_name,
  u.email,
  u.status,
  u.cgu_accepted,
  p.type AS active_profile_type,
  p.validation_status AS profile_status,
  p.active AS profile_active,
  a.admin_role,
  a.permissions
FROM users u
JOIN profiles p ON p.user_id = u.id AND p.type = 'ADMIN'
JOIN admin_profiles a ON a.profile_id = p.id
WHERE u.phone_number = '+237686833006';
