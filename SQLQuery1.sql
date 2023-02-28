create table dbo.covid_deaths
(
iso_code varchar(10),
continent varchar(20),
location varchar(50),
date date,
total_cases int,
new_cases int,
new_cases_smoothed decimal(12,3),
total_deaths int,
new_deaths int,
new_deaths_smoothed decimal(12,3),
total_cases_per_million decimal(12,3),
new_cases_per_million decimal(12,3),
new_cases_smoothed_per_million decimal(12,3),
total_deaths_per_million decimal(12,3),
new_deaths_per_million decimal(12,3),
new_deaths_smoothed_per_million decimal(12,3),
reproduction_rate decimal(12,3),
icu_patients int,
icu_patients_per_million decimal(12,3),
hosp_patients int,
hosp_patients_per_million decimal(12,3),
weekly_icu_admissions int,
weekly_icu_admissions_per_million decimal(12,3),
weekly_hosp_admissions int,
weekly_hosp_admissions_per_million decimal(12,3),
total_tests int
);



select * from [dbo].[vaccinedata]
--drop table dbo.[vaccinedata]
--alter table [dbo].[Sheet1$] to dbo.vaccinedata
--rename table
EXEC sp_rename '[dbo].[Sheet1$]', 'vaccinedata';
select * from portfolio..covid_deaths
order by 3,4
--checking for what are the countries data we have
select distinct(Location) from portfolio..covid_deaths
--creating thenew column population for the countries data we have
--join country population and covid deaths data
select a.*,b.population from portfolio..covid_deaths as a 
inner join portfolio..countrypopulation as b 
on a.location=b.location ;
--select * from portfolio..countrypopulation
--delete data from country population table
--delete from portfolio..countrypopulation
---DATA EXPLORATION---

--select the data we are using

--looking at the Total Cases Vs Total Deaths 
select Location,date,total_cases,total_deaths,
(cast(coalesce(total_deaths,0) as decimal(12,3))/cast(coalesce(total_cases,1) as decimal(12,3)))*100 as DeathPercentage
From Portfolio..covid_deaths
order by 3 desc, 4 desc;

--get the dates where two consecutive days new cases are more than 100
SELECT *
FROM
(
select 
DATE,
ISO_CODE,
coalesce(new_cases,0) AS new_cases,
LAG(coalesce(new_cases,0)) OVER(PARTITION BY ISO_CODE ORDER BY DATE ASC) AS PREV_NEW_CASES,
LAG(coalesce(DATE,CONVERT(DATETIME,'01-01-1900'))) OVER(PARTITION BY ISO_CODE ORDER BY DATE ASC) AS PREV_DATE,
RANK() OVER(PARTITION BY ISO_CODE ORDER BY coalesce(new_cases,0) DESC) AS RNK_NEW_CASES,
DENSE_RANK() OVER(PARTITION BY ISO_CODE ORDER BY coalesce(new_cases,0) DESC) AS DNS_RNK_NEW_CASES,
ROW_NUMBER() OVER(PARTITION BY ISO_CODE ORDER BY coalesce(new_cases,0) DESC) AS ROW_NUM
--,coalesce(new_deaths,0) AS new_deaths
from 
[dbo].[covid_deaths]
where --iso_code='AFG' AND
coalesce(new_cases,0)>=100
) T1
WHERE PREV_NEW_CASES>=100 AND new_cases>=100 
AND
DATEDIFF(DAY,PREV_DATE,DATE)=1
ORDER BY ISO_CODE,DATE;

---
select* from portfolio..covid_deaths


--ADDING COLUMN POPULATION TO COVID_DEATHS
select * from portfolio..covid_deaths;
--adding column to the table
alter table portfolio..covid_deaths add population float;

--update column in table t1 using table t2
update t1
set population=t2.population
from
portfolio..covid_deaths t1,
portfolio..countrypopulation t2
where t1.location=t2.location;

--Total cases vs population
--percentage of population got covid
select location,date,total_cases,population,
((total_cases)/(population))*100  as populationpercentage
from portfolio..covid_deaths;

--countries with highest infectionrate with respect to population
select location,population,Max(total_cases) as highestinfection,
max((total_cases)/(population))*100 as populationinfected
from portfolio..covid_deaths
group by location,population
order by populationinfected desc

--showing countries with highest death count per population

--bulgaria more than 50% of the population died 
select location,population,max(total_deaths) as maxdeaths,
max(total_deaths/population)*100 as deathpopulationpercent
from portfolio..covid_deaths
where continent is not null
group by location,population
order by deathpopulationpercent desc;


--total deaths in each country
select location,max(cast(total_deaths as int)) as TotalDeathscount
from portfolio..covid_deaths
where continent is not null
group by location
order by TotalDeathscount desc



--total deaths in each continent
select continent,max(cast(total_deaths as int)) as TotalDeathscount
from portfolio..covid_deaths
where continent is not null
group by continent
order by TotalDeathscount desc


--global numbers
















