--calculating death% for each country
select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject_Covid.dbo.CovidDeaths
where continent is not null
order by 1,2

-- calculating % of population infected by covid
select location, date,total_cases,population,(total_cases/population)*100 as InfectionPercentage
from PortfolioProject_Covid.dbo.CovidDeaths
where continent is not null
order by 1,2

-- Displaying counrties with highest Infection rate
select location,max(total_cases) as Highest_Case,population,max((total_cases/population))*100 as InfectionPercentage
from PortfolioProject_Covid.dbo.CovidDeaths
where continent is not null
group by location,population
order by InfectionPercentage desc

-- Displaying counrties with highest Death rate
select location,max(total_deaths) as Highest_DeathCase,population,max((total_deaths/population))*100 as DeathPercentage
from PortfolioProject_Covid.dbo.CovidDeaths
where continent is not null
group by location,population
order by DeathPercentage desc

-- Displaying No of Death cases for each continent
select location,sum(total_deaths) as TotalDeathCases
from PortfolioProject_Covid.dbo.CovidDeaths
where continent is null and total_deaths is not null
group by location
order by TotalDeathCases desc

-- Displaying Highest no of death cases for each continent
select location,max(total_deaths) as Highest_no_of_DeathCases
from PortfolioProject_Covid.dbo.CovidDeaths
where continent is null and total_deaths is not null
group by location
order by Highest_no_of_DeathCases desc

-- joining deaths and vaccination table to get % of People vaccinated on date for each country
-- using CTE
with CTE_VaccbyDate as 
(
select death.continent,death.location,death.date,death.population,vacc.new_vaccinations,
sum(vacc.new_vaccinations) over (Partition by death.location order by death.location,death.date) as TotalVaccitaionsOnDate
from PortfolioProject_Covid.dbo.CovidDeaths as death
join PortfolioProject_Covid.dbo.CovidVaccinations as vacc
on death.location=vacc.location and
death.date=vacc.date
where death.continent is not null
)

select *, (TotalVaccitaionsOnDate/population)*100 as VaccinationPercentage from CTE_VaccbyDate
order by 2,3

-- joining deaths and vaccination table to get % of People vaccinated on date for each continent
-- using temp table
drop table if exists #VaccContinent
create table #VaccContinent
(
loaction varchar(50),
date date,
population numeric,
new_vaccinations numeric,
TotalVaccitaionsOnDate numeric
)

insert into #VaccContinent
select death.location,death.date,death.population,vacc.new_vaccinations,
sum(vacc.new_vaccinations) over (Partition by death.location order by death.location,death.date) as TotalVaccitaionsOnDate
from PortfolioProject_Covid.dbo.CovidDeaths as death
join PortfolioProject_Covid.dbo.CovidVaccinations as vacc
on death.location=vacc.location and
death.date=vacc.date
where death.continent is null

select *, (TotalVaccitaionsOnDate/population)*100 as VaccinationPercentage from #VaccContinent
order by 1,2
