-- ============================================================
-- SQL Schema for Students and Teachers Tables
-- ============================================================
-- Run this in your Supabase SQL Editor
-- This will create the tables with proper structure and RLS policies
-- ============================================================

-- ============================================================
-- STUDENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  course_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create unique index on email to prevent duplicates
CREATE UNIQUE INDEX IF NOT EXISTS students_email_idx ON students(email);

-- Add comment to table
COMMENT ON TABLE students IS 'Stores student information. Automatically created on user login.';

-- ============================================================
-- TEACHERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS teachers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  specialization TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create unique index on email to prevent duplicates
CREATE UNIQUE INDEX IF NOT EXISTS teachers_email_idx ON teachers(email);

-- Add comment to table
COMMENT ON TABLE teachers IS 'Stores teacher information.';

-- ============================================================
-- TRIGGER: Auto-update updated_at timestamp
-- ============================================================
-- Function to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for students table
DROP TRIGGER IF EXISTS update_students_updated_at ON students;
CREATE TRIGGER update_students_updated_at
  BEFORE UPDATE ON students
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for teachers table
DROP TRIGGER IF EXISTS update_teachers_updated_at ON teachers;
CREATE TRIGGER update_teachers_updated_at
  BEFORE UPDATE ON teachers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================

-- Enable RLS on students table
ALTER TABLE students ENABLE ROW LEVEL SECURITY;

-- Enable RLS on teachers table
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- STUDENTS TABLE POLICIES
-- ============================================================

-- Policy: Allow authenticated users to SELECT all students
DROP POLICY IF EXISTS "Allow authenticated users to view students" ON students;
CREATE POLICY "Allow authenticated users to view students"
  ON students
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Allow authenticated users to INSERT students
DROP POLICY IF EXISTS "Allow authenticated users to insert students" ON students;
CREATE POLICY "Allow authenticated users to insert students"
  ON students
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy: Allow authenticated users to UPDATE students
DROP POLICY IF EXISTS "Allow authenticated users to update students" ON students;
CREATE POLICY "Allow authenticated users to update students"
  ON students
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Policy: Allow authenticated users to DELETE students
DROP POLICY IF EXISTS "Allow authenticated users to delete students" ON students;
CREATE POLICY "Allow authenticated users to delete students"
  ON students
  FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================
-- TEACHERS TABLE POLICIES
-- ============================================================

-- Policy: Allow authenticated users to SELECT all teachers
DROP POLICY IF EXISTS "Allow authenticated users to view teachers" ON teachers;
CREATE POLICY "Allow authenticated users to view teachers"
  ON teachers
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Allow authenticated users to INSERT teachers
DROP POLICY IF EXISTS "Allow authenticated users to insert teachers" ON teachers;
CREATE POLICY "Allow authenticated users to insert teachers"
  ON teachers
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Policy: Allow authenticated users to UPDATE teachers
DROP POLICY IF EXISTS "Allow authenticated users to update teachers" ON teachers;
CREATE POLICY "Allow authenticated users to update teachers"
  ON teachers
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Policy: Allow authenticated users to DELETE teachers
DROP POLICY IF EXISTS "Allow authenticated users to delete teachers" ON teachers;
CREATE POLICY "Allow authenticated users to delete teachers"
  ON teachers
  FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================
-- VERIFICATION QUERIES (Optional - Run to verify setup)
-- ============================================================
-- Uncomment these to verify the tables were created correctly:

-- SELECT table_name, column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name IN ('students', 'teachers')
-- ORDER BY table_name, ordinal_position;

-- SELECT tablename, policyname, permissive, roles, cmd
-- FROM pg_policies
-- WHERE tablename IN ('students', 'teachers')
-- ORDER BY tablename, policyname;

-- ============================================================
-- NOTES:
-- ============================================================
-- 1. Tables use UUID primary keys (Supabase default)
-- 2. Email fields have unique constraints to prevent duplicates
-- 3. RLS is enabled and policies allow all CRUD operations for authenticated users
-- 4. updated_at is automatically updated via triggers
-- 5. created_at is set automatically on insert
-- 6. The students table is designed to work with automatic student creation on login
-- ============================================================

