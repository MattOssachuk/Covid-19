--Altering table to turn data type to int
ALTER TABLE covid_deaths ALTER COLUMN hosp_patients int


--Select everything from Covid Deaths Table
SELECT * 
FROM Portfolio_Project..covid_deaths
--WHERE continent is not null
ORDER BY 3,4;

--Creating a view for Total_Hospital_Patients_by_Continent
CREATE VIEW Hospital_Patients_by_Continent AS
  SELECT continent, hosp_patients
    FROM Portfolio_Project..covid_deaths;
     
--Deleting the nulls
DELETE FROM Hospital_Patients_by_Continent
WHERE continent IS NULL;

--Calling the table
  SELECT Continent, SUM(hosp_patients) AS Total_Hospital_Patients
    FROM Hospital_Patients_by_Continent
	  GROUP BY continent ORDER BY Total_Hospital_Patients DESC;

--Another query
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..covid_deaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Portfolio_Project..covid_deaths
WHERE location like '%canada%'
ORDER BY 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percentage_got_covid
FROM Portfolio_Project..covid_deaths
WHERE location like '%canada%'
ORDER BY Percentage_got_covid DESC;

--Looking at Countries with highest infection rate compared to population
SELECT location, population,  MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population))*100 AS Highest_Percentage_Infected
FROM Portfolio_Project..covid_deaths
--WHERE location like '%canada%'
GROUP by location, population
ORDER BY Highest_Percentage_Infected DESC
  OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;



-- Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM Portfolio_Project..covid_deaths
--WHERE location like '%canada%'
WHERE continent is not null
GROUP by location
ORDER BY total_death_count DESC
   OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;

-- Let's break things down by continent but these numbers look wrong lets try again
--MAKE IT INTO A PIE CHART!!
SELECT continent, SUM(cast(new_deaths as int)) AS total_death_count
FROM Portfolio_Project..covid_deaths
--WHERE location like '%canada%'
WHERE continent is not null
GROUP by continent
ORDER BY total_death_count DESC;


--Creating a view for Total_Hospital_Patients_by_Continent
CREATE VIEW total_deaths_by_Continent AS
  SELECT continent, total_deaths
    FROM Portfolio_Project..covid_deaths;

--Altering table to turn data type to int
ALTER TABLE Portfolio_Project..covid_deaths ALTER COLUMN total_deaths int

SELECT continent, SUM(distinct(total_deaths)) AS total_deaths
    FROM Portfolio_Project..covid_deaths
	GROUP by continent
	ORDER BY total_deaths;

-- GLOBAL NUMBERS

--totals
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 AS death_percentage
FROM Portfolio_Project..covid_deaths
--WHERE location like '%canada%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2 

--by date
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 AS death_percentage
FROM Portfolio_Project..covid_deaths
--WHERE location like '%canada%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 

--Joining the tables

SELECT *
FROM Portfolio_Project..covid_vaccinations;

--Looking at total population vs vaccinations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated) 
AS
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.location ORDER by D.location, D.date) AS Rolling_People_Vaccinated
--(Rolling_People_Vaccinated/population)*100
FROM Portfolio_Project..covid_deaths D
JOIN Portfolio_Project..covid_vaccinations V 
  ON D.location = V.location
  and D.date = V.date
WHERE D.continent is not null

)

--USE CTE

SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Rolling_Percentage_Vaccinated
FROM PopvsVac


--TEMP Table

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric, 
Rolling_People_Vaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.location Order by D.location, D.date) AS Rolling_People_Vaccinated
--(Rolling_People_Vaccinated/population)*100
FROM Portfolio_Project..covid_deaths D
JOIN Portfolio_Project..covid_vaccinations V 
  ON D.location = V.location
  and D.date = V.date
WHERE D.continent is not null



SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Rolling_Percentage_Vaccinated
FROM #PercentPopulationVaccinated














     







	   