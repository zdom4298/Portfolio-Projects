--select * from [Portfolio Project].[dbo].[Coviddeaths]
--order by 3,4

--select * from [Portfolio Project].[dbo].[covidvaccination]
--order by 3,4

select location, date, total_cases,total_deaths,population
from [Portfolio Project].[dbo].[Coviddeaths]
order by 1,2

--Looking at total cases vs total deaths

select location,date total_cases,total_deaths, (total_cases/total_deaths)
from [Portfolio Project].[dbo].[Coviddeaths]
order by 1,2

--Shows likelihood of dying if you contract covid19 in Puerto Rico
select location,date, total_cases,total_deaths,(convert (float, total_deaths)/
nullif (convert ( float,total_cases),0))*100 As Deathpercentage
from [Portfolio Project].[dbo].[Coviddeaths]
where location = 'puerto rico' and  continent is not null
order by 1,2

--Looking at total cases vs population
--Shows wht percentage f popultion got covid
select location,date, population,total_cases,(convert (float, total_deaths)/
nullif (convert ( float,population),0))*100 As PercentagePopulationInfected
from [Portfolio Project].[dbo].[Coviddeaths]
where location = 'puerto rico' and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

select location,population,Max (total_cases) As HighesInfectionCount,
max((total_cases/population))*100 AS  PercentagePopulationInfected
from [Portfolio Project].[dbo].[Coviddeaths]
--where location = 'puerto rico' and  continent is not null
group by location, population
order by PercentagePopulationInfected desc

--showing countries with higest death count per population

select location,Max (CAST (total_deaths AS INT)) As TotalDeathCount
from [Portfolio Project].[dbo].[Coviddeaths]
where continent is not null
group by location
order by TotalDeathCount desc

--Let's Break Things Down by Continent
--Showing the continent with the highest death per population
select location,Max (CAST (total_deaths AS bigINT)) As TotalDeathCount
from [Portfolio Project].[dbo].[Coviddeaths]
where continent is null and location in (select distinct continent 
from [Portfolio Project].[dbo].[Coviddeaths] where continent is not null)
group by location
order by TotalDeathCount desc

--Global Numbers

select  SUM(cast (new_cases as int))as TotalCases,Sum(cast(new_deaths as int))As TotalDeaths,
Sum(convert (int, new_deaths)/
nullif (convert ( int,new_cases),0))*100 As Deathpercentage
from [Portfolio Project].[dbo].[Coviddeaths]
wHERE continent is not null
--group by date
order by 1,2


--Looking at the Population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum (convert(bigint,vac.new_vaccinations)) over (Partition by  dea.location, dea.date)
As Rollingpeoplevaccinated
From [Portfolio Project].[dbo].[Coviddeaths] dea
Join [Portfolio Project].[dbo].[covidvaccination] vac
On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 
order by 2,3


--Use CTE
With PopvsVac (continent, Location, date, population, new_vaccinations,Rollingpeoplevaccinated) 
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum (convert(bigint,vac.new_vaccinations)) over (Partition by  dea.location, dea.date)
As Rollingpeoplevaccinated
From [Portfolio Project].[dbo].[Coviddeaths] dea
Join [Portfolio Project].[dbo].[covidvaccination] vac
On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 

)
Select *, (Rollingpeoplevaccinated/population)*100 As RollingPeopleVacPercent
From PopvsVac


--Temp table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
);
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum (convert(bigint,vac.new_vaccinations)) over (Partition by  dea.location, dea.date)
As Rollingpeoplevaccinated 
From [Portfolio Project].[dbo].[Coviddeaths] dea
Join [Portfolio Project].[dbo].[covidvaccination] vac
On dea.location = vac.location and dea.date = vac.date
--Where dea.continent is not null 
--order by 2,3

Select *,(Rollingpeoplevaccinated/population)*100
From #PercentPopulationVaccinated


--Create view to store data for later vizualization
Use [Portfolio Project]
go
create view PercentPopulationVaccinated as 
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum (convert(bigint,vac.new_vaccinations)) over (Partition by  dea.location, dea.date)
As Rollingpeoplevaccinated 
From [Portfolio Project].[dbo].[Coviddeaths] dea
Join [Portfolio Project].[dbo].[covidvaccination] vac
On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 
--order by 2,3


Select * 
From PercentPopulationVaccinated