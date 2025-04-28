# PureFlow Database Schema

This document outlines the database schema for the PureFlow app. The database is hosted on Supabase and follows a relational design pattern with Row-Level Security (RLS) for data protection.

## Tables

### users

The built-in Supabase authentication table with custom metadata.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| email | text | User email |
| created_at | timestamp | Account creation timestamp |
| ... | ... | Other auth fields |

**Metadata:**
- `role`: enum ('customer', 'technician', 'admin')
- `full_name`: User's full name
- `phone`: Contact phone number
- `avatar_url`: Profile image URL

**RLS Policies:**
- Users can read their own data
- Admins can read all user data
- Technicians can read customer data for their assigned regions

### customer_profiles

Extended customer information.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| user_id | uuid | Foreign key to users |
| address | text | Customer address |
| phone | text | Contact phone |
| city | text | City |
| postal_code | text | Postal code |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |

**RLS Policies:**
- Customers can read only their own profile
- Technicians can read profiles in their assigned regions
- Admins can read and update all profiles

### technician_profiles

Technician-specific information.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| user_id | uuid | Foreign key to users |
| region | text | Assigned region |
| vehicle_plate | text | Vehicle license plate |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |

**RLS Policies:**
- Technicians can read their own profile
- Admins can read and update all profiles

### contracts

Legal agreements between customers and the service.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| customer_id | uuid | Foreign key to users |
| file_url | text | URL to signed PDF in storage |
| status | enum | ('pending', 'signed', 'expired') |
| signed_at | timestamp | When contract was signed |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |
| expires_at | timestamp | Contract expiration date |

**RLS Policies:**
- Customers can read their own contracts and update status to 'signed'
- Admins can read and update all contracts

### subscriptions

RO water filter subscriptions.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| customer_id | uuid | Foreign key to users |
| status | enum | ('pending', 'active', 'paused', 'cancelled') |
| plan | text | Subscription plan |
| price_monthly | decimal | Monthly price |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |
| next_billing_date | timestamp | Next billing date |
| cancelled_at | timestamp | When subscription was cancelled |

**RLS Policies:**
- Customers can read their own subscriptions
- Technicians can read subscriptions for their assigned customers
- Admins can read and update all subscriptions

### appointments

One-off appointments for installation and maintenance.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| subscription_id | uuid | Foreign key to subscriptions |
| technician_id | uuid | Foreign key to users (technician) |
| date_time | timestamp | Appointment date and time |
| type | enum | ('install', 'maintenance') |
| status | enum | ('scheduled', 'in_progress', 'completed', 'cancelled', 'rescheduled') |
| notes | text | Appointment notes |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |
| completed_at | timestamp | When job was completed |
| cancelled_at | timestamp | When appointment was cancelled |

**RLS Policies:**
- Customers can read appointments for their subscriptions
- Technicians can read and update appointments assigned to them
- Admins can read and update all appointments

### maintenance_visits

Recurring filter changes.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| subscription_id | uuid | Foreign key to subscriptions |
| scheduled_for | timestamp | Visit date and time |
| technician_id | uuid | Foreign key to users (technician) |
| status | enum | Same as appointments |
| notes | text | Visit notes |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |
| completed_at | timestamp | When visit was completed |

**RLS Policies:**
- Same as appointments

### invoices

Monthly charges.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| subscription_id | uuid | Foreign key to subscriptions |
| amount | decimal | Invoice amount |
| due_on | date | Payment due date |
| pdf_url | text | URL to invoice PDF |
| status | enum | ('draft', 'pending', 'paid', 'overdue', 'cancelled') |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |
| paid_on | timestamp | When invoice was paid |
| payment_method | text | Payment method used |
| invoice_number | text | Unique invoice identifier |

**RLS Policies:**
- Customers can read invoices for their subscriptions
- Admins can read and update all invoices

### tickets

Support tickets.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| customer_id | uuid | Foreign key to users |
| technician_id | uuid | Foreign key to users (technician) |
| subject | text | Ticket subject |
| detail | text | Ticket description |
| status | enum | ('open', 'in_progress', 'resolved', 'closed') |
| priority | enum | ('low', 'medium', 'high', 'urgent') |
| category | enum | ('water_quality', 'leakage', 'installation', 'billing', 'other') |
| photo_urls | text[] | Array of photo URLs |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |
| resolved_at | timestamp | When ticket was resolved |

**RLS Policies:**
- Customers can read and create tickets linked to their account
- Technicians can read and update tickets assigned to them
- Admins can read and update all tickets

### ticket_responses

Responses to support tickets.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_id | uuid | Foreign key to tickets |
| user_id | uuid | Foreign key to users (who responded) |
| message | text | Response message |
| photo_urls | text[] | Array of photo URLs |
| created_at | timestamp | Creation timestamp |

**RLS Policies:**
- Customers can read responses to their tickets and create responses to their tickets
- Technicians can read and create responses to tickets assigned to them
- Admins can read and create all responses

## Edge Functions

Edge functions implemented on Supabase:

| Function | Description |
|----------|-------------|
| schedule_monthly_visit | Inserts future maintenance visits rows |
| generate_invoice | Creates PDF, uploads to Storage, emails customer |
| send_push | Unified push notification helper |

## Supabase Storage Buckets

| Bucket | Description | Access |
|--------|-------------|--------|
| contracts | Signed contract PDFs | Private with RLS |
| invoices | Invoice PDFs | Private with RLS |
| profile_images | User avatars | Private with RLS |
| ticket_photos | Support ticket images | Private with RLS |

## RLS Implementation Guidelines

Row-Level Security (RLS) is implemented with the following policies:

1. **Row ownership**: Customers can only access their own data
2. **Role-based access**: Admins have full access to all tables
3. **Region-based access**: Technicians can only access data for customers in their assigned regions
4. **Technician assignments**: Technicians can access appointments and tickets assigned to them

Each policy is implemented using Postgres functions and criteria that validate the requesting user's identity and role before allowing data access. 