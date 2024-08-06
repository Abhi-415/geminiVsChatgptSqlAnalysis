--1)What are the average scores for each capability on both the Gemini Ultra and GPT-4 models?
select
	c.capabilityid,c.capabilityname,
	Round(avg(b.scoregemini)::decimal,1) as Gemini_avg_score,
	Round(avg(b.scoregpt4)::decimal,1) as GPT4_avg_score
from benchmarks b
left join capabilities c
	on b.capabilityid=c.capabilityid
left join models m
	on b.modelid=m.modelid
group by c.capabilityid,c.capabilityname
	order by c.capabilityid;

--2)Which benchmarks does Gemini Ultra outperform GPT-4 in terms of scores?

SELECT m.modelname,b.benchmarkname
from benchmarks b
left join models m
on b.modelid=m.modelid
where b.modelid=1 and b.scoregemini>b.scoregpt4
group by m.modelname,b.benchmarkname;

--3)What are the highest scores achieved by Gemini Ultra and GPT-4 for 
--each benchmark in the Image capability?

select c.capabilityname,b.benchmarkname,
	max(b.scoregemini) as max_geminiscore,
	max(b.scoregpt4) as max_gpt4score
from benchmarks b
	left join capabilities c
	on b.capabilityid=c.capabilityid
where c.capabilityname='Image'
group by c.capabilityname,b.benchmarkname
order by b.benchmarkname;

--Calculate the percentage improvement of Gemini Ultra over GPT-4 for each benchmark?

SELECT benchmarkid,benchmarkname,
	((scoregemini-scoregpt4)/scoregpt4) * 100 as percentage_improvement
from benchmarks
where scoregemini is not NULL AND scoregpt4 is not NULL AND scoregemini>scoregpt4;

--4)Retrieve the benchmarks where both models scored above the average 
--for their respective models?

with averagescore as (
	select avg(scoregemini) as avggeminiscore,
	avg(scoregpt4) as avggpt4score
	from benchmarks
)

select b.*
from benchmarks b, averagescore a
where b.scoregemini>a.avggeminiscore
	AND b.scoregpt4>a.avggpt4score;

--5)Which benchmarks show that Gemini Ultra is expected to outperform GPT-4 
--based on the next score?

Select 
benchmarkid,
benchmarkname,
scoregemini,
scoregpt4,
description
from benchmarks
where scoregemini>scoregpt4;

--7)Classify benchmarks into performance categories based on score ranges?


Select 
benchmarkid,benchmarkname,
scoregemini,scoregpt4,
case
	when scoregemini>=90 then 'Excellent'
	when scoregemini>=75 then 'Good'
	when scoregemini>=60 then 'Average'
	else 'Below Average'
end as GeminiPerformance,
case
	when scoregpt4>=90 then 'Excellent'
	when scoregpt4>=75 then 'Good'
	when scoregpt4>=60 then 'Average'
	when scoregpt4<60 then 'Below Average'
	else 'Unknown'
end as GPT4Performance
from benchmarks;

--8)Retrieve the rankings for each capability based on Gemini Ultra scores?

select c.capabilityname,
b.scoregemini,
dense_rank() over(
	partition by c.capabilityname
	order by b.scoregemini desc) as GeminiRank
from benchmarks b
	left join capabilities c
	on b.capabilityid=c.capabilityid;

--9)Convert the Capability and Benchmark names to uppercase?

Select 
benchmarkid,
upper(benchmarkname),
scoregemini,
scoregpt4,
description
from benchmarks;

Select capabilityid,Upper(capabilityname)
from capabilities;


--10)Can you provide the benchmarks along with their descriptions in a concatenated format?


 Select 
benchmarkid,
scoregemini,
scoregpt4,
concat(Upper(benchmarkname),' : ',description)
from benchmarks;

