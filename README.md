
# Covid-19 Data Exploration

Explore the global data on confirmed COVID-19 deaths available online for the first 16 months of COVID-19 cases.

Dates from 01/01/2020 to 30/04/2021.

***Public DataSet:*** [Our World in Data - Coronavirus (COVID-19) Deaths](https://ourworldindata.org/covid-deaths)

## Skills used: 

**Database:** SQL Server 2022 Express, SQL Server Management Studio v20.1 (SSMS)

**Data Manipulation:** Excel and SQL (Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types)

## Objectives

- Demostrate SQL knowledge
- Find the numbers per day
- Undertand the number of deaths
- See the most affected countries
# Data Preparation

I split the dataset file into two tables: CovidDeaths and CovidVaccinations and saved the files as .txt to be able to import them into the Database.

When importing text files to SQL Server, the default data type for all columns is varchar, in order to handle dates and numbers it is necessary to change the data types. 

I'll demonstrate two ways to change the default data type:

- Configuring the properties of each column during the import of the data
![Data Import Screenshot](https://raw.githubusercontent.com/anapsoliveira/Covid-Data-Exploration/main/images/dataImport.JPG)

- Using SQL commands to convert the data type for a column

1- Identify the current data type for date column

```sql
Select COLUMN_NAME, DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'CovidDeaths' and COLUMN_NAME = 'date'
```

2- Convert the data type to date
```sql
Select TRY_CONVERT(date, date, 103) AS ConvertedDate
from PortfolioProject1..CovidDeaths
```

3- Identify rows with conversion issues
```sql
select CovidDeaths.date
from CovidDeaths
where TRY_CONVERT(date, date, 103) is null
```


4- Update the column type 
```sql
alter table CovidDeaths add DateTemp DATE

update CovidDeaths
set DateTemp = TRY_CONVERT(DATE, date, 103)

alter table CovidDeaths
drop column date;

exec sp_rename 'CovidDeaths.DateTemp', 'date', 'column'
```

Repeat these steps for all all the columns that needs to tbe changed under CovidDeaths and CovidVaccinations tables.
# Data Exploration

Some of the queries created and the results:

1- Showing continents with the highest vaccination count
```bash
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
```

Result: 

![TotalVaccinationsCountPerContry](https://raw.githubusercontent.com/anapsoliveira/Covid-Data-Exploration/main/images/Result1.JPG)


## Authors

- [@anapsoliveira](https://www.github.com/anapsoliveira)

