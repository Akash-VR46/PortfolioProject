select * from ['covidVaccinations']
order by 3,4


--select * from ['covidDeath']
--where continent is not null
--order by 3,4 


--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population from ['covidDeath']
order by 1,2

--we look at total cases vs total death
--likelihood of dying if you contact covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as TotalDeathPercent from ['covidDeath']
where location = 'india'
order by 1,2


--looking at total cases vs population\
--shows what percentage of population got covid


select location,date,population,total_cases,(total_cases/population)*100 as percentpopulationinfected from ['covidDeath']
--where location = 'india'
order by 1,2

--looking at countries with highest infection rate compared to population

select location,population,Max(total_cases) as HighestInfectedCount,Max((total_cases/population))*100 as percentpopulationinfected from ['covidDeath']
--where location = 'india'
group by location,population
order by percentpopulationinfected desc


--showing countries with highest deathcount per population

select location,Max(cast(total_deaths as int)) as TotalDeathCount from ['covidDeath']
--where location = 'india'
where continent is not null
group by location
order by TotalDeathCount desc

--Let's Break things by continent
--showing continents with highest dealth count per continent

select continent,Max(cast(total_deaths as int)) as TotalDeathCount from ['covidDeath']
--where location = 'india'
where continent is not null
group by continent
order by TotalDeathCount desc



--Global Numbers


select sum(new_cases) as total_cases,sum(CAST(new_deaths as int)) as total_death,sum(CAST(new_deaths as int))/sum(new_cases) * 100 as death_percentage
from ['covidDeath']
where continent is not null
order by 1,2


--looking at total vaccinated vs population

with popvsvacc (continent,Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as(

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location,dea.date) as rollingpeoplevaccinated
from  ['covidDeath'] dea
join ['covidVaccinations'] vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--der by 2,3
)

select *,(RollingPeopleVaccinated/Population)*100 from popvsvacc



--Temp table

create table #pecentpopulationsvaccinated(
continent nvarchar(255),
Location nvarchar(255),
date Datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric)

Insert into #pecentpopulationsvaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location,dea.date) as RollingPeopleVaccinated 
from  ['covidDeath'] dea
join ['covidVaccinations'] vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--der by 2,3


select *,(RollingPeopleVaccinated/Population)*100 from #pecentpopulationsvaccinated



--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location,dea.date) as RollingPeopleVaccinated 
from  ['covidDeath'] dea
join ['covidVaccinations'] vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3



select * from PercentPopulationVaccinated