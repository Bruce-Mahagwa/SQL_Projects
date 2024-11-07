--1. Get a sample of the DATA we are going to use

--Select TOP 5 * from CovidVaccinations ORDER BY date DESC

--Select TOP 5 * from CovidDeaths ORDER BY date DESC

--2. Select the data we are going to use
--Select top 5 location, date, total_cases, new_cases, total_deaths, population from CovidDeaths
--ORDER BY location, date

-- Looking at total cases versus total deaths in individual cases
-- It shows the likelihood of dying if you contract COVID in your country
--Select total_cases, total_deaths, location,
--(CASE
	--WHEN total_cases>0 THEN ((total_deaths*1.0)/total_cases) * 100
	--ELSE Null
--END) AS death_percentage
--from CovidDeaths WHERE location='Mexico'

-- Looking at the total case versus the population
-- Shows what percentage of the population has COVID
--Select date, total_cases, population, location,
--(CASE
--	WHEN total_cases>0 THEN ((total_cases * 1.0) / population) * 100
--	ELSE Null
--END) AS infection_percentage
--from CovidDeaths WHERE location = 'Kenya'

-- Select records with a percentage rate of infection higher than 0.5%

--With Kenya_CTE AS (Select date, total_cases, population, location,
--(CASE
--	WHEN total_cases>0 THEN ((total_cases * 1.0) / population) * 100
--	ELSE Null
--END) AS infection_percentage
--from CovidDeaths WHERE location = 'Kenya')
--Select date, total_cases, population, location, infection_percentage 
--FROM Kenya_CTE WHERE infection_percentage >= 0.5

-- Order countries that exhibited the highest infection rates at a given time

--Select location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases * 1.0) / population) * 100 AS highest_infection_rate
--FROM CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY location, population
--ORDER BY highest_infection_rate DESC

-- Order countries that had the highest death rates

--Select location, population, MAX(total_deaths) AS highest_death_count, MAX((total_deaths * 1.0) / population) * 100 AS highest_death_rates
--FROM CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY location, population
--ORDER BY highest_death_rates DESC

-- QUERIES BASED ON CONTINENT

-- Showing continents with the highest death counts

--Select continent, MAX(total_deaths) AS highest_death_count, MAX((total_deaths * 1.0) / population) * 100 AS highest_death_rates
--FROM CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY highest_death_rates DESC

-- QUERIES BASED ON GLOBAL DATA

-- Get sum of new_cases on specific dates globally

--Select date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ((SUM(new_deaths) * 1.0) / NULLIF(SUM(new_cases), 0)) * 100 AS percentage_deaths
--FROM CovidDeaths
--GROUP BY date

-- BRINGING IN THE COVID VACCINATIONS TABLE

---- Finds total number of people who have been vaccinated in countries

--WITH Deaths_Vaccinations_CTE AS (Select Deaths.date, Deaths.continent, Deaths.population,
--Deaths.location, Vaccines.people_vaccinated, Vaccines.people_fully_vaccinated
--FROM CovidDeaths AS Deaths
--INNER JOIN CovidVaccinations AS Vaccines
--ON Deaths.location = Vaccines.location
--AND Deaths.date = Vaccines.date)
--Select location, SUM(cast(people_vaccinated as bigint)) AS total_vaccinated,
--SUM(cast(people_fully_vaccinated as bigint)) AS total_vaccinated_fully
--FROM Deaths_Vaccinations_CTE
--GROUP BY location

-- Find new vaccinations on a rolling basis per country using CTES
--WITH Deaths_Vaccinations_CTE_1 AS (Select Deaths.date, Deaths.continent, Deaths.population,
--Deaths.location, Vaccines.new_vaccinations, 
--SUM(cast(Vaccines.new_vaccinations as bigint)) OVER (Partition by Deaths.location ORDER BY Deaths.date, Deaths.location) AS cumulative_new_vaccinations
--FROM CovidDeaths AS Deaths
--INNER JOIN CovidVaccinations AS Vaccines
--ON Deaths.location = Vaccines.location
--AND Deaths.date = Vaccines.date)
--Select *, ((cumulative_new_vaccinations * 1.0) / population) * 100
--AS cumulative_percentage_new_vaccinations
--from Deaths_Vaccinations_CTE_1 WHERE new_vaccinations <> '' 
--ORDER BY location

-- Creating views to store data for later visualizations

--GO
--CREATE VIEW Deaths_Vaccinations AS
--Select Deaths.continent, Deaths.date, Deaths.population, Deaths.location,
--Vaccines.new_vaccinations, SUM(cast(Vaccines.new_vaccinations as bigint)) OVER (Partition by Deaths.location ORDER BY Deaths.location, Deaths.date) AS cumulative_new_vaccinations
--FROM CovidDeaths AS Deaths
--INNER JOIN CovidVaccinations AS Vaccines
--ON Deaths.location = Vaccines.location AND Deaths.date = Vaccines.date
--GO
--Select *, ((cumulative_new_vaccinations * 1.0) / population) * 100
--AS cumulative_percentage_new_vaccinations
--from Deaths_Vaccinations WHERE new_vaccinations <> '' 
--ORDER BY location
