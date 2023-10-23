USE covid_19;

select * from covid_deaths order by 3,4;
select * from covid_vaccinations order by 3,4;


# Select Data that we are going to be using

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;


# Total cases vs. Total Deaths
-- shows the likelihood if you contract covid at your country

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS death_percentage
FROM
    covid_deaths
WHERE
    location LIKE '%Egypt%'
        AND continent IS NOT NULL
ORDER BY location , date;



# Total cases vs. population
-- Shows what percentage of population got Covid

SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS percent_population_infected
FROM
    covid_deaths
#WHERE
    #location LIKE '%Egypt%'
WHERE
    continent IS NOT NULL
ORDER BY location , date;


# Looking at countries with highest infection rates compared to populations

SELECT 
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX((total_cases / population)) * 100 AS highest_percent_population_infected
FROM
    covid_deaths
#WHERE
    #location LIKE '%Egypt%'
WHERE
    continent IS NOT NULL
GROUP BY location , population
ORDER BY highest_percent_population_infected DESC;


# Showing countries with highest death count per population

SELECT 
    location, MAX(total_deaths) AS highest_death_count
FROM
    covid_deaths
#WHERE
    #location LIKE '%Egypt%'
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC;


# LET'S BREAK THINGS DOWN BY CONTINENTS
# Showing continents with the highest death count per population

SELECT 
    continent, MAX(total_deaths) AS highest_death_count
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC;


# Global Numbers

SELECT 
    date,
    SUM(new_cases) AS total_new_cases,
    SUM(new_deaths) AS total_new_deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM
    covid_deaths
#WHERE
    #location LIKE '%Egypt%'
WHERE
    continent IS NOT NULL
GROUP BY date
ORDER BY date;

SELECT 
    SUM(new_cases) AS total_new_cases,
    SUM(new_deaths) AS total_new_deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM
    covid_deaths
#WHERE
    #location LIKE '%Egypt%'
WHERE
    continent IS NOT NULL;
    
    
# Looking at total populations vs. total vaccinations

-- CTE

WITH pop_vs_vac AS ( 
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER new_vac AS rolling_people_vaccinated
FROM
    covid_deaths dea
        JOIN
    covid_vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
WINDOW new_vac AS (PARTITION BY dea.location ORDER BY dea.location, dea.date)
ORDER BY dea.location, dea.date)

SELECT 
    *,
    (rolling_people_vaccinated / population) * 100 AS percent_population_vaccinated
FROM
    pop_vs_vac;

    
-- TEMP TABLE

DROP TEMPORARY TABLE IF EXISTS percent_population_vaccinated;
    
CREATE TEMPORARY TABLE percent_population_vaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER new_vac AS rolling_people_vaccinated
FROM
    covid_deaths dea
        JOIN
    covid_vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
WINDOW new_vac AS (PARTITION BY dea.location ORDER BY dea.location, dea.date)
ORDER BY dea.location, dea.date;

SELECT 
    *,
    (rolling_people_vaccinated / population) * 100 AS percent_population_vaccinated
FROM
    percent_population_vaccinated;


-- Creating View to store data for later visualization

CREATE VIEW percent_population_vaccinated AS 
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER new_vac AS rolling_people_vaccinated
FROM
    covid_deaths dea
        JOIN
    covid_vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
WINDOW new_vac AS (PARTITION BY dea.location ORDER BY dea.location, dea.date)
ORDER BY dea.location, dea.date;

SELECT 
    *
FROM
    percent_population_vaccinated;
    
        
        
## Creating a procedure showing the pandemic statistics per location

DELIMITER $$
CREATE PROCEDURE location_statistics (IN p_location VARCHAR(50))
BEGIN
WITH covid_statistics_per_location AS
(SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    SUM(dea.total_cases) OVER w AS total_cases,
    SUM(dea.total_deaths) OVER w AS total_deaths,
    SUM(vac.total_vaccinations) OVER w AS total_vaccinations
FROM
    covid_deaths dea
        JOIN
    covid_vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WINDOW w AS (PARTITION BY dea.location ORDER BY dea.location, dea.date)
ORDER BY dea.location , dea.date)

SELECT 
    *,
    (total_cases / population) * 100 AS percent_population_infected,
    (total_deaths / population) * 100 AS death_percentage,
    (total_vaccinations / population) * 100 AS vaccination_percentage
FROM
    covid_statistics_per_location
WHERE
    location = p_location;
END$$
DELIMITER ;
    

CALL location_statistics ('Egypt');