select * 
from PortfolioProject..CovidDeaths
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--total cases(infected) vs total deaths(death)=>DEATH PERCENTAGE
--SHOWS THE CAHANCES OF DYING IF INFECTED
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from CovidDeaths
where location like 'I%dia%'
order by 1,2

--looking at total cases vs population
--Infected population
select location,date,total_cases,Population,(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
--where location like 'I%dia%'
order by 1,2

--looking at contries with highest infection rate compared to their population
select location, max(total_cases) as HighestInfectionCount, Population, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like 'I%dia%'
group by location,population
order by PercentPopulationInfected desc

--showing yhe contries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like 'I%dia%'
where continent is not null
group by location
order by TotalDeathCount desc

--lets break things down by continent

--showing the continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like 'I%dia%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers
select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as deathPercentage
from CovidDeaths
--where location like 'I%dia%'
where continent is not null
group by date
order by 1,2



--looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Using cte
with PopVsVac as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

)
select *,(RollingPeopleVaccinated/population)*100
from PopVsVac

--Using temp table also we can do it

--Creating Views to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated
