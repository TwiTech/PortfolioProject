Select *
From PortfolioProject..CovidDeath
Order by 3,4

Select *
From PortfolioProject..CovidVaccine
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeath
order by 1,2

----loking at total case vs total death

Select location, date, total_cases, total_deaths, (convert (float, total_deaths) / NULLIF(Convert(float, total_cases),0))*100 as DeathPercent
From PortfolioProject..CovidDeath
Where location like '%United%'
order by 1,2


Select location, date, total_cases, total_deaths, (Cast(total_deaths as float) / (Cast(total_cases as float))*100)  AS DeathPercent
From PortfolioProject..CovidDeath
Where location like '%united%'
order by 1,2

Select location, date, population, total_cases, (convert (float, total_cases) / NULLIF(Convert(float, population),0))*100 as InfectedPopulationPercent
From PortfolioProject..CovidDeath
Where location like '%state%'
order by 1,2 

Select location, population, MAX(total_cases) as highestinfected, (Max(convert (float, total_cases)) / NULLIF(Convert(float, population),0))*100 as InfectedPopulationPercent
From PortfolioProject..CovidDeath
--Where location like '%state%'
Where Continent is not null
Group by location, population 
order by InfectedPopulationPercent desc 

-- ##CAST
Select location, population, MAX(total_cases) as highestinfected, (Max(cast (total_cases as float)) / (Cast(population as float)))*100 as InfectedPopulationPercent
From PortfolioProject..CovidDeath
--Where location like '%state%'
Where Continent is not null
Group by location, population 
order by InfectedPopulationPercent desc 

--country with highest death count population
Select location, MAX(total_deaths) as HighestDeath
From PortfolioProject..CovidDeath
Where Continent is not null
Group by location
order by HighestDeath Desc

Select location, MAX(cast (total_deaths as int)) as HighestDeath
From PortfolioProject..CovidDeath
Where Continent is not null
Group by location
order by HighestDeath Desc

--breaking down by continent 

Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
Where Continent is not null
Group by continent
order by TotalDeathCount Desc

--death population globally
Select date, total_cases, total_deaths, (cast (total_deaths as float) / (Cast(total_cases as int)))*100 as InfectedPopulationPercent
From PortfolioProject..CovidDeath
--Where location like '%state%'
Where continent is not null 
order by InfectedPopulationPercent desc 


Select sum(new_cases), sum(cast(new_deaths as int)) as totaldeath, (sum(cast(new_deaths as int)) / sum(NuLLIF (cast (new_cases as Float),0)))*100 as percentagetotalInfected 
From PortfolioProject..CovidDeath
Where continent is not null 
order by 1,2 

--Total population vs total vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeath  dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
From PortfolioProject..CovidDeath  dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated / population)*100
From PopvsVac


--Temp table
Drop Table if exists #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
From PortfolioProject..CovidDeath  dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated / population)*100
From #PercentagePopulationVaccinated


--Creating view to store data for later visualization
Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
From PortfolioProject..CovidDeath  dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentagePopulationVaccinated 