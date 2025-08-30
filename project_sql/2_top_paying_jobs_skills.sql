/*
 Extension of first query, looking further into required skills:
 - Using the top 10 highest paying remote or UK data analyst roles
 - Joining with the specific skills required for those roles
 - Helps to provide further insight into most valuable skills for high paying roles, helping job seekers identify which skills to develop that align with desired salaries
 - Additionally, count the number of jobs that use specific skills
 */
WITH top_jobs AS (
    SELECT
        job_id,
        job_title,
        company_dim.name AS company_name,
        salary_year_avg
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
)
SELECT
    top_jobs.*,
    -- comment this out if counting
    skills AS skill_name
    /* , COUNT(top_jobs.job_id) AS jobs_count */
FROM
    top_jobs
    INNER JOIN skills_job_dim ON skills_job_dim.job_id = top_jobs.job_id
    INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
    /* GROUP BY 
     skill_name
     ORDER BY
     jobs_count DESC */