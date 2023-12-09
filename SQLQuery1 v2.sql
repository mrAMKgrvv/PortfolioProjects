
Select *
From Portfolioproject.dbo.CovidDeaths
Where continent is not null
Order By 3,4


--Select *
--From Portfolioproject.dbo.Covidvaccination
--Order By 3,4
--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject.dbo.CovidDeaths
Where continent is not null
Order By 1,2

--Looking at Total cases vs Total deaths
--shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as Deathpercentage
From Portfolioproject.dbo.CovidDeaths
Where location like '%Afghanistan%'
and continent is not null
Order By 1,2

--looking at the Total cases vs Population
--Shows what percentage of population got covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentagePopulationInfected
From Portfolioproject.dbo.CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null
Order By 1,2

--looking at countries with highest infection rtes compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentagePopulationInfected
From Portfolioproject.dbo.CovidDeaths
--Where location like '%Nigeria%'
Group By continent
Order By PercentagePopulationInfected desc 

--Showing Countries with highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject.dbo.CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null
Group By continent
Order By TotalDeathCount desc 

--LET'S BREAK THING DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject.dbo.CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null
Group By continent
Order By TotalDeathCount desc 

--Showing continents with Highest Death Count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject.dbo.CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null
Group By continent
Order By TotalDeathCount desc 

--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From Portfolioproject.dbo.CovidDeaths
--Where location like '%Afghanistan%'
Where continent is not null
Group by date
Order By 1,2

--Joining both tables


Select *
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
Order by 2,3

--USE CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
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

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
	--Where dea.continent is not null
--Order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select * 
From PercentPopulationVaccinated
