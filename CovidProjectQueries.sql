SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

--Select data that we are going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows chance of mortality when contracting COVID in United States
SELECT Location, Date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location LIKE '%states%'
WHERE continent is not null
ORDER BY 1, 2


-- Looking at Total Cases vs Population
-- Shows percentage of population that have been infected
SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate compare to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS MaxInfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY MaxInfectionPercentage desc


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
Group By Location
ORDER BY TotalDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

-- This was indicated as the truly correct query
--SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
--FROM PortfolioProject.dbo.CovidDeaths
----WHERE Location LIKE '%states%'
--WHERE continent is null
--Group By location
--ORDER BY TotalDeathCount desc


-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
Group By continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS
-- by date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
--total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE Location LIKE '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Overall total

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
--total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE Location LIKE '%states%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location,
  dea.date) AS RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3



-- USE CTE

With PopVsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location,
  dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
From PopVsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location,
  dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location,
  dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3


Select *
From PercentPopulationVaccinated