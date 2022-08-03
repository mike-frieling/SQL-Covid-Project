--Select all from CovidDeaths Table
SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--Select all from CovidVaccinations Table
SELECT *
FROM CovidVaccinations
WHERE continent is not null
ORDER BY 3,4


--Select specific columns 
SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths daily
--Shows likelihood of dying if you contract Covid in your country (United States used as example)
SELECT Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE Continent is not null
and Location like '%states%' and location not like '%virgin%'
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid in country (United States used as example)
SELECT Location, Date, Population, Total_Cases, (Total_Cases/Population)*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE Continent is not null
and Location like '%states%' and location not like '%virgin%'
ORDER BY 1,2


--Looking at countries with highest infection rates compared to total population (can drill down to specific country)
SELECT location, population, max(total_cases)as InfectionCount, max((total_cases/population))*100 as TotalCasesPercentage
FROM CovidDeaths
WHERE continent is not null --and location like '%states%' and location not like '%virgin%'
GROUP BY location, population
ORDER BY TotalCasesPercentage desc


--Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--Continent Breakdown
--Showing continents with highest death counts
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--World Numbers
--Per day total cases, total deaths, and death percentage
SELECT date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Total world numbers (start of pandemic to 7/29/22)
SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Total population vs vaccinations (new vaccinations include boosters as recorded by ourworldindata.org)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3


--CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null)
SELECT *, (RollingPeopleVaccinated/population)*100 as RollingPercentVaccinated
From PopvsVac


--Temp Table (new vaccinations include boosters as recorded by ourworldindata.org)
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPercentVaccinated
FROM #PercentPopulationVaccinated
ORDER BY 2,3


--Creating views to store data for visualizations
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


