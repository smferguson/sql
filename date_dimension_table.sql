-- postgresql-specific
CREATE TABLE date_dimension (
    date_id serial primary key,
    day_of_month int NOT NULL,
    day_name varchar(255) NOT NULL,
    day_of_week int NOT NULL,
    month int NOT NULL,
    month_name varchar(255) NOT NULL,
    year int NOT NULL,
    quarter int NOT NULL,
    full_date_yyyymmdd varchar(255) NOT NULL,
    full_date_mmddyyyy varchar(255) NOT NULL,
    month_year varchar(255) NOT NULL,
    year_month varchar(255) NOT NULL,
    weekday_indicator varchar(255) NOT NULL
);


INSERT INTO date_dimension
    (day_of_month,
        day_name,
        day_of_week,
        month,
        month_name,
        year,
        quarter,
        full_date_yyyymmdd,
        full_date_mmddyyyy,
        month_year,
        year_month,
        weekday_indicator)
SELECT date_part('day', day) AS day_of_month,
    to_char(day, 'Day') AS day_name,
    EXTRACT(DOW FROM day) AS day_of_week,
    EXTRACT('month' FROM day) AS month,
    rtrim(to_char(day, 'Month')) AS month_name,
    date_part('year', day) AS year,
    EXTRACT(QUARTER FROM day) AS quarter,
    to_char(day, 'YYYYMMDD') AS full_date_yyyymmdd,
    to_char(day, 'MMDDYYYY') AS full_date_mmddyyyy,
    to_char(day, 'MMYYYY') AS mmyyyy,
    to_char(day, 'YYYYMM') AS yyyymm,
    CASE
        WHEN date_part('isodow', day) IN (6, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS weekend_weekday
FROM
    generate_series('2001-01-01'::date, '2020-12-31'::date, '1 day') day;
