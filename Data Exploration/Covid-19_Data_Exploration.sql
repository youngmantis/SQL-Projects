
SELECT * FROM CovidDeaths
--WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * FROM CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM CovidDeaths
WHERE population IS NOT NULL
ORDER BY 1,2

--Total_cases vs Total_deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%nigeria%'
ORDER BY 1,2

--Total_cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
FROM CovidDeaths
WHERE location LIKE '%antigua%'
ORDER BY 1,2

--Countries with highest infection rate vs population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulationPercentage
FROM CovidDeaths
--WHERE location LIKE '%antigua%'
GROUP BY location, population
ORDER BY InfectedPopulationPercentage DESC

--Countries with highest death rate per population

SELECT location, population, MAX(CAST (total_deaths AS INT)) AS TotalDeaths
FROM CovidDeaths
--WHERE location LIKE '%antigua%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeaths DESC

SELECT location, population, MAX(CAST (total_deaths AS INT)) AS TotalDeaths
FROM CovidDeaths
--WHERE location LIKE '%antigua%'
WHERE continent IS NULL
GROUP BY location, population
ORDER BY TotalDeaths DESC

--Continents with highest death rate per population

SELECT continent, population, MAX(CAST (total_deaths AS INT)) AS TotalDeaths
FROM CovidDeaths
--WHERE location LIKE '%antigua%'
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY TotalDeaths DESC

--Global count

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS TotalDeathsPercentPerDay
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS TotalDeathsPercentPerDay
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


SELECT * FROM CovidVaccinations

SELECT * 
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac 
ON
dea.location = vac.location AND
dea.date = vac.date

--Total Population vs Vaccination

SELECT DISTINCT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON
dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

WITH POPvsVAC (continent, location, date, population, new_vaccination, RollingPopulationVaccinated)
AS
(
SELECT DISTINCT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopulationVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON
dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPopulationVaccinated/population)
FROM POPvsVAC

--TEMP TABLE

--DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccination NUMERIC,
RollingPopulationVaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT DISTINCT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopulationVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON
dea.location = vac.location AND
dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPopulationVaccinated/population)
FROM #PercentPopulationVaccinated

--Create view for later visualization
CREATE VIEW PercentPopulationVaccinated AS 
SELECT DISTINCT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopulationVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON
dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated