select * 
from PortfolioProject..CovidDeaths
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- top 10 countries with highest infection 
select top(10) continent,location,population, max(total_cases) as HighestInfectionViaCountry 
from PortfolioProject..CovidDeaths
where continent is not null
group by continent,location,population
order by 4 desc

-- total deaths count

select top(10) location,population, max(cast(total_deaths as int)) as totalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by 3 desc

--error

select population
from (select distinct location from PortfolioProject..CovidDeaths)

--
select date,location,population, (total_deaths/total_cases)*100 as totalDeathsPercentage
from PortfolioProject..CovidDeaths
where continent is not null
and location like 'India'
order by 1 

--highest 
select location,population, max((total_cases/population)) as FatalityRate, max(total_cases) as Highestinfection 
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by 3 desc ,4 desc

-----new vaccines

select dea.location, dea.date,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over (partition by 
dea.location order by dea.date) as CumulativeVaccines
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null

group by dea.location,dea.date,vac.new_vaccinations
order by 1,2

--using CTE for vaccination percentage

With PopvsVac(Location,Date,Population,new_vaccinations,CumulativeVaccines)
AS(

select dea.location, dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over (partition by 
dea.location order by dea.date) as CumulativeVaccines
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null

group by dea.location,dea.date,dea.population,vac.new_vaccinations
--order by 1,2
)
Select * , (CumulativeVaccines/Population)*100 as VaccinationPercentage
from PopvsVac

--temp tablle

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Location nvarchar(100),
Date nvarchar(255),
Population numeric,
new_vaccinations numeric,
CumulativeVaccines numeric
)
 Insert into #PercentPopulationVaccinated
 select dea.location, dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over (partition by 
dea.location order by dea.date) as CumulativeVaccines
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null

group by dea.location,dea.date,dea.population,vac.new_vaccinations
order by 1,2

Select * , (CumulativeVaccines/Population)*100 as VaccinationPercentage
from #PercentPopulationVaccinated

--creating views
 
Create View PercentPopulationVaccinated as
select dea.location, dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over (partition by 
dea.location order by dea.date) as CumulativeVaccines
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null

group by dea.location,dea.date,dea.population,vac.new_vaccinations
--order by 1,2

select * from PercentPopulationVaccinated