
/*==========================================================================*/
-- TEST RUN
Select Location, date, total_cases, new_cases, total_deaths, population
-- select columns for info
From coviddeath_data_project cdp 
-- from covid death table
order by 1, 2 desc
-- order asc by first two columns (location and date) 

/*==========================================================================*/

-- Now, let's look at Total deaths vs Total cases (in U.S.)

SELECT location, date , total_cases , total_deaths , 
(CAST(total_deaths AS FLOAT) / total_cases) * 100 AS death_rate
FROM coviddeath_data_project cdp 
where location like '%states%'
and continent is not null
ORDER BY 1, 2

-- This returns the chance of dying from getting covid (in percent)

/*==========================================================================*/

-- Now, let's look at Total case vs Total population (in U.S.)

SELECT location, date , total_cases , population , 
(CAST(total_cases AS FLOAT) / population) * 100 AS getting_covid_rate
FROM coviddeath_data_project cdp 
where location like '%states%'
and continent is not null
ORDER BY 1, 2

-- This returns the chance of getting covid (in percent)

/*==========================================================================*/

-- Countries with highest infection rate

SELECT location, population, MAX(total_cases) as Highest_Case_Recorded, 
max((cast(total_cases as float)/population)) * 100 AS infection_rate
from coviddeath_data_project cdp 
where continent is not null
group by location, population
order by 4 desc

/*==========================================================================*/

-- Countries with highest death count among population

SELECT location, population , max(total_deaths) as highest_death_recorded, 
MAX(cast(total_deaths as float)/population) * 100  as death_vs_population
from coviddeath_data_project cdp 
where continent is not null
group by location, population 
order by 4 desc

/*==========================================================================*/

-- Countries with highest death 

SELECT location, max(total_deaths) as highest_death_recorded
from coviddeath_data_project cdp 
where continent is not null
group by location
order by 2 desc
/*==========================================================================*/

-- Continent with highest death 

SELECT continent , max(total_deaths) as highest_death_recorded
from coviddeath_data_project cdp 
where continent is not null
group by continent 
order by 2 desc

/*==========================================================================*/

-- Global Info

SELECT date, sum(new_cases) as total_new_cases, sum(new_deaths) as total_new_deaths
, (sum(CAST(new_deaths AS FLOAT))/ sum(new_cases)) * 100 AS death_rate
FROM coviddeath_data_project cdp  
WHERE continent is not null
GROUP BY date
HAVING death_rate is not null
ORDER BY 1

/*==========================================================================*/

-- COVID Population & Vaccination (Method 1: CTE)

WITH popvacc (continent, location, date, population, new_vaccinations, Sum_Vacc_overtime) AS
(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
(sum(vac.new_vaccinations) over (PARTITION by death.location Order by death.location, death.date)) as Sum_Vacc_overtime
from coviddeath_data_project as death
inner join covidvaccination_data_project as vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null and vac.new_vaccinations is not null
--order by 2,3
)

SELECT continent, location, date, population, new_vaccinations, Sum_Vacc_overtime, (cast(Sum_Vacc_overtime as float)/population) * 100 as Vacc_rate
FROM popvacc
ORDER BY 2,3

-- COVID Population & Vaccination (Method 2: Temp Table)
Drop table if exists popvsvacc

CREATE TEMP TABLE popvsvacc (
    continent varchar(255),
    location varchar(255),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    Sum_Vacc_overtime numeric
);

INSERT INTO popvsvacc
SELECT 
    death.continent, 
    death.location, 
    death.date, 
    death.population, 
    vac.new_vaccinations, 
    (SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date)) AS Sum_Vacc_overtime
FROM 
    coviddeath_data_project AS death
INNER JOIN 
    covidvaccination_data_project AS vac
ON 
    death.location = vac.location
    AND death.date = vac.date
WHERE 
    death.continent IS NOT NULL 
    AND vac.new_vaccinations IS NOT NULL

SELECT 
    continent, 
    location, 
    date, 
    population, 
    new_vaccinations, 
    Sum_Vacc_overtime, 
    (Cast(Sum_Vacc_overtime as float) / population) * 100 AS Vacc_rate
FROM 
    popvsvacc
ORDER BY 
    2, 3

