/*==========================================================================*/
-- Tableau Sheet 1

SELECT sum(new_cases) as sum_new_cases, 
	   sum(cast(new_deaths as float)) as sum_new_deaths,
	   (sum(cast(new_deaths as float))/sum(new_cases))*100 as deaths_rate
FROM coviddeath_data_project cdp 
Where continent is not null
Order by 1,2

/*==========================================================================*/
-- Tableau Sheet 2

Select location, SUM(cast(new_deaths as float)) as TotalDeathCount
From coviddeath_data_project cdp 
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income' )
Group by location
order by TotalDeathCount desc

/*==========================================================================*/
-- Tableau Sheet 3

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max(cast(total_cases as float)/population)*100 as PercentPopulationInfected
From coviddeath_data_project cdp 
Group by Location, Population
order by PercentPopulationInfected desc

/*==========================================================================*/
-- Tableau Sheet 4

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max(cast(total_cases as float)/population)*100 as PercentPopulationInfected
From coviddeath_data_project cdp 
Group by Location, Population, date
order by PercentPopulationInfected desc



