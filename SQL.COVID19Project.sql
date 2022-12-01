-- Select the data we are going to be using

select *
from CovidDeaths
where continent is not null
order by 3,4

select *
from CovidVaccination
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


-- Total cases vs Total Deaths for Croatia

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location = 'Croatia'
order by 1,2



-- Looking at Total Cases vs Population for Croatia
-- Shows the percentage of Infected population

select location, date, total_cases, population, (total_cases/population)*100 as PercentageofInfected
from CovidDeaths
Where location = 'Croatia'
order by 1,2

-- Highest infection rate per country

select location, max(total_cases) as HighestInfectionCount, population, (max(total_cases)/population)*100 as MaximumPercentageofInfected
from CovidDeaths
group by location, population
order by MaximumPercentageofInfected desc

-- Highest death count per country

select location, max(cast(total_deaths as int)) as HighestDeathCount, population, (max(total_deaths)/population)*100 as MaximumPercentageofDeseased
from CovidDeaths
where continent is not null
group by location, population
order by HighestDeathCount desc


-- Break down by Continent 
-- Continents with highest death count per population

-- USE THIS ONE
select location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc

-- OR CAN BE DONE LIKE THIS
select continent, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc


-- Global Numbers
-- Maxmum on Specific dates, by desending oreder of Maximum Cases

select date, max(new_cases) as DailyMaximum
from CovidDeaths
where continent is not null
group by date
order by DailyMaximum desc

-- Global death percentage, per day of the pandemic

select date, max(new_cases) as DailyMaximum, sum(cast(new_deaths as int)) as TotalDeathsPerDay, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentagePerDay
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total percentage of deaths in the World

select sum(new_cases) as TotalWorldCases, sum(cast(new_deaths as int)) as TotalWorldDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as WorldDeathPercentage
from CovidDeaths
where continent is not null
order by 1,2

----------------------------------------------------------------------------------------
-- Joining CovidDeaths and CovidVaccination by Location and Date
select *
from PorfolioProjectCOVID..CovidDeaths as death
join PorfolioProjectCOVID..CovidVaccination as vacc
     on death.location = vacc.location
	 and death.date = vacc.date


-- Rolling count of Total people vaccinated by Country

select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as int)) over (partition by death.location order by death.location, death.Date) as RollingPeopleVacc -- Rolling count
from PorfolioProjectCOVID..CovidDeaths as death
join PorfolioProjectCOVID..CovidVaccination as vacc
     on death.location = vacc.location
	 and death.date = vacc.date
where death.continent is not null
order by 1,2,3


-- Use of CTE to calculate percentage of Vaccinated people vs Population

--with CTE_TotalVacc as
--(select vacc.location, death.population, POGLEDAJ OVO!!!! sum(cast(vacc.new_vaccinations as int)) as TotalPeopleVacc
--from PorfolioProjectCOVID..CovidVaccination as vacc
--join PorfolioProjectCOVID..CovidDeaths as death
--   on vacc.location = death.location
--where vacc.continent is not null
--group by vacc.location, death.population
--)

--select location, population, TotalPeopleVacc, (TotalPeopleVacc/population)*100 as PercentageofVacc
--from CTE_TotalVacc
--order by 1,2



with CTE_TotalVacc as
(select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as int)) over (partition by death.location order by death.location, death.Date) as RollingPeopleVacc -- Rolling count
from PorfolioProjectCOVID..CovidDeaths as death
join PorfolioProjectCOVID..CovidVaccination as vacc
     on death.location = vacc.location
	 and death.date = vacc.date
where death.continent is not null)


select location, population, RollingPeopleVacc, (RollingPeopleVacc/population)*100 as PercentageofVacc
from CTE_TotalVacc
order by 1,2


-- Use of TEMP TABLE to calculate percentage of Vaccinated people vs Population for Croatia


drop table if exists #temp_TotalVaccPercentage
create table #temp_TotalVaccPercentage
(continent nvarchar (255),
location nvarchar (255),
Date datetime,
population int,
NewVaccinated int,
RollingPeopleVacc int)

insert into #temp_TotalVaccPercentage
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as int)) over (partition by death.location order by death.location, death.Date) as RollingPeopleVacc -- Rolling count
from PorfolioProjectCOVID..CovidDeaths as death
join PorfolioProjectCOVID..CovidVaccination as vacc
     on death.location = vacc.location
	 and death.date = vacc.date
where death.continent is not null

select location, population, RollingPeopleVacc, (RollingPeopleVacc/population)*100
from #temp_TotalVaccPercentage
where location = 'Croatia'



-- View to store data for later visualization

Create view PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as int)) over (partition by death.location order by death.location, death.Date) as RollingPeopleVacc -- Rolling count
from PorfolioProjectCOVID..CovidDeaths as death
join PorfolioProjectCOVID..CovidVaccination as vacc
     on death.location = vacc.location
	 and death.date = vacc.date
where death.continent is not null


select *
from PercentPopulationVaccinated
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- To be used for Tableau visualization

-- Percentage of Total Deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
--Group By date
order by 1,2

-- Death count for each Continent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- Percentage of Population infected per Location

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Highest percentage of Infected per Day

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
