SELECT *
  FROM `COVID.CovidDeaths`
  ORDER BY 3,4;

SELECT *
  FROM `COVID.CovidVaccines`
  ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM `COVID.CovidDeaths`
  ORDER BY 1,2;



-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  FROM `COVID.CovidDeaths`
  ORDER BY 1,2;


-- Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
  FROM `COVID.CovidDeaths`
  ORDER BY 1,2;


-- Countries with Highest Infection Rate vs Population
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as InfectedPercentage
  FROM `COVID.CovidDeaths`
  GROUP BY location, population
  ORDER BY InfectedPercentage DESC;


-- Countries with Highest Death Count vs Population
SELECT location, MAX(total_deaths) as TotalDeathCount
  FROM `COVID.CovidDeaths`
  WHERE continent is not null
  -- where clause to exlude groupings of countries
  GROUP BY location
  ORDER BY TotalDeathCount DESC;

-- Breakdown by continent
SELECT location, MAX(total_deaths) as TotalDeathCount
  FROM `COVID.CovidDeaths`
  WHERE continent is null
  -- where clause to exlude groupings of countries
  AND location not in ('World', 'European Union', 'International')
  GROUP BY location
  ORDER BY TotalDeathCount DESC;


--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
  FROM `COVID.CovidDeaths`
  WHERE continent IS NOT NULL
  ORDER BY 1,2;


--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccination_total
  FROM `COVID.CovidDeaths` as dea
  JOIN `COVID.CovidVaccines` as vac
    ON dea.location = vac.location
    and dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  ORDER BY 2,3;


-- USE A CTE TO RUN CALCULATIONS WITH RUNNING TOTAL
WITH popvsvac AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
      PARTITION BY dea.location 
      ORDER BY dea.date
    ) AS rolling_vaccination_total
  FROM `COVID.CovidDeaths` AS dea
  JOIN `COVID.CovidVaccines` AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_vaccination_total/population)*100 as vacpercentage
FROM popvsvac;


--CREATING VIEWS
CREATE VIEW COVID.vacpercentage as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccination_total
  FROM `COVID.CovidDeaths` as dea
  JOIN `COVID.CovidVaccines` as vac
    ON dea.location = vac.location
    and dea.date = vac.date
  WHERE dea.continent IS NOT NULL
