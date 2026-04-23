-- Seed 5 eco-challenges into the Challenges table.
-- Safe to run repeatedly: only inserts rows whose Title does not already exist.
-- PostgreSQL dialect (matches the InitialPostgres migration schema).

INSERT INTO "Challenges" (
    "Title",
    "Description",
    "ChallengeType",
    "TargetActivityTypeId",
    "TargetCategoryId",
    "TargetValue",
    "TargetUnit",
    "PointsReward",
    "BadgeRewardId",
    "StartDate",
    "EndDate",
    "IsActive"
)
SELECT * FROM (VALUES
    (
        'Plastic-Free Week',
        'Avoid single-use plastics for 7 days. Log every plastic-free meal, coffee, or shopping trip.',
        'weekly',
        NULL::int, NULL::int,
        7.0, 'days',
        150, NULL::int,
        (NOW() AT TIME ZONE 'UTC'),
        (NOW() AT TIME ZONE 'UTC') + INTERVAL '7 days',
        TRUE
    ),
    (
        'Green Commuter',
        'Walk, cycle, or use public transport instead of driving. Target 50 km of low-carbon travel.',
        'weekly',
        NULL, NULL,
        50.0, 'km',
        200, NULL,
        (NOW() AT TIME ZONE 'UTC'),
        (NOW() AT TIME ZONE 'UTC') + INTERVAL '14 days',
        TRUE
    ),
    (
        'Meatless Monday x4',
        'Skip meat every Monday for a month. Each plant-based Monday counts as 1.',
        'monthly',
        NULL, NULL,
        4.0, 'meatless days',
        250, NULL,
        (NOW() AT TIME ZONE 'UTC'),
        (NOW() AT TIME ZONE 'UTC') + INTERVAL '30 days',
        TRUE
    ),
    (
        'Energy Saver',
        'Cut 20 kWh of home electricity use vs last week through mindful consumption.',
        'weekly',
        NULL, NULL,
        20.0, 'kWh',
        180, NULL,
        (NOW() AT TIME ZONE 'UTC'),
        (NOW() AT TIME ZONE 'UTC') + INTERVAL '7 days',
        TRUE
    ),
    (
        'Zero-Waste Hero',
        'Reduce household waste to under 2 kg across 14 days by recycling and composting.',
        'monthly',
        NULL, NULL,
        2.0, 'kg waste',
        300, NULL,
        (NOW() AT TIME ZONE 'UTC'),
        (NOW() AT TIME ZONE 'UTC') + INTERVAL '14 days',
        TRUE
    )
) AS v(
    "Title", "Description", "ChallengeType",
    "TargetActivityTypeId", "TargetCategoryId",
    "TargetValue", "TargetUnit",
    "PointsReward", "BadgeRewardId",
    "StartDate", "EndDate", "IsActive"
)
WHERE NOT EXISTS (
    SELECT 1 FROM "Challenges" c WHERE c."Title" = v."Title"
);

-- Verify
SELECT "Id", "Title", "ChallengeType", "TargetValue", "TargetUnit", "PointsReward", "IsActive"
FROM "Challenges"
ORDER BY "Id";
