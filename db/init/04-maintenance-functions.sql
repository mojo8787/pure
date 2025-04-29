-- Function to schedule a maintenance visit
CREATE OR REPLACE FUNCTION schedule_maintenance_visit(
    p_subscription_id UUID,
    p_scheduled_for TIMESTAMP WITH TIME ZONE,
    p_notes TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_visit_id UUID;
BEGIN
    -- Insert the maintenance visit
    INSERT INTO maintenance_visits (
        subscription_id,
        scheduled_for,
        status,
        notes
    ) VALUES (
        p_subscription_id,
        p_scheduled_for,
        'scheduled',
        p_notes
    ) RETURNING id INTO v_visit_id;

    -- Update the subscription's next maintenance date
    UPDATE subscriptions
    SET next_billing_date = p_scheduled_for
    WHERE id = p_subscription_id;

    RETURN v_visit_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update maintenance visit status
CREATE OR REPLACE FUNCTION update_maintenance_visit_status(
    p_visit_id UUID,
    p_status TEXT,
    p_notes TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE maintenance_visits
    SET 
        status = p_status,
        notes = COALESCE(p_notes, notes),
        completed_at = CASE 
            WHEN p_status = 'completed' THEN NOW()
            ELSE completed_at
        END,
        updated_at = NOW()
    WHERE id = p_visit_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get upcoming maintenance visits
CREATE OR REPLACE FUNCTION get_upcoming_maintenance_visits(
    p_customer_id UUID,
    p_limit INTEGER DEFAULT 5
) RETURNS TABLE (
    id UUID,
    subscription_id UUID,
    scheduled_for TIMESTAMP WITH TIME ZONE,
    status TEXT,
    notes TEXT,
    technician_name TEXT,
    technician_phone TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mv.id,
        mv.subscription_id,
        mv.scheduled_for,
        mv.status,
        mv.notes,
        u.full_name as technician_name,
        u.phone as technician_phone
    FROM maintenance_visits mv
    JOIN subscriptions s ON s.id = mv.subscription_id
    LEFT JOIN auth.users u ON u.id = mv.technician_id
    WHERE s.customer_id = p_customer_id
    AND mv.scheduled_for > NOW()
    ORDER BY mv.scheduled_for ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 