/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM Portfolio_Projects..Covid_Deaths$
WHERE continent is not NULL
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Projects..Covid_Deaths$
WHERE continent is not NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM Portfolio_Projects..Covid_Deaths$
WHERE location = 'United States'
AND continent is not NULL
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as Positive_cases_per_capita
FROM Portfolio_Projects..Covid_Deaths$
WHERE location = 'United States'
AND continent is not NULL
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location,MAX(total_cases) AS Highest_Infection_Count, population, MAX((total_cases/population))*100 as Positive_cases_per_capita
FROM Portfolio_Projects..Covid_Deaths$
--WHERE location = 'United States'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY Positive_cases_per_capita DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM Portfolio_Projects..Covid_Deaths$
WHERE continent is not NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM Portfolio_Projects..Covid_Deaths$
WHERE continent is not NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC


--Global numbers

SELECT date,SUM(new_cases) as Total_cases, SUM(cast(new_deaths as INT))as Total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as Death_Percentage
FROM Portfolio_Projects..Covid_Deaths$
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

--Global numbers

SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as INT))as Total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as Death_Percentage
FROM Portfolio_Projects..Covid_Deaths$
WHERE continent is not NULL
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Updated_Vax_Numbers
	FROM Portfolio_Projects..Covid_Deaths$ dea
	JOIN Portfolio_Projects..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not NULL

-- Looking at total population vs vaccinations
-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac (continent, location, date, population,new_vaccinations, Updated_Vax_Numbers)
	as
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Updated_Vax_Numbers
	FROM Portfolio_Projects..Covid_Deaths$ dea
	JOIN Portfolio_Projects..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not NULL
	)
SELECT *, (Updated_Vax_Numbers/population)*100 as Vaccination_Percent
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio_Projects..Covid_Deaths$ dea
Join Portfolio_Projects..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL

Select *, (RollingPeopleVaccinated/Population)/2*100 as Total_population_vax
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio_Projects..Covid_Deaths$ dea
Join Portfolio_Projects..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL