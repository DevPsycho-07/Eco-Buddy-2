-- Seed data for admin@eco.com user
-- Run against eco_db PostgreSQL database

DO $$
DECLARE
    admin_id INT;
BEGIN
    -- Get the user ID for admin@eco.com
    SELECT "Id" INTO admin_id FROM "AspNetUsers" WHERE "Email" = 'admin@eco.com';

    IF admin_id IS NULL THEN
        RAISE EXCEPTION 'User with email admin@eco.com not found!';
    END IF;

    RAISE NOTICE 'Found admin user with ID: %', admin_id;

    -- ============================================
    -- INSERT ACTIVITIES (past 30 days, diverse mix)
    -- ============================================

    -- Transport activities
    INSERT INTO "Activities" ("UserId", "ActivityTypeId", "Quantity", "Unit", "Notes", "CO2Impact", "PointsEarned", "LocationName", "ActivityDate", "CreatedAt", "IsAutoDetected")
    VALUES
    -- Walking (TypeId=1, 0 CO2, 15pts)
    (admin_id, 1, 3.5, 'km', 'Morning walk to office', 0.0, 15, 'Downtown', NOW() - INTERVAL '1 day', NOW(), false),
    (admin_id, 1, 2.0, 'km', 'Evening walk', 0.0, 15, 'Park', NOW() - INTERVAL '2 days', NOW(), false),
    (admin_id, 1, 4.0, 'km', 'Walk to market', 0.0, 15, 'Market Road', NOW() - INTERVAL '4 days', NOW(), false),
    (admin_id, 1, 1.5, 'km', 'Short walk', 0.0, 15, '', NOW() - INTERVAL '6 days', NOW(), false),
    (admin_id, 1, 5.0, 'km', 'Long walk', 0.0, 15, 'Riverside', NOW() - INTERVAL '8 days', NOW(), false),
    (admin_id, 1, 2.5, 'km', 'Walk to gym', 0.0, 15, 'Gym', NOW() - INTERVAL '10 days', NOW(), false),
    (admin_id, 1, 3.0, 'km', 'Walk with friends', 0.0, 15, '', NOW() - INTERVAL '14 days', NOW(), false),
    (admin_id, 1, 2.0, 'km', 'Morning stroll', 0.0, 15, '', NOW() - INTERVAL '20 days', NOW(), false),

    -- Cycling (TypeId=2, 0 CO2, 15pts)
    (admin_id, 2, 8.0, 'km', 'Cycle to college', 0.0, 15, 'GTU Campus', NOW() - INTERVAL '1 day', NOW(), false),
    (admin_id, 2, 12.0, 'km', 'Weekend cycling', 0.0, 15, 'City Trail', NOW() - INTERVAL '3 days', NOW(), false),
    (admin_id, 2, 5.0, 'km', 'Quick bike ride', 0.0, 15, '', NOW() - INTERVAL '5 days', NOW(), false),
    (admin_id, 2, 10.0, 'km', 'Cycling workout', 0.0, 15, 'Cycling Track', NOW() - INTERVAL '9 days', NOW(), false),
    (admin_id, 2, 6.0, 'km', 'Bike to store', 0.0, 15, '', NOW() - INTERVAL '15 days', NOW(), false),

    -- Public Transit (TypeId=3, 0.089 CO2/km, 10pts)
    (admin_id, 3, 15.0, 'km', 'Bus to work', 15.0 * 0.089, 10, 'Bus Station', NOW() - INTERVAL '2 days', NOW(), false),
    (admin_id, 3, 20.0, 'km', 'Metro ride', 20.0 * 0.089, 10, 'Metro', NOW() - INTERVAL '7 days', NOW(), false),
    (admin_id, 3, 10.0, 'km', 'Bus commute', 10.0 * 0.089, 10, '', NOW() - INTERVAL '12 days', NOW(), false),

    -- Car Solo (TypeId=5, 0.192 CO2/km, 0pts) - emitting activities
    (admin_id, 5, 25.0, 'km', 'Drive to meeting', 25.0 * 0.192, 0, 'Office', NOW() - INTERVAL '3 days', NOW(), false),
    (admin_id, 5, 40.0, 'km', 'Road trip', 40.0 * 0.192, 0, 'Highway', NOW() - INTERVAL '7 days', NOW(), false),
    (admin_id, 5, 15.0, 'km', 'Grocery run', 15.0 * 0.192, 0, 'Mall', NOW() - INTERVAL '11 days', NOW(), false),
    (admin_id, 5, 30.0, 'km', 'Weekend drive', 30.0 * 0.192, 0, '', NOW() - INTERVAL '18 days', NOW(), false),
    (admin_id, 5, 20.0, 'km', 'Commute', 20.0 * 0.192, 0, '', NOW() - INTERVAL '25 days', NOW(), false),

    -- Carpooling (TypeId=6, 0.096 CO2/km, 8pts)
    (admin_id, 6, 20.0, 'km', 'Carpool with colleagues', 20.0 * 0.096, 8, 'Office', NOW() - INTERVAL '4 days', NOW(), false),
    (admin_id, 6, 15.0, 'km', 'Shared ride', 15.0 * 0.096, 8, '', NOW() - INTERVAL '13 days', NOW(), false),

    -- Food activities
    -- Vegan Meal (TypeId=9, -2.5 CO2, 20pts)
    (admin_id, 9, 1.0, 'meal', 'Vegan lunch', -2.5, 20, '', NOW() - INTERVAL '1 day', NOW(), false),
    (admin_id, 9, 1.0, 'meal', 'Vegan dinner', -2.5, 20, '', NOW() - INTERVAL '2 days', NOW(), false),
    (admin_id, 9, 1.0, 'meal', 'Vegan brunch', -2.5, 20, '', NOW() - INTERVAL '5 days', NOW(), false),
    (admin_id, 9, 1.0, 'meal', 'Vegan salad', -2.5, 20, 'Cafe', NOW() - INTERVAL '9 days', NOW(), false),
    (admin_id, 9, 1.0, 'meal', 'Tofu stir fry', -2.5, 20, '', NOW() - INTERVAL '16 days', NOW(), false),

    -- Vegetarian Meal (TypeId=10, -1.5 CO2, 15pts)
    (admin_id, 10, 1.0, 'meal', 'Veggie burger', -1.5, 15, 'Restaurant', NOW() - INTERVAL '1 day', NOW(), false),
    (admin_id, 10, 1.0, 'meal', 'Paneer curry', -1.5, 15, '', NOW() - INTERVAL '3 days', NOW(), false),
    (admin_id, 10, 1.0, 'meal', 'Pasta primavera', -1.5, 15, '', NOW() - INTERVAL '6 days', NOW(), false),
    (admin_id, 10, 1.0, 'meal', 'Dal rice', -1.5, 15, '', NOW() - INTERVAL '10 days', NOW(), false),
    (admin_id, 10, 1.0, 'meal', 'Vegetable soup', -1.5, 15, '', NOW() - INTERVAL '19 days', NOW(), false),

    -- Local Produce (TypeId=11, -0.5 CO2, 10pts)
    (admin_id, 11, 1.0, 'purchase', 'Farmers market veggies', -0.5, 10, 'Farmers Market', NOW() - INTERVAL '4 days', NOW(), false),
    (admin_id, 11, 1.0, 'purchase', 'Local fruits', -0.5, 10, 'Local Store', NOW() - INTERVAL '11 days', NOW(), false),

    -- Meat-based Meal (TypeId=13, 3.3 CO2, 0pts) - emitting
    (admin_id, 13, 1.0, 'meal', 'Chicken dinner', 3.3, 0, '', NOW() - INTERVAL '2 days', NOW(), false),
    (admin_id, 13, 1.0, 'meal', 'BBQ lunch', 3.3, 0, '', NOW() - INTERVAL '8 days', NOW(), false),
    (admin_id, 13, 1.0, 'meal', 'Burger', 3.3, 0, 'Fast Food', NOW() - INTERVAL '14 days', NOW(), false),

    -- Energy activities
    -- Solar Energy (TypeId=14, -1.5 CO2/kWh, 20pts)
    (admin_id, 14, 5.0, 'kWh', 'Solar panel output', -7.5, 20, 'Home', NOW() - INTERVAL '1 day', NOW(), false),
    (admin_id, 14, 4.0, 'kWh', 'Solar energy', -6.0, 20, 'Home', NOW() - INTERVAL '5 days', NOW(), false),
    (admin_id, 14, 6.0, 'kWh', 'Sunny day solar', -9.0, 20, 'Home', NOW() - INTERVAL '12 days', NOW(), false),

    -- LED Lighting (TypeId=15, -0.05 CO2/hr, 5pts)
    (admin_id, 15, 8.0, 'hours', 'LED lights all day', -0.4, 5, 'Home', NOW() - INTERVAL '1 day', NOW(), false),
    (admin_id, 15, 10.0, 'hours', 'LED office lights', -0.5, 5, 'Office', NOW() - INTERVAL '6 days', NOW(), false),

    -- Air Dry Laundry (TypeId=16, -2.4 CO2/load, 10pts)
    (admin_id, 16, 1.0, 'load', 'Air dried clothes', -2.4, 10, 'Home', NOW() - INTERVAL '3 days', NOW(), false),
    (admin_id, 16, 1.0, 'load', 'Line drying', -2.4, 10, 'Home', NOW() - INTERVAL '10 days', NOW(), false),

    -- Recycling activities
    -- Recycling (TypeId=18, -0.5 CO2/kg, 10pts)
    (admin_id, 18, 3.0, 'kg', 'Paper and cardboard', -1.5, 10, 'Recycling Center', NOW() - INTERVAL '2 days', NOW(), false),
    (admin_id, 18, 2.0, 'kg', 'Plastic bottles', -1.0, 10, '', NOW() - INTERVAL '7 days', NOW(), false),
    (admin_id, 18, 4.0, 'kg', 'Mixed recycling', -2.0, 10, 'Home', NOW() - INTERVAL '15 days', NOW(), false),

    -- Composting (TypeId=19, -0.3 CO2/kg, 10pts)
    (admin_id, 19, 2.0, 'kg', 'Kitchen scraps', -0.6, 10, 'Garden', NOW() - INTERVAL '1 day', NOW(), false),
    (admin_id, 19, 1.5, 'kg', 'Food waste composting', -0.45, 10, 'Garden', NOW() - INTERVAL '5 days', NOW(), false),

    -- Water activities
    -- Short Shower (TypeId=22, -0.1 CO2/shower, 5pts)
    (admin_id, 22, 1.0, 'shower', '5 min shower', -0.1, 5, 'Home', NOW() - INTERVAL '1 day', NOW(), false),
    (admin_id, 22, 1.0, 'shower', 'Quick shower', -0.1, 5, 'Home', NOW() - INTERVAL '2 days', NOW(), false),
    (admin_id, 22, 1.0, 'shower', 'Short shower', -0.1, 5, 'Home', NOW() - INTERVAL '4 days', NOW(), false),
    (admin_id, 22, 1.0, 'shower', 'Eco shower', -0.1, 5, 'Home', NOW() - INTERVAL '6 days', NOW(), false);

    -- ============================================
    -- INSERT DAILY SCORES (past 30 days)
    -- ============================================
    INSERT INTO "DailyScores" ("UserId", "Date", "Score", "CO2Emitted", "CO2Saved", "Steps")
    VALUES
    (admin_id, (NOW() - INTERVAL '1 day')::date,  85, 4.8,  16.5, 8500),
    (admin_id, (NOW() - INTERVAL '2 days')::date, 72, 6.6,  7.6,  6200),
    (admin_id, (NOW() - INTERVAL '3 days')::date, 78, 4.8,  6.3,  7800),
    (admin_id, (NOW() - INTERVAL '4 days')::date, 65, 0.0,  3.1,  5500),
    (admin_id, (NOW() - INTERVAL '5 days')::date, 80, 0.0,  11.5, 7200),
    (admin_id, (NOW() - INTERVAL '6 days')::date, 60, 0.0,  0.5,  4800),
    (admin_id, (NOW() - INTERVAL '7 days')::date, 55, 7.68, 4.28, 3500),
    (admin_id, (NOW() - INTERVAL '8 days')::date, 70, 0.0,  2.5,  6000),
    (admin_id, (NOW() - INTERVAL '9 days')::date, 75, 0.0,  4.5,  7500),
    (admin_id, (NOW() - INTERVAL '10 days')::date, 68, 0.0, 3.0,  5200),
    (admin_id, (NOW() - INTERVAL '11 days')::date, 50, 2.88, 0.0, 3000),
    (admin_id, (NOW() - INTERVAL '12 days')::date, 82, 0.89, 11.0, 8000),
    (admin_id, (NOW() - INTERVAL '13 days')::date, 62, 1.44, 1.5, 4500),
    (admin_id, (NOW() - INTERVAL '14 days')::date, 58, 0.0,  3.3, 4000),
    (admin_id, (NOW() - INTERVAL '15 days')::date, 73, 0.0,  4.0, 6800),
    (admin_id, (NOW() - INTERVAL '16 days')::date, 77, 0.0,  2.5, 7000),
    (admin_id, (NOW() - INTERVAL '17 days')::date, 45, 0.0,  0.0, 2500),
    (admin_id, (NOW() - INTERVAL '18 days')::date, 48, 5.76, 0.0, 2800),
    (admin_id, (NOW() - INTERVAL '19 days')::date, 70, 0.0,  1.5, 6000),
    (admin_id, (NOW() - INTERVAL '20 days')::date, 65, 0.0,  2.0, 5500),
    (admin_id, (NOW() - INTERVAL '21 days')::date, 55, 0.0,  0.0, 3200),
    (admin_id, (NOW() - INTERVAL '22 days')::date, 60, 0.0,  0.0, 4000),
    (admin_id, (NOW() - INTERVAL '23 days')::date, 72, 0.0,  3.0, 6500),
    (admin_id, (NOW() - INTERVAL '24 days')::date, 68, 0.0,  1.5, 5800),
    (admin_id, (NOW() - INTERVAL '25 days')::date, 42, 3.84, 0.0, 2200),
    (admin_id, (NOW() - INTERVAL '26 days')::date, 58, 0.0,  0.5, 4200),
    (admin_id, (NOW() - INTERVAL '27 days')::date, 63, 0.0,  2.0, 5000),
    (admin_id, (NOW() - INTERVAL '28 days')::date, 75, 0.0,  4.5, 7200),
    (admin_id, (NOW() - INTERVAL '29 days')::date, 52, 0.0,  0.0, 3400),
    (admin_id, (NOW() - INTERVAL '30 days')::date, 60, 0.0,  1.0, 4500);

    -- ============================================
    -- UPDATE USER ECO STATS
    -- ============================================
    UPDATE "AspNetUsers"
    SET
        "EcoScore" = 685,
        "TotalCO2Saved" = 62.5,
        "CurrentStreak" = 5,
        "LongestStreak" = 12,
        "Level" = 4,
        "ExperiencePoints" = 685,
        "LastActivityDate" = (NOW() - INTERVAL '1 day')::date
    WHERE "Id" = admin_id;

    RAISE NOTICE 'Successfully seeded data for admin@eco.com (ID: %)', admin_id;
END $$;
