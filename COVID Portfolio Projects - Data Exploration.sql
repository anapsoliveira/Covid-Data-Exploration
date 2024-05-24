/*

First 16 months of COVID-19 cases/deaths/vaccination worldwide 
Dates from 01/01/2020 to 30/04/2021
Public dataset from https://ourworldindata.org/covid-deaths

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--Checking the entries on both tables

Select *
from PortfolioProject1..CovidDeaths
order by date

Select top 1000 *
from PortfolioProject1..CovidDeaths
where continent != '' 
order by date

Select *
from PortfolioProject1..CovidVaccinations
order by location, date

-----------------------------------------------------------------------------------------------
------------------- DATA PREPARATION ---------------------------------------------------------
-----------------------------------------------------------------------------------------------

-----------------------------
---- HANDLING DATE DATA ----

-- 1- Identify the current data type for date column
Select COLUMN_NAME, DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'CovidDeaths' and COLUMN_NAME = 'date'
--Result is varchar data type

-- 2- Convert the data type to date
Select TRY_CONVERT(date, date, 103) AS ConvertedDate
from PortfolioProject1..CovidDeaths

-- 3- Identify rows with conversion issues
select CovidDeaths.date
from CovidDeaths
where TRY_CONVERT(date, date, 103) is null
-- Result is none

-- 4- Update the column type 
alter table CovidDeaths add DateTemp DATE

update CovidDeaths
set DateTemp = TRY_CONVERT(DATE, date, 103)

alter table CovidDeaths
drop column date;

exec sp_rename 'CovidDeaths.DateTemp', 'date', 'column'

-- Repeat the same steps for the CovidVaccinations table

-----------------------------
---- HANDLING NUMBER DATA ----

-- 1- Identify the current data type for date column
Select COLUMN_NAME, DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'CovidDeaths' and COLUMN_NAME = 'total_cases'
-- Result is varchar data type

-- 2- Convert the data type to DECIMAL
Select TRY_CONVERT(DECIMAL, total_cases) AS ConvertedTotal_Cases
from PortfolioProject1..CovidDeaths

-- 3- Identify rows with conversion issues
select CovidDeaths.total_cases
from CovidDeaths
where TRY_CONVERT(DECIMAL, total_cases) is null
-- Result is none

-- 4- Update the column type 
alter table CovidDeaths add Total_CasesTemp DECIMAL

update CovidDeaths
set Total_CasesTemp = TRY_CONVERT(DECIMAL, total_cases)

alter table CovidDeaths
drop column total_cases;

exec sp_rename 'CovidDeaths.Total_CasesTemp', 'total_cases', 'column'

-- Repeate the same steps for othe number columns (total_deaths, new_cases, population, etc.) and on the CovidVaccinations table.


-----------------------------------------------------------------------------------------------
------------------- DATA EXPLORATION ---------------------------------------------------------
-----------------------------------------------------------------------------------------------

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths
order by location, date

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where location like '%austral%'
order by location, date

-- Total Cases vs Population
-- Shows the percentage of population infected with Covid per day
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
where location like '%austral%'
order by location, date

-- Countries with highest infection rate compared to population
---- (The problem here is that at some point people started to contract covid more than once)
Select location, population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
where total_deaths > 0 
and continent != ''
group by location, population
order by PercentPopulationInfected desc

-- Countries with highest death count per population
Select location, max(total_deaths) as TotalDeathsCount
from PortfolioProject1..CovidDeaths
where continent != ''
group by location
order by TotalDeathsCount desc

-- Total Vaccinations vs Population
-- Vaccinations Roll Out in your country
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) as CumulativeVaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where vac.new_vaccinations != 0
and dea.location like '%austral%'
order by dea.date

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

-- Using CTE (Common Table Expression) to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) as CumulativeVaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where vac.new_vaccinations != 0
and dea.location like '%austral%'
)
Select *, (CumulativeVaccinations/Population)*100  as PercentPopulationVaccinated
from PopvsVac
order by Location, Date

-- Using Temp Table to perform Calculation on Partition By in previous query
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
	SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) as CumulativeVaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where vac.new_vaccinations != 0
and dea.location like '%austral%'

Select *, (CumulativeVaccinations/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count
With DeathsCount (Continent, Location, TotalDeathsCountPerContry)
as 
(
Select continent, location, max(total_deaths) as TotalDeathsCountPerContry
from PortfolioProject1..CovidDeaths
where continent != ''
group by continent, location
)
Select continent, sum(TotalDeathsCountPerContry) as TotalDeathsCountPerContinent
from DeathsCount
where continent != ''
group by continent
order by TotalDeathsCountPerContinent desc


-- Showing continents with the highest vaccination count
With VaccinationsCount (Continent, Location, TotalVaccinationsCountPerContry)
as 
(
Select dea.continent 
	, dea.location
	, SUM(SUM(vac.new_vaccinations)) OVER (partition by dea.location) as cumulative_vaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
group by dea.continent, dea.location
)
Select continent, sum(TotalVaccinationsCountPerContry) as TotalVaccinationsCountPerContinent
from VaccinationsCount
where continent != ''
group by continent
order by TotalVaccinationsCountPerContinent desc


-- GLOBAL NUMBERS

-- Total Cases vs Total Deaths vs Total Vaccinations
Select SUM(dea.new_cases) as total_cases, SUM(dea.new_deaths) as total_deaths
	, SUM(dea.new_deaths)/SUM(dea.new_cases)*100 as DeathPercentage, SUM(vac.new_vaccinations) as total_vaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''

-- Per day
Select dea.date
	, SUM(dea.new_cases) as total_new_cases
	, SUM(SUM(dea.new_cases)) OVER (order by dea.date) as cumulative_cases
	, SUM(dea.new_deaths) as total_new_deaths
	, SUM(SUM(dea.new_deaths)) OVER (order by dea.date) as cumulative_deaths
	, SUM(vac.new_vaccinations) as total_new_vaccinations
	, SUM(SUM(vac.new_vaccinations)) OVER (order by dea.date) as cumulative_vaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--and vac.location = 'China'
group by dea.date
order by dea.date


-- Creating views to store data for later vizualizations

---------------------
-- PercentPopulationVaccinated
Drop view if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.date) as CumulativeVaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
and vac.new_vaccinations != 0
--and dea.location like '%australi%'
)
Select *, (CumulativeVaccinations/Population)*100  as PercentPopulationVaccinated
from PopvsVac

-- Showing the new view
Select *
from PortfolioProject1..PercentPopulationVaccinated
order by Location, Date


---------------------
-- PercentPopulationInfected
Drop view if exists PercentPopulationInfected

Create View PercentPopulationInfected as
Select continent, location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
where continent != ''
and total_cases != 0
--and location like '%australi%'

-- Showing the new view
Select *
from PortfolioProject1..PercentPopulationInfected
order by Location, Date

