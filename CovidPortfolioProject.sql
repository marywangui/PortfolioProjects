select * 
from PortfolioProject..CovidDeaths$
where continent is not NULL
order by 3,4


--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--select data that we are going to be using

select Location, date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
where continent is not NULL
order by 1,2

--Looking for total cases vs total deaths
--shows the likelyhood of dying if you contract covid
select Location, date,total_cases,total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where Location like '%states%'
 --where continent is not NULL
order by 1,2

--Looking for total_cases vs Population
--shows what percentage of population got covid 
select Location, date,total_cases,population,(total_cases/population)* 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where Location like '%states%'
where continent is not NULL
order by 1,2

--Looking at countries with highest infection rates
select Location,MAX (total_cases) as highestInfectionCount,population,MAX ((total_cases/population))* 100 as PercentPopulatioInfected
from PortfolioProject..CovidDeaths$
--where Location like '%states%'
where continent is not NULL
Group by Location,population
order by PercentPopulatioInfected desc


--LETS BREAK DOWN BY CONTINENT

--Showing Countries With the Highest death Counts per Population 

select Location,MAX (cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where Location like '%states%'
where continent is not NULL
Group by Location
order by TotalDeathCount desc

--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

select continent,MAX (cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where Location like '%states%'
where continent is not NULL
Group by continent
order by TotalDeathCount desc

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where Location like '%states%'
where continent is not NULL
Group by date
order by 1,2

--joining CovidDeaths nd CovidVaccination tables
--Looking for total population vs vacinations

select *
from PortfolioProject ..CovidDeaths$ dea
join Portfolioproject ..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--Looking for total population vs vacinations
--use a CTE table...issue with code
with PopvsVac (continent,population,date,location,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths$ dea
join Portfolioproject ..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
Drop Table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths$ dea
join Portfolioproject ..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated

-- creating veiw to store data for later visualization....issue with code has error
Create View PercentagePopulationVaccinated 
AS
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths$ dea
join Portfolioproject ..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
