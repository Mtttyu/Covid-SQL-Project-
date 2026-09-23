select * 
from Covid..CovidDeaths
order by 3,4

--select * 
--from Covid..CovidVaccinations
--order by 3,4


--data we will work with
select location,date,total_cases,new_cases,total_deaths,population 
from Covid..CovidDeaths
order by 1,2


--total cases VS total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_rate
from Covid..CovidDeaths
--where location='Egypt'
order by 1,2



--totalcases VS population
select location,date,population,total_cases,(total_cases/population)*100 as cases_rate
from Covid..CovidDeaths
--where location='Egypt'
order by 1,2


--Highest cases and infection rate in countries
select location,population,max(total_cases) as max_cases,max((total_cases/population)*100) as cases_rate
from Covid..CovidDeaths
group by location , population
order by 4 desc


--Highest deaths in countries
select location,max(total_deaths)as total_deaths
from Covid..CovidDeaths
where continent is not null
group by location
order by 2 desc




--Highest deaths in continents
select continent,max(total_deaths)as total_deaths
from Covid..CovidDeaths
where continent is not null
group by continent
order by 2 desc



-- Global Numbers

select sum(new_cases)as total_cases,sum(new_deaths)as total_deaths,(sum(new_deaths)/sum(new_cases))*100 as death_rate
from Covid..CovidDeaths
where continent is not null


-- (total cases, total deaths, death rate) ALL per day
select date,sum(new_cases)as total_cases,sum(new_deaths)as total_deaths,(sum(new_deaths)/sum(new_cases))*100 as death_rate
from Covid..CovidDeaths
where continent is not null
group by date
having sum(new_cases) is not null
order by 1,2


-----------------------

-- total population VS total vaccinations
select dea.location,dea.population,max(vac.total_vaccinations) as total_vaccinations
from Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
group by dea.location,dea.population
order by 1


 
select dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(vac.new_vaccinations)over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by 1,2



-- use CTE
with popVSvac (location,date,population,new_vaccinations,RollingPeopleVaccinated)
as (
select dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(vac.new_vaccinations)over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
and vac.new_vaccinations is not null

)

select *,(RollingPeopleVaccinated/population)*100 as VacinatedPercentage
from popVSvac



-- Create VIEW
create view percentpopulationvaccinated as
select dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(vac.new_vaccinations)over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
and vac.new_vaccinations is not null

select * 
from percentpopulationvaccinated