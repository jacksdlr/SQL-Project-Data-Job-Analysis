/* 
 Identify top paying data analyst jobs:
 - Top 10 highest yearly salaries for remote or UK roles
 - Only retrieve jobs with specified (non-null) salaries
 - Done to highlight top paying opportunities and offer insights
 */
SELECT
    job_id,
    job_title,
    company_dim.name AS company_name,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date :: DATE
FROM
    job_postings_fact
    LEFT JOIN company_dim ON company_dim.company_id = job_postings_fact.company_id
WHERE
    job_title_short = 'Data Analyst'
    AND (
        job_work_from_home = TRUE
        OR job_location = 'Anywhere' -- Use OR to cover bases
        OR job_location = 'United Kingdom'
    )
    AND salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT
    10