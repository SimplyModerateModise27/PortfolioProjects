SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
  FROM [PortofolioProject].[dbo].[CovidDeaths]
  SE

  SELECT *
  FROM CovidDeaths
  WHERE continent IS NOT NULL;

  SELECT location, date, total_cases, new_cases, total_deaths , total_cases, population
  FROM CovidDeaths
  ORDER BY 1,2;

  SELECT location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 as Mortality
  FROM CovidDeaths
  WHERE location like '%South Africa%' AND continent IS NOT NULL;
  ORDER BY 1,2;

  SELECT location, date, total_cases, population , (total_cases/population)*100 as InfectionRate
  FROM CovidDeaths
  WHERE location like '%South Africa%' AND continent IS NOT NULL;
  ORDER BY 1,2;

  SELECT location, population, MAX(total_cases) as HighInfectCount, MAX((total_cases/population)*100) as PercentPopulationInfected
  FROM PortofolioProject..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY location, population
  ORDER BY PercentPopulationInfected desc;

  SELECT location, population, MAX(CAST(total_deaths AS int)) as HighDeathCount, 
  MAX((total_deaths/population)*100) as PercentDeathsPopulation
  FROM PortofolioProject..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY location, population
  ORDER BY PercentDeathsPopulation desc;


  SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
  FROM CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY location
  ORDER BY TotalDeathCount desc;


  SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
  FROM CovidDeaths
  WHERE continent IS NULL
  GROUP BY location
  ORDER BY TotalDeathCount desc;

  SELECT --date,
  SUM(new_cases) AS TotalCases, 
  SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
  SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
  FROM CovidDeaths
  WHERE continent IS NOT NULL
  --GROUP BY date
  ORDER BY 1,2;

  SELECT Dea.continent, Dea.location, Dea.date, Dea.population,
  Vac.new_vaccinations, 
  SUM(CONVERT(int,Vac.new_vaccinations))
  OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
  FROM CovidDeaths Dea 
  JOIN CovidVaccinations Vac
	ON Dea.date = Vac.date 
	AND Dea.location = Vac.location
  WHERE Dea.continent IS NOT NULL
  ORDER BY 2,3

  --use CTE 
  With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
  as
  (
  SELECT Dea.continent, Dea.location, Dea.date, Dea.population,
  Vac.new_vaccinations, 
  SUM(CONVERT(int,Vac.new_vaccinations))
  OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
  FROM CovidDeaths Dea 
  JOIN CovidVaccinations Vac
	ON Dea.date = Vac.date 
	AND Dea.location = Vac.location
  WHERE Dea.continent IS NOT NULL
  --ORDER BY 2,3
  )
  SELECT *, (RollingPeopleVaccinated/population)*100 as TotalPopulationVaccinated
  FROM PopvsVac;


  --USE TEMP TABLES

  Drop Table if exists #PercentPeopleVaccinated
  CREATE Table #PercentPeopleVaccinated
  (
   continent nvarchar(255),
   location nvarchar(255),
   date datetime,
   population numeric,
   new_vaccinations numeric, 
   RollingPeopleVaccinated numeric
   )

  INSERT INTO #PercentPeopleVaccinated
  SELECT Dea.continent, Dea.location, Dea.date, Dea.population,
  Vac.new_vaccinations, 
  SUM(CONVERT(int,Vac.new_vaccinations))
  OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
  FROM CovidDeaths Dea 
  JOIN CovidVaccinations Vac
	ON Dea.date = Vac.date 
	AND Dea.location = Vac.location
  WHERE Dea.continent IS NOT NULL
  --ORDER BY 2,3

  SELECT *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
  FROM #PercentPeopleVaccinated

  Create View PercentPeopleVaccinated AS
  SELECT Dea.continent, Dea.location, Dea.date, Dea.population,
  Vac.new_vaccinations, 
  SUM(CONVERT(int,Vac.new_vaccinations))
  OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
  FROM CovidDeaths Dea 
  JOIN CovidVaccinations Vac
	ON Dea.date = Vac.date 
	AND Dea.location = Vac.location
  WHERE Dea.continent IS NOT NULL
  --ORDER BY 2,3

  SELECT * 
  FROM PercentPeopleVaccinated

  CREATE VIEW PopvsVac AS 
  SELECT Dea.continent, Dea.location, Dea.date, Dea.population,
  Vac.new_vaccinations, 
  SUM(CONVERT(int,Vac.new_vaccinations))
  OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
  FROM CovidDeaths Dea 
  JOIN CovidVaccinations Vac
	ON Dea.date = Vac.date 
	AND Dea.location = Vac.location
  WHERE Dea.continent IS NOT NULL
  --ORDER BY 2,3

  SELECT *
  FROM PopvsVac