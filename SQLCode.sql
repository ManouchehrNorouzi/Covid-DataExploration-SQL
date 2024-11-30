Create table Coviddeaths (
	iso_code varchar(50),
	continent varchar(50),
	location varchar(50),
	date date,
	population bigint,
	total_cases bigint,
	new_cases bigint,
	new_cases_smoothed real,
	total_deaths bigint,
	new_deaths bigint,
	new_deaths_smoothed real,
	total_cases_per_million real,
	new_cases_per_million real,
	new_cases_smoothed_per_million real,
	total_deaths_per_million real,
	new_deaths_per_million real,
	new_deaths_smoothed_per_million real,
	reproduction_rate real,
	icu_patients bigint,
	icu_patients_per_million real,
	hosp_patients bigint,
	hosp_patients_per_million real,
	weekly_icu_admissions bigint,
	weekly_icu_admissions_per_million real,
	weekly_hosp_admissions real,
	weekly_hosp_admissions_per_million real
);

ALTER TABLE Coviddeaths
ALTER COLUMN weekly_hosp_admissions TYPE real;


\COPY Coviddeaths(iso_code, continent, location, date, population,	total_cases, new_cases, new_cases_smoothed, total_deaths, new_deaths, new_deaths_smoothed, total_cases_per_million, new_cases_per_million, new_cases_smoothed_per_million, total_deaths_per_million, new_deaths_per_million,	new_deaths_smoothed_per_million, reproduction_rate,	icu_patients, icu_patients_per_million, hosp_patients,	hosp_patients_per_million,	weekly_icu_admissions,	weekly_icu_admissions_per_million,	weekly_hosp_admissions, weekly_hosp_admissions_per_million) FROM 'C:/Users/ASUS/Desktop/Portfolio Files/1/CovidDeaths.csv' CSV HEADER;

select count(*) from coviddeaths;
-----------------------------------------------

CREATE TABLE Covidvaccination (
	iso_code varchar(50),
	continent varchar(50),
	location varchar(50),
	date date,
	new_tests bigint,
	total_tests bigint,
	total_tests_per_thousand real,
	new_tests_per_thousand real,
	new_tests_smoothed real,
	new_tests_smoothed_per_thousand real,
	positive_rate real,
	tests_per_case real,
	tests_units bigint,
	total_vaccinations bigint,
	people_vaccinated bigint,
	people_fully_vaccinated bigint,
	new_vaccinations bigint,
	new_vaccinations_smoothed real,
	total_vaccinations_per_hundred real,
	people_vaccinated_per_hundred real,
	people_fully_vaccinated_per_hundred real,
	new_vaccinations_smoothed_per_million real,
	stringency_index real,
	population_density real,
	median_age real,
	aged_65_older real,
	aged_70_older real,
	gdp_per_capita real,
	extreme_poverty real,
	cardiovasc_death_rate real,
	diabetes_prevalence real,
	female_smokers real,
	male_smokers real,
	handwashing_facilities real,
	hospital_beds_per_thousand real,
	life_expectancy real,
	human_development_index real
)


ALTER TABLE covidvaccination
ALTER COLUMN tests_units TYPE varchar(50);


\copy Covidvaccination (iso_code, continent, location, date, new_tests, total_tests, total_tests_per_thousand, new_tests_per_thousand, new_tests_smoothed, new_tests_smoothed_per_thousand, positive_rate, tests_per_case, tests_units, total_vaccinations, people_vaccinated, people_fully_vaccinated, new_vaccinations, new_vaccinations_smoothed, total_vaccinations_per_hundred, people_vaccinated_per_hundred, people_fully_vaccinated_per_hundred, new_vaccinations_smoothed_per_million, stringency_index, population_density, median_age, aged_65_older, aged_70_older, gdp_per_capita, extreme_poverty, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, hospital_beds_per_thousand, life_expectancy, human_development_index) from 'C:\Users\ASUS\Desktop\Portfolio Files\1\CovidVaccinations.csv' CSV HEADER;


select count(*) from covidvaccination;
--------------------------------------------------------

SELECT * from coviddeaths limit 1;

/*Rate of people died in a Counrtry*/
SELECT location, date, total_cases, total_deaths, 
       ROUND((total_deaths::NUMERIC / total_cases) * 100, 3) AS DeathRate
FROM coviddeaths
WHERE location LIKE '%Germany%' and continent is not null
ORDER BY DeathRate DESC;


/*Rate of people Got disease in a Counrtry*/
SELECT location, date, total_cases, population, 
       ROUND((total_cases::NUMERIC / population) * 100, 3) AS InfectionRate
FROM coviddeaths
WHERE location LIKE '%Germany%' and continent is not null
ORDER BY InfectionRate DESC;


/* Countries with highest InfectionRate and Population*/
SELECT location, MAX(total_cases) as HighestInfectionCount, population,
	MAX(ROUND((total_cases::NUMERIC / population) * 100, 3)) as InfectionRate
FROM coviddeaths
where continent is not null
group by location, population
ORDER by InfectionRate DESC;


/* Countries with highest DeathRate and Population*/
SELECT location, MAX(total_deaths) as HighestDeathCount, population,
	MAX(ROUND((total_deaths::NUMERIC / population) * 100, 3)) as DeathRate
FROM coviddeaths
where continent is not null
group by location, population
ORDER by DeathRate DESC;


/* Countries with highest Death count by location and continent*/
SELECT location, MAX(total_deaths) as HighestDeathCount
FROM coviddeaths
where total_deaths is not null and continent is not null
group by location
ORDER by HighestDeathCount DESC;


SELECT continent, MAX(total_deaths) as HighestDeathCount
FROM coviddeaths
where total_deaths is not null and continent is not null
group by continent
ORDER by HighestDeathCount DESC;


SELECT location, MAX(total_deaths) as HighestDeathCount
FROM coviddeaths
where total_deaths is not null and continent is null
group by location
ORDER by HighestDeathCount DESC;



-- Continents with the highest death count

select location, population, Max(round((total_deaths::Numeric/population) *100,3)) as DeathRate
from coviddeaths
where continent is null
group by location, population
order by Deathrate desc


-- Global Cases and Deaths by Date
select date,  sum(new_deaths) as DailyDeaths, sum(new_cases) as DailyCases,
		round(sum(new_deaths::Numeric)/sum(new_cases)*100, 3) as DailyRate
from coviddeaths
where continent is null and new_cases != 0
group by date
order by date

-- Vaccination vs Population
SELECT d.continent, d.location, population, v.date, v.new_vaccinations
from coviddeaths d join covidvaccination v
	on d.date= v.date
		and d.location= v.location
where v.continent is not null
order by 1,2,3


-- Cululative Vaccination by for each Country by Date

SELECT d.continent, d.location, v.date, d.population, v.new_vaccinations, 
       SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY v.date) AS cumulative_vaccinations
FROM coviddeaths d
JOIN covidvaccination v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL and d.continent like '%Europ%'
ORDER BY d.continent, d.location, v.date)


with popvsvac (continent, location, date, population, new_vaccinations, cumulative_vaccinations)
as(
SELECT d.continent, d.location, v.date, d.population, v.new_vaccinations, 
       SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY v.date) AS cumulative_vaccinations
FROM coviddeaths d
JOIN covidvaccination v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL and d.continent like '%Europ%'
ORDER BY 1, 2, 3)
select *, round((cumulative_vaccinations/population)*100, 3) as Rate
from popvsvac;


-- Temp Table
Drop table if exists PercentPopulationVaccinated;

create temp table PercentPopulationVaccinated(
	continent varchar(255),
	location varchar(255),
	date date,
	population numeric,
	new_vaccinations numeric,
	cumulative_vaccinations real
);

insert into PercentPopulationVaccinated
SELECT d.continent, d.location, v.date, d.population, v.new_vaccinations, 
       SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY v.date) AS cumulative_vaccinations
FROM coviddeaths d
JOIN covidvaccination v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NUll
ORDER BY 1, 2, 3

-- Creating Views
create view PercentPopulationVaccinated as
SELECT d.continent, d.location, v.date, d.population, v.new_vaccinations, 
       SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY v.date) AS cumulative_vaccinations
FROM coviddeaths d
JOIN covidvaccination v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NUll
ORDER BY 1, 2, 3


select * from PercentPopulationVaccinated





