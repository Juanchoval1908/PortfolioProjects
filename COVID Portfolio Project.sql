--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4


-- Select Data that we're going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Show the likelihood of dying if you contract the Covid in your conuntry

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1, 2	

-- Total Cases vs Population
-- What percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1, 2

-- What Country have the highest infection rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount
, Max((total_cases/population))*100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentOfPopulationInfected desc

-- Showing the countries with the highest decease count per population
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- LET'S BREAKE THINGS DOWN BY CONTINENT


-- Showing the continent with the highest death count

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- What Continent have the highest infection rate compared to Population
SELECT continent, Max(cast(total_cases as int)) as TotalCasesCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalCasesCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2	


-- TotalCases
SELECT SUM(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


-- Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- ROLLING COUNT

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- USING CTE

WITH CTE_PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM CTE_PopVsVac
ORDER BY 2, 3

-- USING TEMP TABLES

--DROP TABLE IF EXISTS #temp_PercentPopulationVaccinated
CREATE TABLE #temp_PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #temp_PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #temp_PercentPopulationVaccinated
ORDER BY 2, 3

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated