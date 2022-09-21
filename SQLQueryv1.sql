Select *
FROM PortfolioProjectCovid..CovidDeaths$
Where continent is not null
order by 3,4
--Select *
--FROM PortfolioProjectCovid..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjectCovid..CovidDeaths$
order by 1,2

--looking at the total cases vs total deaths
--shows likelihood of dying if you contract covid in your area
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProjectCovid..CovidDeaths$
Where location like '%states%'
order by 1,2

--looking at Total Cases vs Population

Select location, date, new_cases, total_deaths, population, (total_cases/population)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths$
Where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

Select location,population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as Percentpopulationinfected
from PortfolioProjectCovid..CovidDeaths$
group by location, population
order by percentpopulationinfected desc

--showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProjectCovid..CovidDeaths$
where continent is not null
group by location
order by totaldeathcount desc

--showing continents with highest death count

Select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProjectCovid..CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc

Select location, MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProjectCovid..CovidDeaths$
Where continent is null
group by location
order by totaldeathcount desc



--global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths$
Where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths$
Where continent is not null
--group by date
order by 1,2

--looking at total pop vs vaccinaitons
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vac_Count
From PortfolioProjectCovid..CovidDeaths$ dea
Join PortfolioProjectCovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

	--USE CTE OR TEMP TABLE TO CREATE USABLE Rolling_Vac_Count
With popvsvac (continent, location, date, population,New_vaccinations,Rolling_Vac_Count)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vac_Count
From PortfolioProjectCovid..CovidDeaths$ dea
Join PortfolioProjectCovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	)
	Select *, (Rolling_Vac_Count/population)*100
	From popvsvac

--TEMP TABLE
--ADD: Drop Table if exists #PercentPopVaccinated        if any alterations are made, when rerun no error will occur
Drop Table if exists #PercentPopVaccinated 
Create table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Vac_Count numeric
)
Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vac_Count
From PortfolioProjectCovid..CovidDeaths$ dea
Join PortfolioProjectCovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

	Select *, (Rolling_Vac_Count/Population)*100
	From #PercentPopVaccinated

--creating view to store data for later visualizations

Create View PercentPopVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vac_Count
From PortfolioProjectCovid..CovidDeaths$ dea
Join PortfolioProjectCovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3