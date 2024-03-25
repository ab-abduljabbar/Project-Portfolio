select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


select *
from PortfolioProject..CovidVaccinations
order by 3,4

select location, date total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--what % have got Covid--

select location, date, population, total_cases,  
(total_cases/population)*100 as DeathPercentange
from PortfolioProject..CovidDeaths
where location like '%States%'
order by 1,2

--looking at countries with highest infection rate compared to Population--

select location, population, MAX(total_cases) as HighestInfectionCount,  
MAX((total_cases/population))*100 as PercentageOfPopulationInfected
from PortfolioProject..CovidDeaths

group by location,population
order by 4 DESC

--showing countries with highest death count per population
select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 DESC;
 
 -- Lets break things down by the continent--
 --showing continents with the highest death count per population--
select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths 
where continent is not null 
group by continent
order by 2 DESC

--global numbers
select sum(new_cases) as newcases, SUM(new_deaths) as newdeaths
from PortfolioProject..CovidDeaths 
where continent is not null 


--joins--
with sum_newjab as (
select cd.continent, cd.location, cd.population, cv.new_vaccinations, 
ROW_NUMBER() OVER (partition by cd.location ORDER BY sum(cv.new_vaccinations)) as row_num

from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location 
	and cd.date = cv.date 
	where cv.continent is not null and cv.new_vaccinations is not null 
	group by cd.continent, cd.location, cd.population, cv.new_vaccinations
	
	)

	select *
	from sum_newjab
	where row_num <= 1 


	--totalling sum of new vaccinations && this query sums up the new_vacc row each time

	with sum_newjab as (
	select cd.location, cd.population, cv.new_vaccinations, cv.total_vaccinations,
sum(cv.new_vaccinations) OVER (partition by cd.location ORDER BY cd.location) as total_jabs

from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location 
	and cd.date = cv.date 
	where cv.continent is not null and cv.new_vaccinations is not null 
	
	)
	
	select location, population, new_vaccinations, total_vaccinations,  (total_jabs/population)*100 as PercentageOfPopulationVaccinanted
	from sum_newjab
	group by location, population, new_vaccinations, total_jabs,total_vaccinations
	order by 1 asc;


	







	------------------

	With new_jabs (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From new_jabs


	--temp table-- Creating table method



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



-------------------

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



----------------


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 