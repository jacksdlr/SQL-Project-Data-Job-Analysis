/* Get the average yearly salary for each job schedule type of jobs posted after 2023-06-01 */
SELECT
    AVG(salary_year_avg) AS average_yearly_salary,
    AVG(salary_hour_avg) AS average_hourly_salary,
    job_schedule_type
FROM
    job_postings_fact
WHERE
    job_posted_date > '2023-06-01'
GROUP BY
    job_schedule_type
ORDER BY
    average_yearly_salary DESC
    /* Count the number of jobs posted in each month of 2023 */
SELECT
    COUNT(job_id) AS jobs_count,
    EXTRACT(
        MONTH
        FROM
            job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
    ) AS month
FROM
    job_postings_fact
WHERE
    EXTRACT(
        YEAR
        FROM
            job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
    ) = 2023
GROUP BY
    month
ORDER BY
    month
    /* Get company names that offer health insurance on jobs posted in the second quarter */
SELECT
    company_dim.name AS company_name
FROM
    job_postings_fact
    LEFT JOIN company_dim ON company_dim.company_id = job_postings_fact.company_id
WHERE
    job_postings_fact.job_health_insurance = TRUE
    AND EXTRACT(
        QUARTER
        FROM
            job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
    ) = 2
GROUP BY
    company_name
    /* Bucketing yearly salaries for data analyst roles */
SELECT
    COUNT(job_id) AS jobs_count,
    CASE
        WHEN salary_year_avg < 50000 THEN 'Low (<$50,000)'
        WHEN salary_year_avg BETWEEN 50000
        AND 100000 THEN 'Standard ($50,000-$100,000)'
        WHEN salary_year_avg > 100000 THEN 'High (>$100,000)'
        ELSE 'No Salary Data'
    END AS yearly_salary
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg > 0
GROUP BY
    yearly_salary
ORDER BY
    jobs_count DESC
    /* Identify top 5 skills most frequently mentioned */
    WITH skills_count AS (
        SELECT
            skill_id,
            COUNT(*) AS jobs_count
        FROM
            skills_job_dim
        GROUP BY
            skill_id
    )
SELECT
    skills AS skill,
    jobs_count
FROM
    skills_dim
    LEFT JOIN skills_count ON skills_count.skill_id = skills_dim.skill_id
ORDER BY
    jobs_count DESC
LIMIT
    5
    /* Bucket companies into size based on number of job postings */
    WITH companies_job_count AS(
        SELECT
            company_id,
            COUNT(*) AS jobs_count
        FROM
            job_postings_fact
        GROUP BY
            company_id
    )
SELECT
    name AS company_name,
    jobs_count,
    CASE
        WHEN jobs_count < 10 THEN 'Small'
        WHEN jobs_count BETWEEN 10
        AND 50 THEN 'Medium'
        WHEN jobs_count > 50 THEN 'Large'
    END AS company_size
FROM
    company_dim
    LEFT JOIN companies_job_count ON companies_job_count.company_id = company_dim.company_id
ORDER BY
    jobs_count DESC
    /* Top 5 skills for remote Data Analyst jobs */
    WITH remote_job_skills AS (
        SELECT
            skill_id,
            COUNT(*) AS skill_count
        FROM
            skills_job_dim AS skills_to_job
            INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
        WHERE
            job_postings.job_work_from_home = TRUE
            AND job_postings.job_title_short = 'Data Analyst'
        GROUP BY
            skill_id
    )
SELECT
    skills AS skill_name,
    skill_count
FROM
    remote_job_skills
    INNER JOIN skills_dim ON skills_dim.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT
    5
    /* Get skills details for Q1 job postings with salary > $70,000 */
    WITH q1_jobs_skills AS (
        SELECT
            q1_jobs.job_id AS job_id,
            job_title_short,
            salary_year_avg,
            skills_job_dim.skill_id
        FROM
            (
                SELECT
                    job_id,
                    job_title_short,
                    salary_year_avg
                FROM
                    jan_jobs_2023
                UNION
                ALL
                SELECT
                    job_id,
                    job_title_short,
                    salary_year_avg
                FROM
                    feb_jobs_2023
                UNION
                ALL
                SELECT
                    job_id,
                    job_title_short,
                    salary_year_avg
                FROM
                    mar_jobs_2023
            ) AS q1_jobs
            LEFT JOIN skills_job_dim ON q1_jobs.job_id = skills_job_dim.job_id
        WHERE
            salary_year_avg > 70000
    )
SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    skills as skill,
    type as skill_type
FROM
    q1_jobs_skills
    LEFT JOIN skills_dim ON q1_jobs_skills.skill_id = skills_dim.skill_id
ORDER BY
    job_id