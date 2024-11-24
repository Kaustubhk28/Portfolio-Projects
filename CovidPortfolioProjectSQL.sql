select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases vs Total deaths
-- Likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows % of population got Covid

select Location, date as Date, population as Population, total_cases as TotalCases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to population

select Location, population as Population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'India'
group by Location, population
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population and its percentage

select Location, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 as PercentPopulationDied
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

-- Lets break things down by continent
-- showing continent with highest death count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Global Numbers

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
	   sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2, 3

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2, 3

--use cte
with popvsvac as
(
	select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(convert(int, v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths d
	join PortfolioProject..CovidVaccinations v
	on d.location = v.location and d.date = v.date
	where d.continent is not null
)
select *, round((RollingPeopleVaccinated/population), 2) * 100 as percentage
from popvsvac

--temp table

drop table if exists #PercentPopulationvaccinated
create table #PercentPopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationvaccinated

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null

select *, round((RollingPeopleVaccinated/population), 2) * 100 as percentage
from #PercentPopulationvaccinated


-- Create view to store data for later visualizations
create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null

select *
from PercentPopulationVaccinated