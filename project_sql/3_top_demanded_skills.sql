/* 
 Most in-demand skills for data analyst roles:
 - Looking at job postings around the world
 - Identify top 5 skills to inform decisions of how time should be best spent and invested in learning new skills
 - Utilising inner joins as in query 2 to match up jobs to with their respective skills
 */
SELECT
    skills AS skill_name,
    COUNT(job_postings_fact.job_id) AS jobs_count
FROM
    job_postings_fact
    INNER JOIN skills_job_dim ON skills_job_dim.job_id = job_postings_fact.job_id
    INNER JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    /* AND (job_work_from_home = TRUE OR job_location = 'United Kingdom') */
GROUP BY
    skill_name
ORDER BY
    jobs_count DESC
LIMIT
    5