--Checking the entries on both tables

Select top 1000 *
from PortfolioProject1..CovidDeaths
where continent != '' 
order by date

Select top 100 *
from PortfolioProject1..CovidVaccinations
order by location, date

-----------------------------------------------------------------------------------------------
------------------- DATA PREPARATION ---------------------------------------------------------
-----------------------------------------------------------------------------------------------

---------------------
---- HANDLING DATE DATA

---- 1- Identify the current data type for date column
--Select COLUMN_NAME, DATA_TYPE
--from INFORMATION_SCHEMA.COLUMNS
--where TABLE_NAME = 'CovidDeaths' and COLUMN_NAME = 'date'
---- Result is varchar data type

---- 2- Convert the data type to date
--Select TRY_CONVERT(date, date, 103) AS ConvertedDate
--from PortfolioProject1..CovidDeaths

---- 3- Identify rows with conversion issues
--select CovidDeaths.date
--from CovidDeaths
--where TRY_CONVERT(date, date, 103) is null
---- Result is none

---- 4- Update the column type 
--alter table CovidDeaths add DateTemp DATE

--update CovidDeaths
--set DateTemp = TRY_CONVERT(DATE, date, 103)

--alter table CovidDeaths
--drop column date;

--exec sp_rename 'CovidDeaths.DateTemp', 'date', 'column'

---- Repeating the same steps fot the CovidVaccinations table

--Select COLUMN_NAME, DATA_TYPE
--from INFORMATION_SCHEMA.COLUMNS
--where TABLE_NAME = 'CovidVaccinations' and COLUMN_NAME = 'date'

--Select TRY_CONVERT(date, date, 103) AS ConvertedDate
--from PortfolioProject1..CovidVaccinations

--select CovidVaccinations.date
--from CovidVaccinations
--where TRY_CONVERT(date, date, 103) is null

--alter table CovidVaccinations add DateTemp DATE

--update CovidVaccinations
--set DateTemp = TRY_CONVERT(DATE, date, 103)

--alter table CovidVaccinations
--drop column date;

--exec sp_rename 'CovidVaccinations.DateTemp', 'date', 'column'

---------------------
---- HANDLING NUMBER DATA

---- 1- Identify the current data type for date column
--Select COLUMN_NAME, DATA_TYPE
--from INFORMATION_SCHEMA.COLUMNS
--where TABLE_NAME = 'CovidDeaths' and COLUMN_NAME = 'total_cases'
---- Result is varchar data type

---- 2- Convert the data type to FLOAT
--Select TRY_CONVERT(FLOAT, total_cases) AS ConvertedTotal_Cases
--from PortfolioProject1..CovidDeaths

---- 3- Identify rows with conversion issues
--select CovidDeaths.total_cases
--from CovidDeaths
--where TRY_CONVERT(FLOAT, total_cases) is null
---- Result is none

---- 4- Update the column type 
--alter table CovidDeaths add Total_CasesTemp FLOAT

--update CovidDeaths
--set Total_CasesTemp = TRY_CONVERT(FLOAT, total_cases)

--alter table CovidDeaths
--drop column total_cases;

--exec sp_rename 'CovidDeaths.Total_CasesTemp', 'total_cases', 'column'

---- Repeating the same steps fot the total_deaths

---- 1- Identify the current data type for date column
--Select COLUMN_NAME, DATA_TYPE
--from INFORMATION_SCHEMA.COLUMNS
--where TABLE_NAME = 'CovidDeaths' and COLUMN_NAME = 'total_deaths'
---- Result is varchar data type

---- 2- Convert the data type to FLOAT
--Select TRY_CONVERT(FLOAT, total_deaths) AS Total_DeathsTemp
--from PortfolioProject1..CovidDeaths

---- 3- Identify rows with conversion issues
--select CovidDeaths.total_deaths
--from CovidDeaths
--where TRY_CONVERT(FLOAT, total_deaths) is null
---- Result is none

---- 4- Update the column type 
--alter table CovidDeaths add Total_DeathsTemp FLOAT

--update CovidDeaths
--set Total_DeathsTemp = TRY_CONVERT(FLOAT, total_deaths)

--alter table CovidDeaths
--drop column total_deaths;

--exec sp_rename 'CovidDeaths.Total_DeathsTemp', 'total_deaths', 'column'



-----------------------------------------------------------------------------------------------
------------------- DATA EXPLORATION ---------------------------------------------------------
-----------------------------------------------------------------------------------------------

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths
order by location, date

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where total_cases > 0 and total_deaths > 0 and location like '%states%'
order by location, date


-- Looking at the Total Cases vs Population
-- Shows what the percent of the population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
where total_cases > 0 and total_deaths > 0 
and location like '%states%'
order by location, date

-- Looking at the Countries with highest infection rate compared to population
----- The problem here is that people gets infected more than one
Select location, population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
where total_cases > 0 and total_deaths > 0 
and continent != ''
group by location, population
order by PercentPopulationInfected desc

-- Looking at the Countries with highest death count per population
Select location, max(total_deaths) as TotalDeathsCount
from PortfolioProject1..CovidDeaths
where total_deaths > 0 
and continent != ''
group by location
order by TotalDeathsCount desc

-- Looking at the Countries with highest death count per population
Select location, max(total_deaths) as TotalDeathsCount
from PortfolioProject1..CovidDeaths
where total_deaths > 0 
and continent != ''
group by location
order by TotalDeathsCount desc


-- LETS BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

-- Thats the right way
Select location, max(total_deaths) as TotalDeathsCount
from PortfolioProject1..CovidDeaths
where total_deaths > 0 
and continent = ''
group by location
order by TotalDeathsCount desc

-- Thats the wrong way
Select continent, max(total_deaths) as TotalDeathsCount
from PortfolioProject1..CovidDeaths
where total_deaths > 0 
and continent != ''
group by continent
order by TotalDeathsCount desc


-- GLOBAL NUMBERS

-- Looking at the Total Cases vs Total Deaths

Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where continent != '' and new_cases != 0
group by date
order by date

Select  SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where continent != '' and new_cases != 0
--and date < '2021-01-11 00:00:00.000' and date > '2020-02-01 00:00:00.000'



-- Both tables joined
Select *
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) as CumulativeVaccinations
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
and vac.new_vaccinations != 0
order by dea.location, dea.date

-- USE CTE (common table expression)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinations --, (CumulativeVaccinations/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
and vac.new_vaccinations != 0
--order by 2,3
)
Select *, (CumulativeVaccinations/Population)*100 
from PopvsVac


-- USE TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativeVaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinations --, (CumulativeVaccinations/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
and vac.new_vaccinations != 0
--order by 2,3

Select *, (CumulativeVaccinations/Population)*100 
from #PercentPopulationVaccinated




-- Creating views to store data for later vizualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinations --, (CumulativeVaccinations/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
and vac.new_vaccinations != 0
--order by 2,3

Select *
from PortfolioProject1..PercentPopulationVaccinated

