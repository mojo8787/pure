-- Enable the UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create necessary roles
CREATE ROLE anon NOLOGIN;
CREATE ROLE authenticated NOLOGIN;
CREATE ROLE service_role NOLOGIN;

-- Grant permissions to roles
GRANT anon TO postgres;
GRANT authenticated TO postgres;
GRANT service_role TO postgres;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;

-- Create the users table
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL DEFAULT 'customer',
    name TEXT,
    phone TEXT,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create the subscriptions table
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES public.users(id),
    plan TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    price_monthly DECIMAL(10, 2) NOT NULL,
    next_billing_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create the contracts table
CREATE TABLE IF NOT EXISTS public.contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_id UUID REFERENCES public.subscriptions(id),
    file_url TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    signed_at TIMESTAMP WITH TIME ZONE
);

-- Create the invoices table
CREATE TABLE IF NOT EXISTS public.invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_id UUID REFERENCES public.subscriptions(id),
    amount DECIMAL(10, 2) NOT NULL,
    invoice_number TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    due_on TIMESTAMP WITH TIME ZONE NOT NULL,
    paid_on TIMESTAMP WITH TIME ZONE,
    payment_method TEXT,
    pdf_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create the maintenance_visits table
CREATE TABLE IF NOT EXISTS public.maintenance_visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_id UUID REFERENCES public.subscriptions(id),
    technician_id UUID REFERENCES public.users(id),
    scheduled_for TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled',
    address TEXT NOT NULL,
    notes TEXT,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create the support_tickets table
CREATE TABLE IF NOT EXISTS public.support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES public.users(id),
    subject TEXT NOT NULL,
    message TEXT NOT NULL,
    priority TEXT NOT NULL DEFAULT 'medium',
    status TEXT NOT NULL DEFAULT 'open',
    assigned_to UUID REFERENCES public.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- Create RLS policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

-- Create basic policies
CREATE POLICY users_policy ON public.users
    USING (id = auth.uid() OR role IN ('admin', 'technician'));

CREATE POLICY subscriptions_policy ON public.subscriptions
    USING (customer_id = auth.uid() OR EXISTS (
        SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin')
    ));

CREATE POLICY maintenance_visits_technician_policy ON public.maintenance_visits
    USING (technician_id = auth.uid() OR EXISTS (
        SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin')
    ) OR EXISTS (
        SELECT 1 FROM public.subscriptions
        WHERE subscriptions.id = maintenance_visits.subscription_id
        AND subscriptions.customer_id = auth.uid()
    ));

-- Create some sample data for testing
INSERT INTO public.users (id, email, role, name, phone, address)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin@example.com', 'admin', 'Admin User', '+1234567890', '123 Admin St'),
    ('00000000-0000-0000-0000-000000000002', 'tech@example.com', 'technician', 'Tech User', '+1234567891', '456 Tech Ave'),
    ('00000000-0000-0000-0000-000000000003', 'customer@example.com', 'customer', 'Customer User', '+1234567892', '789 Customer Blvd');

-- Grant permissions on all tables to authenticated users
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;

-- PureFlow Database Schema Initialization

-- Create custom types for enums
CREATE TYPE user_role AS ENUM ('customer', 'technician', 'admin');
CREATE TYPE contract_status AS ENUM ('pending', 'signed', 'expired');
CREATE TYPE subscription_status AS ENUM ('pending', 'active', 'paused', 'cancelled');
CREATE TYPE appointment_type AS ENUM ('install', 'maintenance');
CREATE TYPE appointment_status AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled', 'rescheduled');
CREATE TYPE invoice_status AS ENUM ('draft', 'pending', 'paid', 'overdue', 'cancelled');
CREATE TYPE ticket_status AS ENUM ('open', 'in_progress', 'resolved', 'closed');
CREATE TYPE ticket_priority AS ENUM ('low', 'medium', 'high', 'urgent');
CREATE TYPE ticket_category AS ENUM ('water_quality', 'leakage', 'installation', 'billing', 'other');

-- Extend auth.users with metadata
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS role user_role DEFAULT 'customer';
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS full_name TEXT;
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Create customer_profiles table
CREATE TABLE IF NOT EXISTS customer_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    address TEXT NOT NULL,
    phone TEXT NOT NULL,
    city TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create technician_profiles table
CREATE TABLE IF NOT EXISTS technician_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    region TEXT NOT NULL,
    vehicle_plate TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create contracts table
CREATE TABLE IF NOT EXISTS contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    file_url TEXT,
    status contract_status DEFAULT 'pending',
    signed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    expires_at TIMESTAMP WITH TIME ZONE
);

-- Create subscriptions table
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    contract_id UUID REFERENCES contracts(id),
    status subscription_status DEFAULT 'pending',
    plan TEXT NOT NULL,
    price_monthly DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    next_billing_date TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE
);

-- Create appointments table
CREATE TABLE IF NOT EXISTS appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    technician_id UUID REFERENCES auth.users(id),
    date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    type appointment_type NOT NULL,
    status appointment_status DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE
);

-- Create maintenance_visits table
CREATE TABLE IF NOT EXISTS maintenance_visits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    scheduled_for TIMESTAMP WITH TIME ZONE NOT NULL,
    technician_id UUID REFERENCES auth.users(id),
    status appointment_status DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Create invoices table
CREATE TABLE IF NOT EXISTS invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    due_on DATE NOT NULL,
    pdf_url TEXT,
    status invoice_status DEFAULT 'draft',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    paid_on TIMESTAMP WITH TIME ZONE,
    payment_method TEXT,
    invoice_number TEXT NOT NULL UNIQUE
);

-- Create tickets table
CREATE TABLE IF NOT EXISTS tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    technician_id UUID REFERENCES auth.users(id),
    subject TEXT NOT NULL,
    detail TEXT NOT NULL,
    status ticket_status DEFAULT 'open',
    priority ticket_priority DEFAULT 'medium',
    category ticket_category NOT NULL,
    photo_urls TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- Create ticket_responses table
CREATE TABLE IF NOT EXISTS ticket_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    photo_urls TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create health_check table for testing connection
CREATE TABLE IF NOT EXISTS health_check (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status TEXT DEFAULT 'ok',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Insert a health check record
INSERT INTO health_check (status) VALUES ('ok');

-- Enable Row Level Security on all tables
ALTER TABLE customer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE technician_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_check ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies

-- Everyone can read the health_check table
CREATE POLICY health_check_read_policy ON health_check
    FOR SELECT USING (true);

-- Customer profiles policies
CREATE POLICY customer_profiles_read_own ON customer_profiles
    FOR SELECT TO authenticated USING (
        auth.uid() = user_id OR 
        EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND (role = 'admin' OR role = 'technician'))
    );

-- Technician profiles policies
CREATE POLICY technician_profiles_read_own ON technician_profiles
    FOR SELECT TO authenticated USING (
        auth.uid() = user_id OR 
        EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND role = 'admin')
    );

-- Contracts policies
CREATE POLICY contracts_read_own ON contracts
    FOR SELECT TO authenticated USING (
        auth.uid() = customer_id OR 
        EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND role = 'admin')
    );

-- Subscriptions policies
CREATE POLICY subscriptions_read_own ON subscriptions
    FOR SELECT TO authenticated USING (
        auth.uid() = customer_id OR 
        EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND 
            (role = 'admin' OR 
             (role = 'technician' AND EXISTS (
                SELECT 1 FROM appointments 
                WHERE appointments.subscription_id = subscriptions.id AND 
                      appointments.technician_id = auth.uid()
             ))
            )
        )
    );

-- Appointments policies
CREATE POLICY appointments_read_policy ON appointments
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM subscriptions 
                WHERE subscriptions.id = appointments.subscription_id AND 
                      subscriptions.customer_id = auth.uid()) OR
        auth.uid() = technician_id OR
        EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND role = 'admin')
    );

-- Maintenance visits policies
CREATE POLICY maintenance_visits_read_policy ON maintenance_visits
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM subscriptions 
                WHERE subscriptions.id = maintenance_visits.subscription_id AND 
                      subscriptions.customer_id = auth.uid()) OR
        auth.uid() = technician_id OR
        EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND role = 'admin')
    );

-- Invoices policies
CREATE POLICY invoices_read_policy ON invoices
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM subscriptions 
                WHERE subscriptions.id = invoices.subscription_id AND 
                      subscriptions.customer_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND role = 'admin')
    );

-- Tickets policies
CREATE POLICY tickets_read_policy ON tickets
    FOR SELECT TO authenticated USING (
        auth.uid() = customer_id OR
        auth.uid() = technician_id OR
        EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND role = 'admin')
    );

-- Ticket responses policies
CREATE POLICY ticket_responses_read_policy ON ticket_responses
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM tickets 
                WHERE tickets.id = ticket_responses.ticket_id AND 
                      (tickets.customer_id = auth.uid() OR 
                       tickets.technician_id = auth.uid())) OR
        EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND role = 'admin')
    );

-- Add update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_customer_profiles_updated_at
    BEFORE UPDATE ON customer_profiles
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_technician_profiles_updated_at
    BEFORE UPDATE ON technician_profiles
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_contracts_updated_at
    BEFORE UPDATE ON contracts
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_maintenance_visits_updated_at
    BEFORE UPDATE ON maintenance_visits
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at
    BEFORE UPDATE ON invoices
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_tickets_updated_at
    BEFORE UPDATE ON tickets
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column(); 