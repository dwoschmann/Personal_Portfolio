SELECT
    Id,
    COUNT(ActivityDate) AS num_workouts,
    ROUND(AVG(steps_db1), 2) AS avg_steps_db1,
    ROUND(AVG(distance_db1), 2) AS avg_distance_db1,
    ROUND(AVG(very_active_minutes_db1), 2) AS avg_very_active_minutes_db1,
    ROUND(AVG(sedentary_minutes_db1), 2) AS avg_sedentary_minutes_db1,
    ROUND(AVG(steps_db2), 2) AS avg_steps_db2,
    ROUND(AVG(distance_db2), 2) AS avg_distance_db2,
    ROUND(AVG(very_active_minutes_db2), 2) AS avg_very_active_minutes_db2,
    ROUND(AVG(sedentary_minutes_db2), 2) AS avg_sedentary_minutes_db2
FROM (
    SELECT
        activity_1.Id AS Id,
        activity_1.ActivityDate AS ActivityDate,
        activity_1.TotalSteps AS steps_db1,
        activity_1.TotalDistance AS distance_db1,
        activity_1.VeryActiveMinutes AS very_active_minutes_db1,
        activity_1.SedentaryMinutes AS sedentary_minutes_db1,
  
        activity_2.ActivityDate AS date2,
        activity_2.TotalSteps AS steps_db2,
        activity_2.TotalDistance AS distance_db2,
        activity_2.VeryActiveMinutes AS very_active_minutes_db2,
        activity_2.SedentaryMinutes AS sedentary_minutes_db2
    FROM
        `Fitabase_Data_31216_41116.daily_activity` AS activity_1
    JOIN
        `Fitabase_Data_41216_51216.daily_activity` AS activity_2
    ON
        activity_1.Id = activity_2.Id
) AS combined_data
GROUP BY Id
