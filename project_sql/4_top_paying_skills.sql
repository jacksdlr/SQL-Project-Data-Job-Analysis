/* 
 Top skills based on salary:
 - Gather the average salaries for each skill required for data analyst positions
 - Focus on roles matching salary requirements, regardless of job location
 - This will reveal how different skills impact salaries for data analyst roles and help identify the most financially rewarding skills to persue and learn
 */
SELECT
    skills AS skill_name,
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
    skill_name
ORDER BY
    average_yearly_salary DESC
LIMIT
    25