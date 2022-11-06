SELECT *
FROM covid_deaths
ORDER BY 3,4;

SELECT *
FROM covid_vaccinations
ORDER BY 3,4;

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,2;

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
--Death Percentage by date in the Honduras

SELECT Location, date, total_cases,total_deaths,ROUND((total_deaths/total_cases)*100,7) AS DeathPercentage
FROM covid_deaths
WHERE location like '%states%'
ORDER BY 1,2;

--Hospital Patients Percentage by date in the USA
SELECT Location, date, total_cases,hosp_patients,(hosp_patients/total_cases)*100 AS HospPatientPercentage
FROM covid_deaths
WHERE location like '%states%'AND total_cases IS NOT NULL
ORDER BY 1,2;

--ICU patinets Percentage from Hopsital Total Patients by date in the USA
SELECT Location, date,hosp_patients,icu_patients,(hosp_patients/total_cases)*100 AS HospPatientPercentage
FROM covid_deaths
WHERE location like '%states%' AND hosp_patients IS NOT NULL
ORDER BY 1,2;



-- COUNTRIES BY INFECTION RATE (HIGHEST)

SELECT Location,population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY Location, population 
ORDER BY MAX((total_cases/population)*100)DESC;

--Countries with highest dead count per Population 
SELECT Location, MAX(CAST(Total_deaths AS int))  AS TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;



--CONTINENTS 

--Countries with highest dead count per Population 
SELECT location, MAX(CAST(Total_deaths AS int))  AS TotalDeathCount
FROM covid_deaths
WHERE continent IS NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;


--WORLD NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, 
SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS deathPercentage 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location 
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL AND dea.location = 'United States' 
ORDER BY 2,3;


-- USE CTE

WITH PopvsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location 
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL AND dea.location = 'United States')
SELECT *, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinated_in_USA
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS PerPopVacc
CREATE TABLE PerPopVacc
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PerPopVacc
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location 
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL AND dea.location = 'United States'
SELECT *, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinated_in_USA
FROM PerPopVacc


--CREATING A VIEW FOR TABLEAU

CREATE VIEW PerPopVacc1 AS
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location 
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL AND dea.location = 'United States'
