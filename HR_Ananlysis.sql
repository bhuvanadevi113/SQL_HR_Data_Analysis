Use hr_analysis;

describe hr;

-- Column ï»¿id is incorrect and needs to be corrected

Alter table hr 
Change column ï»¿id EmpID varchar(20);

select * from hr;
-- Birthdate data is not formated correctly as it is in text. Have to be formatted.

SET SQL_SAFE_UPDATES=0;

Select birthdate from hr;

update hr
set birthdate=case 
when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
Else NULL
END;

ALTER Table hr
modify column birthdate date;

-- Same goes with hire_date as it has incorrect date format and needs to be converted from text to date

update hr
set hire_date=case 
when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
Else NULL
END;

Select hire_date from hr;
ALTER Table hr
modify column hire_date date;

-- termdate has date and time information together and has null values. This has to be corrected.
update hr
set termdate=date(str_to_date(termdate,'%Y-%m-%d' '%H:%i:%s UTC'))
where termdate is not null and termdate !=' ';

UPDATE hr
SET termdate = NULL
WHERE termdate = '0000-00-00';

select termdate from hr;

ALTER Table hr
modify column termdate date;

/*Adding one more colum to calculate age and using timestampdiff function for 
this to get the difference between birthdat to current date*/

Alter table hr add column age Int;

update hr 
set age =timestampdiff(YEAR,birthdate,curdate());

Select min(age) as youngest,
       max(age) as oldest 
from hr;

Select count(*) 
from hr
where age <18;

-- what is gender breakdown of employees in the company?
select gender,count(*) 
from hr
where age>=18 and termdate is null
group by gender;

-- what is the race/ethnicity breakdow of the employees in the company?
select race,count(*) as count
from hr
where age>=18 and termdate is null
group by race
order by 2 desc;

-- what is the age distribution of the emplyees in the company?
select min(age) as youngest,
max(age) as olderst
from hr
where age>=18 and termdate is null;

select 
case 
when age>=18 and age<=24 then '18-24'
when age>=25 and age<=34 then '25-34'
when age>=35 and age<=44 then '35-44'
when age>=45 and age<=54 then '45-54'
when age>=55 and age<=64 then '55-64'
else '65+'
End as age_group,
count(*) as "count"
from hr
where age>=18 and termdate is null
group by age_group
order by age_group;

select 
case 
when age>=18 and age<=24 then '18-24'
when age>=25 and age<=34 then '25-34'
when age>=35 and age<=44 then '35-44'
when age>=45 and age<=54 then '45-54'
when age>=55 and age<=64 then '55-64'
else '65+'
End as age_group,gender,
count(*) as "count"
from hr
where age>=18 and termdate is null
group by age_group,gender
order by age_group,gender;

-- how many employees work at headquarters vs remote location?
select location,count(*) as count 
from hr
where age>=18 and termdate is null
group by location;

-- what is the average length of employment for employees who have been terminated?
select 
  round(avg(datediff(termdate,hire_date))/365,2) as avg_employment_years
from hr
where termdate is not null and age>=18 and termdate<=curdate();

-- what is the gender distribution in deplartments?
select department,gender,count(*)
from hr
where age>=18 and termdate is null
group by 1,2
order by 1,2;

-- what is the distribution of job titles across the company?
select jobtitle,count(*)
from hr
where age>=18 and termdate is null
group by 1
order by 1;

-- which department has the highest turnover rate?
select department,
total_count,
terminated_count,
terminated_count/total_count as termination_rate
from (
select department,
count(*) as total_count,
sum(case when termdate is not null and termdate<= curdate() then 1 else 0 end) as terminated_count
from hr
where age >=18
group by department ) as sub
order by termination_rate desc;

--- what is the distribution of employees across locations by state?
select location_state,count(*) as count
from hr
where age>=18 and termdate is null
group by location_state
order by 2 desc;

-- how has the company's employee count changed over time based on hire and term dates?
select 
year,
hires,
terminations,
hires-terminations as net_change,
round((hires-terminations)/hires*100,2) as net_change_percent
from (
select year(hire_date) as year,
count(*) as hires,
sum(case when termdate is not null and termdate <=curdate() then 1 else 0 end) as terminations
from hr
where age >=18
group by 1) as sub
order by 1 asc;

-- what is the tenure distribution for each department?
select department,round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from hr
where termdate is not null and termdate<=curdate() and age >=18
group by 1;