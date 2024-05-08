select *
from CovidDeaths
where continent is not NULL 
order by 3,4

-- select data that is about to be used 

select Location, date,total_cases,new_cases,total_deaths,population
From CovidDeaths
order by 1,2

--Looking at Total cases vs Total deaths 

SELECT 
    Location,
    date,
    total_cases,
    total_deaths,
    CASE 
        WHEN total_cases = 0 THEN NULL
        ELSE CAST(total_deaths AS float) / NULLIF(total_cases, 0) * 100 
    END AS deathpercent
FROM 
    CovidDeaths
ORDER BY 
    1, 2;

	--TO FIND OUT WHAT PERCENTAGE OF POPULATION THAT GOT COVID IN UNITED STATES PER DAY
	
SELECT 
    Location,
    date,
    total_cases,
    Population,
    CASE 
        WHEN total_cases = 0 THEN NULL
        ELSE NULLIF(total_cases, 0) / CAST(population AS float) * 100 
    END AS deathpercent
FROM CovidDeaths
WHERE	location like '%states%'
ORDER BY 
    1, 2;

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION 

SELECT 
    Location, 
    Population, 
    MAX(CAST(total_cases AS FLOAT)) as HighestInfectionCount, 
    Max(CAST(total_cases AS FLOAT)/NULLIF(CAST(population AS FLOAT), 0))*100 as PercentPopulationInfected 
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc 

--showing countries with highest death count per population 
SELECT Location,MAX(cast(Total_deaths as float)) as totaldeathcount 
from CovidDeaths
Where continent is not null 
Group by Location 
order by totaldeathcount desc

--highest deat count by continents
SELECT continent,MAX(cast(Total_deaths as float)) as totaldeathcount 
from CovidDeaths
where continent is not null
Group by continent 
order by totaldeathcount desc


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/NULLIF(Population, 0))*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

--DROP Table if exists #PercentPopulationVaccinated
--Create Table #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric,
--New_vaccinations numeric,
--RollingPeopleVaccinated numeric
--)

--Insert into #PercentPopulationVaccinated
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--FROM CovidDeaths dea
--JOIN CovidVaccinations vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date


--SELECT *, (RollingPeopleVaccinated/NULLIF(Population, 0))*100
--FROM #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3