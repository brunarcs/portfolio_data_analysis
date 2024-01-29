--Covid Deaths exploratory analysis
--Data selection 
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths$
order by 1,2

--Comparison of total deaths and total cases
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
Where location like '%Brazil%'
order by 1,2

--Comparison of total cases and population
SELECT Location,date,total_cases,population,(total_cases/population)*100 as CasesPercentage
FROM CovidDeaths$
Where location like '%Brazil%'
order by 1,2

--Comparison of total deaths and population
SELECT Location,date,total_deaths,population,(total_deaths/population)*100 as DeathPercentage
FROM CovidDeaths$
Where location like '%Brazil%'
order by 1,2

--Countries with highest infection rate compared to population
SELECT Location,population,MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PopulationInfectedPercentage
FROM CovidDeaths$
Group by location,population
order by PopulationInfectedPercentage Desc

--Countries with highest death count per population
SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount Desc

--Analysis per continent

-- Continents with highest death count
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount Desc

-- GLOBAL NUMBERS
-- General
SELECT SUM(new_cases) as TotalCases ,SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths$
Where continent is not null
order by 1,2

-- Per date
SELECT date, SUM(new_cases) as TotalCases ,SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths$
Where continent is not null
group by date
order by 1,2

--Covid Vacinations overview
SELECT *
FROM CovidVaccinations$

--Joining tables
SELECT *
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Comparing population and vaccinations

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingCountVaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingCountVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingCountVaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingCountVaccinations/Population)*100 as RateOfVaccination
From PopvsVac

--- Creating View
Create View VaccinatedPeople as
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingCountVaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null