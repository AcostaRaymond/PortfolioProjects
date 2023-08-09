select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at total cases vs population

select location, date,population, total_cases, (total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercetPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location,population
order by 4 desc

-- Looking at countries with highest death rate compared to population

select location, MAX(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotaldeathCount desc


-- showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotaldeathCount desc


-- GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at total Population vs Vaccinations

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations cv 
inner join PortfolioProject..CovidDeaths cd on cv.location = cd.location and cv.date = cd.date
where cd.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccination)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations cv 
inner join PortfolioProject..CovidDeaths cd on cv.location = cd.location and cv.date = cd.date
where cd.continent is not null
)

Select *, (RollingPeopleVaccination/population)*100
from PopvsVac

-- TEMP TABLE

drop table if exists #PopvsVac

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
into #PopvsVac
from PortfolioProject..CovidVaccinations cv 
inner join PortfolioProject..CovidDeaths cd on cv.location = cd.location and cv.date = cd.date
where cd.continent is not null


Select *, (RollingPeopleVaccinated/population)*100
from #PopvsVac


-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations cv 
inner join PortfolioProject..CovidDeaths cd on cv.location = cd.location and cv.date = cd.date
where cd.continent is not null


select *
from PercentPopulationVaccinated