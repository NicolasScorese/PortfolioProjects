--Load data from tables
SELECT *
FROM Sample_Project..['CovidDeaths']
ORDER BY 3,4

SELECT *
FROM Sample_Project..['CovidVaccinations']
ORDER BY 3,4

--Load just specific data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Sample_Project..['CovidDeaths']
ORDER BY 1,2


--Total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (CONVERT(FLOAT,total_deaths)/NULLIF(CONVERT(FLOAT,total_cases),0))*100 AS DeathPercent
FROM Sample_Project..['CovidDeaths']
WHERE location = 'United States'
ORDER BY 1,2

--Total cases vs population
--Shows % of population was infected with covid
SELECT location, date, total_cases, population, (CONVERT(FLOAT,total_cases)/NULLIF(CONVERT(FLOAT,population),0))*100 AS InfectionPercent
FROM Sample_Project..['CovidDeaths']
WHERE location = 'United States'
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CONVERT(FLOAT,total_cases)/NULLIF(CONVERT(FLOAT,population),0)))*100 AS InfectionPercent
FROM Sample_Project..['CovidDeaths']
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY InfectionPercent DESC


--COUNTRIES with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Sample_Project..['CovidDeaths']
--WHERE location = 'United States'
WHERE Continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--CONTINENT with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Sample_Project..['CovidDeaths']
--WHERE location = 'United States'
WHERE Continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS - new cases per deaths per day line 54
SELECT date, SUM(new_cases) AS Cases, SUM(CAST(new_deaths AS INT)) AS Deaths, 
		CASE
			WHEN SUM(new_cases) = 0 THEN 0
			ELSE SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100
		END AS DeathPercent
FROM Sample_Project..['CovidDeaths']
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS - total death percent, all dates combined
SELECT SUM(new_cases) AS Cases, SUM(CAST(new_deaths AS INT)) AS Deaths, 
		CASE
			WHEN SUM(new_cases) = 0 THEN 0
			ELSE SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100
		END AS DeathPercent
FROM Sample_Project..['CovidDeaths']
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



--Total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
--,(PeopleVaccinated/population)*100
FROM Sample_Project..['CovidDeaths'] dea
JOIN Sample_Project..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE version
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(PeopleVaccinated/population)*100
FROM Sample_Project..['CovidDeaths'] dea
JOIN Sample_Project..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPercentVaccinated
FROM PopVsVac
ORDER BY 2,3


--Use Temp Table version
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date DATETIME,
population numeric,
new_vaccintations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(PeopleVaccinated/population)*100
FROM Sample_Project..['CovidDeaths'] dea
JOIN Sample_Project..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPercentVaccinated
FROM #PercentPopulationVaccinated
ORDER BY 2,3


--CERATE VIEW to store data for later visualizations

CREATE VIEW PercentPopulationVacciniated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(PeopleVaccinated/population)*100
FROM Sample_Project..['CovidDeaths'] dea
JOIN Sample_Project..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVacciniated