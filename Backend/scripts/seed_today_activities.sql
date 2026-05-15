-- Seed activities for TODAY for admin@eco.com user
-- Run against eco_db PostgreSQL database

DO $$
DECLARE
    admin_id INT;
    today_date DATE;
BEGIN
    -- Get the user ID for admin@eco.com
    SELECT "Id" INTO admin_id FROM "AspNetUsers" WHERE "Email" = 'admin@eco.com';

    IF admin_id IS NULL THEN
        RAISE EXCEPTION 'User with email admin@eco.com not found!';
    END IF;

    today_date := CURRENT_DATE;
    RAISE NOTICE 'Adding activities for admin user (ID: %) for date: %', admin_id, today_date;

    -- ============================================
    -- INSERT ACTIVITIES FOR TODAY
    -- ============================================

    -- Transport activities
    -- Walking (TypeId=1, 0 CO2, 15pts)
    INSERT INTO "Activities" ("UserId", "ActivityTypeId", "Quantity", "Unit", "Notes", "CO2Impact", "PointsEarned", "LocationName", "ActivityDate", "ActivityTime", "CreatedAt", "IsAutoDetected")
    VALUES
    (admin_id, 1, 3.5, 'km', 'Morning walk to office', 0.0, 15, 'Downtown', today_date, '08:00:00'::time, NOW(), false),
    (admin_id, 1, 2.0, 'km', 'Evening walk', 0.0, 15, 'Park', today_date, '18:30:00'::time, NOW(), false),
    
    -- Cycling (TypeId=2, 0 CO2, 15pts)
    (admin_id, 2, 8.0, 'km', 'Cycle to college', 0.0, 15, 'GTU Campus', today_date, '09:00:00'::time, NOW(), false),
    
    -- Public Transit (TypeId=3, 0.089 CO2/km, 10pts)
    (admin_id, 3, 15.0, 'km', 'Bus to work', 15.0 * 0.089, 10, 'Bus Station', today_date, '08:30:00'::time, NOW(), false),
    
    -- Food activities
    -- Vegan Meal (TypeId=9, -2.5 CO2, 20pts)
    (admin_id, 9, 1.0, 'meal', 'Vegan breakfast', -2.5, 20, '', today_date, '07:30:00'::time, NOW(), false),
    (admin_id, 9, 1.0, 'meal', 'Vegan lunch', -2.5, 20, 'Cafe', today_date, '12:30:00'::time, NOW(), false),
    (admin_id, 9, 1.0, 'meal', 'Vegan dinner', -2.5, 20, '', today_date, '19:00:00'::time, NOW(), false),
    
    -- Vegetarian Meal (TypeId=10, -1.5 CO2, 15pts)
    (admin_id, 10, 1.0, 'meal', 'Veggie snack', -1.5, 15, '', today_date, '15:00:00'::time, NOW(), false),
    
    -- Local Produce (TypeId=11, -0.5 CO2, 10pts)
    (admin_id, 11, 2.0, 'kg', 'Farmers market shopping', -1.0, 10, 'Farmers Market', today_date, '10:00:00'::time, NOW(), false),
    
    -- Energy activities
    -- Solar Energy (TypeId=14, -1.5 CO2/kWh, 20pts)
    (admin_id, 14, 5.0, 'kWh', 'Solar panel output', -7.5, 20, 'Home', today_date, '12:00:00'::time, NOW(), false),
    
    -- LED Lighting (TypeId=15, -0.05 CO2/hr, 5pts)
    (admin_id, 15, 8.0, 'hours', 'LED lights used today', -0.4, 5, 'Home', today_date, '20:00:00'::time, NOW(), false),
    
    -- Air Dry Laundry (TypeId=16, -2.4 CO2/load, 10pts)
    (admin_id, 16, 1.0, 'load', 'Air dried clothes', -2.4, 10, 'Home', today_date, '11:00:00'::time, NOW(), false),
    
    -- Recycling (TypeId=18, -0.5 CO2/kg, 10pts)
    (admin_id, 18, 3.0, 'kg', 'Recycling today', -1.5, 10, 'Recycling Bin', today_date, '17:00:00'::time, NOW(), false);

    RAISE NOTICE 'Successfully added 13 activities for today!';

END $$;
