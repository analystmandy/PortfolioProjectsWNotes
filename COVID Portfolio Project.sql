
Select *
From ProjectPortfolio..CovidDeaths
Where continent is not null -- Add to every script
Order By 3,4

--Select *
--From ProjectPortfolio..CovidDeaths
--Order By 3,4


--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths 
--Shows likelihood of dying if you contract COVID in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%states%'
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
--What percentage of your population has gotten Covid and it's been reported

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population (continent is not null)

-- issue with data type (total_deaths): fixed by converting/cast as an integer so its read as a numeric -- very common
-- taking the nvarchar(255) and converting into an integer 
-- now we have another issue with the data, continents are being grouped with countries 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Showing Countries with Highest Death Count per Population (continent is not null)

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc


-- Showing continents with the Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Looking at Global Numbers (Across the world)
-- new_cases is a float, new_deaths is in varchar = use cast as an integer

-- Global Numbers by Date

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

-- Global Numbers total (no date)

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2


-- Looking at Total Population vs Vaccination (Global)
-- cast as int is the same as convert int

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac



-- TEMP TABLE

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
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated



-- Creating View to Store Data for Later Visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3


Select *
From PercentPopulationVaccinated