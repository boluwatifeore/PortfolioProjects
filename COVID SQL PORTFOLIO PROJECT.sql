SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4

-- Select the data we are going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT Location, Date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT Location, Date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

SELECT Location, Date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1,2

SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population

SELECT Location, MAX(total_deaths) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
GROUP BY Location
ORDER BY TotalDeathCount desc

SELECT Location, MAX(cast(total_deaths as int) ) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Let's break things down by continent

SELECT continent, MAX(cast(total_deaths as int) ) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

SELECT location, MAX(cast(total_deaths as int) ) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
where continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Showing Continents with the Highest Death Count Per Population

SELECT continent, MAX(cast(total_deaths as int) ) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers

SELECT Location, Date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2

SELECT Date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by date
ORDER BY 1,2

SELECT Date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(Cast(New_deaths as int))/
SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(Cast(New_deaths as int))/
SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2


-- Looking at Total Population vs Vaccination

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location
and dea.date= vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated) as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location
and dea.date= vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.Location order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated








