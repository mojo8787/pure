-- Fix the contracts policy
CREATE POLICY contracts_read_own ON contracts
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM subscriptions 
                WHERE subscriptions.id = contracts.subscription_id AND 
                      subscriptions.customer_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND role = 'admin')
    ); 