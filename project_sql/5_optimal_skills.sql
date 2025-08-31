/* 
 The most optimal skills to learn (high demand and high paying skills):
 - Combine data to identify skills in high demand and have high average salaries in data analyst roles
 - Looking at remote positions or positions in the UK with specified salaries
 - Once again, revealing relevant skills to learn that will offer job security (can be used across the industry) and financial benefits, offering strategic insights for personal career development
 */
/* */
/* Using CTEs */
WITH skills_demand AS (
    SELECT
        skills_dim.skill_id AS skill_id,
        skills AS skill_name,
        COUNT(job_postings_fact.job_id) AS jobs_count
    FROM
        job_postings_fact
        INNER JOIN skills_job_dim ON skills_job_dim.job_id = job_postings_fact.job_id
        INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst'
        AND (
            job_work_from_home = TRUE
            OR job_location = 'United Kingdom'
        )
    GROUP BY
        skills_dim.skill_id
),
skills_salary AS (
    SELECT
        skills_dim.skill_id AS skill_id,
        ROUND(AVG(salary_year_avg), 0) AS average_yearly_salary
    FROM
        job_postings_fact
        INNER JOIN skills_job_dim ON skills_job_dim.job_id = job_postings_fact.job_id
        INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND (
            job_work_from_home = TRUE
            OR job_location = 'United Kingdom'
        )
    GROUP BY
        skills_dim.skill_id
)
SELECT
    skills_demand.skill_name,
    jobs_count,
    average_yearly_salary
FROM
    skills_demand
    INNER JOIN skills_salary ON skills_salary.skill_id = skills_demand.skill_id
ORDER BY
    jobs_count DESC,
    average_yearly_salary DESC
LIMIT
    25
    /*  */
    /* Without CTEs (different numbers as jobs_count is also filtering those without listed salaries) */
SELECT
    skills_dim.skills AS skill_name,
    COUNT(skills_job_dim.job_id) AS jobs_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS average_yearly_salary
FROM
    job_postings_fact
    INNER JOIN skills_job_dim ON skills_job_dim.job_id = job_postings_fact.job_id
    INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND (
        job_work_from_home = TRUE
        OR job_location = 'United Kingdom'
    )
GROUP BY
    skill_name
ORDER BY
    jobs_count DESC,
    average_yearly_salary DESC
LIMIT
    25