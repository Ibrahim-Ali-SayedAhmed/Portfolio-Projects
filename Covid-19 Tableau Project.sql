## Data source link: https://drive.google.com/drive/folders/1v8D8T-JQ85Xtbkxo8_ff7KIAXtP1qw0e?usp=drive_link
## Dashboard link: https://public.tableau.com/app/profile/ibrahim.ali2761/viz/Covid-19TableauProject_16985316887680/Dashboard1
    
-- Queries used for the Tableau project 

-- 1. Global Numbers of the Pandemic all over the world


SELECT 
    SUM(dea.new_cases) AS total_new_cases,
    SUM(vac.new_vaccinations) AS total_new_vaccinations,
    SUM(dea.new_deaths) AS total_new_deaths,
    (SUM(dea.new_deaths) / SUM(dea.new_cases)) * 100 AS death_percentage
FROM
    covid_deaths dea
        JOIN
    covid_vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
    

-- 2. Showing continents with death count per population

SELECT 
    continent, SUM(new_deaths) AS total_death_count
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


-- 3. Looking at countries with highest infection rates compared to populations

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


-- 4. Looking at countries with highest infection rates compared to populations per date

SELECT 
    location,
    population,
    date,
    MAX(total_cases) AS highest_infection_count,
    MAX((total_cases / population)) * 100 AS highest_percent_population_infected
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY location , population , date
ORDER BY highest_percent_population_infected DESC;

