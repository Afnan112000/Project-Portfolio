SELECT *
FROM CovidDeaths
ORDER BY 3,4 

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE Location like '%india%'
ORDER BY 1,2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid

SELECT Location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfect
FROM CovidDeaths
--WHERE Location like '%india%'
ORDER BY 1,2


-- Looking at countries with highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE Location like '%india%'
GROUP BY location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count Per Population
-- Problem Faced is total death column was specified wrong type i.e nvarchar, so we have to use cast to show total death as int as it will low to show us correct format

SELECT location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--Where location like '%india%'
where continent is not null
Group by location, population
Order by TotalDeathCount desc

-- Let's  Break things down by Continent

-- Showing continents with the highest death count per population


SELECT continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--Where location like '%india%'
where continent is not null
Group by continent
Order by TotalDeathCount desc





-- Breaking Global Numbers

SELECT date, SUM(new_cases) as total_newcases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--where location like '%state%'
where continent	 is not null
group by date
order by 1,2


SELECT  SUM(new_cases) as total_newcases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--where location like '%state%'
where continent	 is not null
--group by date
order by 1,2



-- Looking at Total Population vs Vaccinations
-- USE CTE

WITH PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    on dea.location = vac. location
	and dea. date = vac.date
where dea.continent is not null	)
	--order by 2,3
 Select *, (RollingPeopleVaccinated/population)*100
 From PopvsVac


 -- TEMP TABLE

 DROP TABLE IF exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 ( continent nvarchar(255),
 location nvarchar (255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    on dea.location = vac. location
	and dea. date = vac.date
where dea.continent is not null	

Select *, (RollingPeopleVaccinated/population)*100
 From #PercentPopulationVaccinated


 


















