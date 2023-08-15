SELECT *
FROM PortfolioProject..CovidDeaths


SELECT *
FROM PortfolioProject..CovidVaccination
ORDER BY 3,4

-- Selecting data that will be using
SELECT location, date, total_cases, total_deaths,population
FROM PortfolioProject..[CovidDeaths ]
ORDER BY 1,2

-- The Total Cases Vs. Total Deaths (in the Philippines)
SELECT location, date, total_cases,total_deaths, ((CAST(total_deaths AS FLOAT))/(CAST(total_cases AS FLOAT))*100) AS DeathPercentage
FROM PortfolioProject..[CovidDeaths ]
where location like '%Philippines%' 
ORDER BY 1,2

--Total Cases Vs. Population
--Population that gets COVID
SELECT location, date, total_cases, population, ((CAST(total_cases AS FLOAT))/(CAST(population AS FLOAT))*100) AS PopulationPercentageInfected
FROM PortfolioProject..[CovidDeaths ]
WHERE continent is not null
ORDER BY 1,2


--Top 10 Country that has been greatly affected by COVID
SELECT location,population, MAX(CAST(total_cases AS INT)) as HighestInfectionCount, MAX((total_cases /population))*100 as PopulationtInfetionPercentage
FROM PortfolioProject..[CovidDeaths ]
WHERE continent is not null
GROUP BY location, population
ORDER BY PopulationtInfetionPercentage desc

--Countries with Highest Death Count per Population
SELECT location, population, MAX(CAST(total_deaths AS INT)) as TotalDeathCount, MAX(CAST(total_deaths AS FLOAT)/CAST(population AS FLOAT)) *100 as DeathPercentage
FROM PortfolioProject..[CovidDeaths ]
WHERE continent is not null
GROUP BY location, population
ORDER BY DeathPercentage desc


--Data by 
--Total Death Count Per Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..[CovidDeaths ]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS
--GLOBAL PERCENTAGE OF DEATHS 
SELECT date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DEATH_PERCENTAGE_GLOBALLY
FROM PortfolioProject..[CovidDeaths ]
WHERE continent is not null and new_cases <>0
GROUP BY date
ORDER BY 1,2

--TOTAL CASES AND DEATHS
SELECT  SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DEATH_PERCENTAGE_GLOBALLY
FROM PortfolioProject..[CovidDeaths ]
WHERE continent is not null and new_cases <>0
ORDER BY 1,2


--JOINING COVID DEATHS AND COVID VACCINATION TABLE
SELECT *
FROM PortfolioProject..[CovidDeaths ] cd
JOIN PortfolioProject..[CovidVaccination ] cv
ON cd.location=cv.location and cd.date=cv.date


--LOOKING FOR TOTAL POPULATION VS. NUMBER OF VACCINATION
SELECT cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS VACCINATION_ROLLING_COUNT
FROM PortfolioProject..[CovidDeaths ] cd
JOIN PortfolioProject..[CovidVaccination ] cv
ON cd.location=cv.location and cd.date=cv.date
WHERE cd.continent is not null
ORDER BY 2,3

-- USING CTE
WITH POPVSVAC (continent, location, date, Population,new_vaccinations, VACCINATION_ROLLING_COUNT)	
AS
(
SELECT cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations, 
SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS VACCINATION_ROLLING_COUNT
FROM PortfolioProject..[CovidDeaths ] cd
JOIN PortfolioProject..[CovidVaccination ] cv
ON cd.location=cv.location and cd.date=cv.date
WHERE cd.continent is not null
)
SELECT *, (CAST(VACCINATION_ROLLING_COUNT AS INT)/CAST(Population AS int))*100
FROM POPVSVAC


--CREATINGG VIEW  FOR VISUAL PRESENTATION
CREATE VIEW PERCENT_PEOPLE_VACCINATED AS
SELECT cd.continent, cd.location,cd.date, cd.population,cv.new_vaccinations, 
SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS VACCINATION_ROLLING_COUNT
FROM PortfolioProject..[CovidDeaths ] cd
JOIN PortfolioProject..[CovidVaccination ] cv
ON cd.location=cv.location and cd.date=cv.date
WHERE cd.continent is not null

SELECT * FROM PERCENT_PEOPLE_VACCINATED