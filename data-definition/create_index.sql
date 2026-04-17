create table "public"."todos" (
    "id" SERIAL,
    "employee_id" integer not null,
    "title" varchar(100) not null,
    "description" text null,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    constraint "todos_pkey" primary key ("id"),
    constraint "fk_todos_employee_id" foreign key ("employee_id") references "public"."employees" ("employee_id") on delete cascade on update cascade
);

-- Tambah kolom soft delete (nullable → null = data aktif)
ALTER TABLE "public"."todos"
ADD COLUMN IF NOT EXISTS "deleted_at" TIMESTAMPTZ NULL;

-- =========================================================
-- INDEXING STRATEGY
-- =========================================================

-- Partial index untuk data aktif (soft delete)
-- Kenapa pakai partial index?
-- 1. GORM default selalu query: WHERE deleted_at IS NULL
-- 2. Index jadi lebih kecil (hanya data aktif)
-- 3. Query SELECT jadi lebih cepat karena tidak scan data yang sudah dihapus
-- 4. Lebih optimal dibanding index full di deleted_at

-- NOTE:
-- Saat ini pakai (id), tapi di real use-case biasanya lebih optimal:
-- (employee_id) karena sering dipakai di WHERE clause
-- contoh: WHERE employee_id = ? AND deleted_at IS NULL
CREATE INDEX IF NOT EXISTS idx_todos_active
ON "public"."todos" ("id")
WHERE "deleted_at" IS NULL;

-- ini contoh nanti kalau sering pakai
-- WHERE employee_id = ? AND deleted_at IS NULL
-- CREATE INDEX IF NOT EXISTS idx_todos_employee_active
-- ON "public"."todos" ("employee_id")
-- WHERE "deleted_at" IS NULL;
