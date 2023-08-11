select*
From PortfolioProjectL..CovidDeaths 
order by 3,4

--select*
--From PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectL..CovidDeaths 
order by 1,2

-- Looking at total cases vs total deaths
-- Shows how likely you'll die if you contract covid in the UK

Select Location, date, total_cases, total_deaths, (convert(float,total_deaths)/total_cases)*100 as DeathPercentage
From PortfolioProjectL..CovidDeaths
where location like '%kingdom%'
Order by 1,2

-- Looking at total cases vs population
-- shows what percentage of the population got covid

 Select Location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
From PortfolioProjectL..CovidDeaths
--where location like '%kingdom%'
Order by 1,2

-- Looking at countries with the highest infection rate compared to population

Select Location,  population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjectL..CovidDeaths
--where location like '%kingdom%'
Group by location, population 
Order by PercentPopulationInfected desc

-- showing countries with the highest death count per population

Select Location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProjectL..CovidDeaths
--where location like '%kingdom%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

Select location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProjectL..CovidDeaths
--where location like '%kingdom%'
Where continent is null
Group by location
Order by TotalDeathCount desc

-- Breaking it down to continents
-- Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProjectL..CovidDeaths
--where location like '%kingdom%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercenage
 From PortfolioProjectL..CovidDeaths
 Where continent is not null
 Order by 1,2

 -- Looking at Total Population vs Vaccinations

select def.continent, def.location, def.date, def.population, vax.new_vaccinations, 
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by def.location Order by def.location, def.date) as
RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
 From PortfolioProjectL..CovidDeaths def
 join PortfolioProjectL..CovidVaccinations vax
 on def.location= vax.location 
 and def.date= vax.date
 WHERE def.continent is not null
 Order by 2,3

-- USE CTE

with PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(select def.continent, def.location, def.date, def.population, vax.new_vaccinations, 
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by def.location Order by def.location,
def.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
 From PortfolioProjectL..CovidDeaths def
 join PortfolioProjectL..CovidVaccinations vax
 on def.location= vax.location 
 and def.date= vax.date
 WHERE def.continent is not null
 --Order by 2,3
 )
 SELECT*, (RollingPeopleVaccinated/Population)*100
 FROM PopvsVac


 -- TEMP TABLE

 DROP TABLE IF EXISTS #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into #PercentPopulationVaccinated
select def.continent, def.location, def.date, def.population, vax.new_vaccinations, 
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by def.location Order by def.location, def.date) as
RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
 From PortfolioProjectL..CovidDeaths def
 join PortfolioProjectL..CovidVaccinations vax
 on def.location= vax.location 
 and def.date= vax.date
 WHERE def.continent is not null
 Order by 2,3

 SELECT*, (RollingPeopleVaccinated/Population)*100
 FROM #PercentPopulationVaccinated

 -- Creasting view to store data for later visualisations

 CREATE VIEW PercentPopulationVaccinated as
select def.continent, def.location, def.date, def.population, vax.new_vaccinations, 
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by def.location Order by def.location, def.date) as
RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
 From PortfolioProjectL..CovidDeaths def
 join PortfolioProjectL..CovidVaccinations vax
 on def.location= vax.location 
 and def.date= vax.date
 WHERE def.continent is not null
 --Order by 2,3

 Select*
 FROM PercentPopulationVaccinated
