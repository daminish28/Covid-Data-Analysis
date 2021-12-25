-- Checking the table

SELECT * FROM covid_deaths order by 3 asc;

--Looking at the total cases vs total deaths

SELECT location, date, total_cases, new_cases, total_deaths, population FROM covid_deaths ORDER BY 1,2;

--Shows death percentage for every country

SELECT location, date, total_cases, total_deaths, 
(CAST(total_deaths AS decimal )/total_cases)*100 AS percentage_of_deaths 
FROM covid_deaths ORDER BY 1,2;

--Looking at total cases vs total population, shows % of popn that got covid

SELECT location, date, total_cases, population, 
(CAST(total_cases AS decimal)/ population)*100 AS percentage_of_cases FROM covid_deaths ORDER BY 3 DESC;

--Looking at the locations where is high percentage of cases

SELECT location, MAX(total_cases) AS high_infection, population, 
MAX((CAST(total_cases as decimal)/ population)*100) AS percentage_of_cases FROM covid_deaths 
GROUP BY location, population ORDER BY percentage_of_cases DESC;

--Countries with highest death count

SELECT location, MAX(total_deaths) AS high_deaths FROM covid_deaths
WHERE continent IS NOT null
GROUP BY location ORDER BY high_deaths DESC;

--Breaking things by continent

SELECT location, MAX(total_deaths) AS high_deaths FROM covid_deaths
WHERE continent IS null
GROUP BY location ORDER BY high_deaths DESC;

--Continents with highest death count per population

SELECT continent, 
MAX(total_deaths) AS death_counts 
FROM covid_deaths GROUP BY continent ORDER BY death_counts DESC;

--Shows death percentage as time increases

SELECT date, SUM(new_cases) AS cases, SUM(new_deaths) AS deaths,
(SUM(CAST(new_deaths AS decimal))/SUM(NULLIF(new_cases,0)))*100 AS death_percentage
	FROM covid_deaths GROUP BY date ORDER BY SUM(new_deaths) DESC;
	
--Global numbers

SELECT SUM(new_cases) AS cases, SUM(new_deaths) AS deaths,
(SUM(CAST(new_deaths AS decimal))/SUM(new_cases))*100 AS death_percentage
	FROM covid_deaths;
	
--Joining both tables

SELECT * FROM covid_deaths AS a JOIN covid_vaccines as b
ON a. location = b.location and a.date = b.date;

--Looking at total vaccination vs total populations

SELECT a.continent, a.location,a.date, a.population, b.new_vaccinations
FROM covid_deaths AS a JOIN covid_vaccines AS b
ON a. location = b.location and a.date = b.date 
WHERE b.new_vaccinations IS NOT null AND location ORDER BY new_vaccinations DESC;

SELECT a.location, MAX(b.new_vaccinations) FROM covid_deaths AS a JOIN covid_vaccines AS b ON
a.location = b.location and a.date = b.date WHERE (new_vaccinations) IS NOT null 
AND a.continent IS NOT null
GROUP BY a.location, b.new_vaccinations ORDER BY new_vaccinations DESC;

SELECT a.continent, a.location,a.date, a.population, b.total_vaccinations
FROM covid_deaths AS a JOIN covid_vaccines as b
on a. location = b.location and a.date = b.date 
WHERE a.continent IS NOT null and b.total_vaccinations IS NOT null 
GROUP BY a.location, a.continent, a.date, a.population, b.total_vaccinations 
ORDER BY total_vaccinations DESC;

SELECT a.continent, a.location,a.date, a.population, b.new_vaccinations,
SUM(b.new_vaccinations) OVER (PARTITION BY a.location ORDER BY a.location,a.date)
AS rolling_people_vaccinated
FROM covid_deaths AS a JOIN covid_vaccines as b
on a. location = b.location and a.date = b.date 
WHERE a.continent IS NOT null AND b.total_vaccinations IS NOT null
ORDER BY a.date ASC;

--Looking at vaccination percentage
--(1)
SELECT a.continent, a.location,a.date, a.population,
SUM(b.new_vaccinations) OVER (PARTITION BY a.location ORDER BY a.location,a.date)
AS rolling_people_vaccinated, 
((SUM(b.new_vaccinations) OVER (PARTITION BY a.location 
ORDER BY a.location,a.date))/(a.population))*100 AS vaccination_percentage
FROM covid_deaths AS a JOIN covid_vaccines as b
ON a. location = b.location AND a.date = b.date 
WHERE a.continent IS NOT null AND b.total_vaccinations IS NOT null ORDER BY a.date ASC;

--(2) Using CTE

WITH PopvsVac (Continent, Location, Date, Population,Rolling_people_vaccinated) AS
(SELECT a.continent, a.location,a.date, a.population,
SUM(b.new_vaccinations) OVER (PARTITION BY a.location ORDER BY a.location,a.date)
AS rolling_people_vaccinated 
FROM covid_deaths AS a JOIN covid_vaccines AS b
ON a. location = b.location AND a.date = b.date 
WHERE a.continent IS NOT null AND b.total_vaccinations IS NOT null)
SELECT continent,location,date,(Rolling_people_vaccinated/Population)*100 AS vac FROM Popvsvac

--Creating View

CREATE VIEW population_vaccinated AS SELECT a.continent, a.location,a.date, a.population, b.new_vaccinations,
SUM(b.new_vaccinations) OVER (PARTITION BY a.location ORDER BY a.location,a.date)
AS rolling_people_vaccinated
FROM covid_deaths AS a JOIN covid_vaccines AS b
ON a. location = b.location AND a.date = b.date 
WHERE a.continent IS NOT null AND b.total_vaccinations IS NOT null;