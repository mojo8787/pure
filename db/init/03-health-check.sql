-- Make sure health_check table exists and is accessible
CREATE TABLE IF NOT EXISTS health_check (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status TEXT DEFAULT 'ok',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Make sure there's at least one row
INSERT INTO health_check (status) 
SELECT 'ok' 
WHERE NOT EXISTS (SELECT 1 FROM health_check);

-- Enable Row Level Security on the table
ALTER TABLE health_check ENABLE ROW LEVEL SECURITY;

-- Create a policy to allow all authenticated users to read the health_check table
DROP POLICY IF EXISTS health_check_read_policy ON health_check;
CREATE POLICY health_check_read_policy ON health_check
    FOR SELECT USING (true); 