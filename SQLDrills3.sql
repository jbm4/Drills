--1.
https://drive.google.com/file/d/1AOZkcgkRSoLBpdv0BSACHxBmFvznZShz/view?usp=sharing

-- 2. Write a query that returns the namefirst and namelast fields of the people table, 
-- along with the inducted field from the hof_inducted table. 
-- All rows from the people table should be returned, 
-- and NULL values for the fields from hof_inducted should be returned when there is no match found.

SELECT namefirst, 
	namelast, 
	inducted
FROM people AS p
LEFT JOIN hof_inducted as hof
ON p.playerid = hof.playerid;

-- 3. In 2006, a special Baseball Hall of Fame induction was conducted 
-- for players from the negro baseball leagues of the 20th century. 
-- In that induction, 17 players were posthumously inducted into the Baseball Hall of Fame. 
-- Write a query that returns the first and last names, birth and death dates, 
-- and birth countries for these players. Note that the year of induction was 2006, 
-- and the value for votedby will be “Negro League.”

SELECT namefirst,
	namelast,
	birthyear,
	deathyear,
	birthcountry,
	inducted
FROM people AS p
LEFT JOIN hof_inducted as hof
ON p.playerid = hof.playerid
WHERE yearid=2006 
	AND deathyear<2006 
	AND votedby='Negro League';

-- 4.Write a query that returns the yearid, playerid, teamid, and salary fields from the salaries table, 
-- along with the category field from the hof_inducted table. 
-- Keep only the records that are in both salaries and hof_inducted. 
-- Hint: While a field named yearid is found in both tables, don’t JOIN by it. 
-- You must, however, explicitly name which field to include.

SELECT s.yearid,
	s.playerid,
	s.teamid,
	s.salary,
	hof.category
FROM salaries AS s
JOIN hof_inducted AS hof
ON s.playerid=hof.playerid;

-- 5. Write a query that returns the playerid, yearid, teamid, lgid, 
-- and salary fields from the salaries table and the inducted field from the hof_inducted table. 
-- Keep all records from both tables.

SELECT s.yearid,
	s.playerid,
	s.teamid,
	s.lgid,
	s.salary,
	hof.inducted
FROM salaries AS s
FULL OUTER JOIN hof_inducted AS hof
ON s.playerid=hof.playerid;

-- 6. There are 2 tables, hof_inducted and hof_not_inducted, 
-- indicating successful and unsuccessful inductions into the Baseball Hall of Fame, respectively.
-- a. Combine these 2 tables by all fields. Keep all records.

--in this way, you have players who were once put up for it and turned down one previous time on the same line
-- SELECT hof.*, 
-- 	notin.yearid AS notinyearid, 
-- 	notin.votedby AS notinvotedby, 
-- 	notin.ballots AS notinballots, 
-- 	notin.needed AS notinneeded, 
-- 	notin.votes AS notinvotes, 
-- 	notin.inducted AS notininducted, 
-- 	notin.category AS notincategory, 
-- 	notin.needed_note AS notinneeded_note
-- FROM hof_inducted AS hof
-- FULL OUTER JOIN hof_not_inducted as notin
-- ON hof.playerid=notin.playerid;

--could also just do union lol:
SELECT * FROM hof_inducted
UNION ALL
SELECT * FROM hof_not_inducted;

-- b. Get a distinct list of all player IDs for players who have been put up for HOF induction.
SELECT DISTINCT CASE 
					WHEN hof.playerid IS NOT NULL THEN hof.playerid
					ELSE notin.playerid
				END AS allplayerids
FROM hof_inducted AS hof
FULL OUTER JOIN hof_not_inducted as notin
ON hof.playerid=notin.playerid;

--or, using union:
SELECT playerid FROM hof_not_inducted
UNION
SELECT playerid FROM hof_inducted;

-- 7. Write a query that returns the last name, first name (see people table), 
-- and total recorded salaries for all players found in the salaries table.

SELECT namelast, namefirst, SUM(salary) AS total_salary
FROM salaries AS s
LEFT JOIN people AS pp
ON s.playerid=pp.playerid
GROUP BY s.playerid, namelast, namefirst;

-- 8.Write a query that returns all records from the hof_inducted 
-- and hof_not_inducted tables that include playerid, yearid, namefirst, and namelast.
-- Hint: Each FROM statement will include a LEFT OUTER JOIN!

SELECT hof.playerid,
	yearid,
	namefirst,
	namelast
FROM hof_inducted AS hof
LEFT JOIN people AS pp
ON hof.playerid=pp.playerid

UNION ALL --why union all here?

SELECT nothof.playerid,
	yearid,
	namefirst,
	namelast
FROM hof_not_inducted AS nothof
LEFT JOIN people AS pp
ON nothof.playerid=pp.playerid
ORDER BY playerid, yearid;

-- 9. Return a table including all records from both hof_inducted and hof_not_inducted, 
-- and include a new field, namefull, which is formatted as namelast , 
-- namefirst (in other words, the last name, followed by a comma, then a space, then the first name). 
-- The query should also return the yearid and inducted fields. 
-- Include only records since 1980 from both tables. 
-- Sort the resulting table by yearid, then inducted so that Y comes before N. 
-- Finally, sort by the namefull field, A to Z.

SELECT hof.playerid,
	yearid,
	namefirst,
	namelast,
	inducted,
	CONCAT(namelast, ', ', namefirst) AS namefull
FROM hof_inducted AS hof
LEFT JOIN people AS pp
ON hof.playerid=pp.playerid
WHERE yearid>=1980

UNION ALL--why do the answers insist on unionall here?

SELECT nothof.playerid,
	yearid,
	namefirst,
	namelast,
	inducted,
	CONCAT(namelast, ', ', namefirst) AS namefull
FROM hof_not_inducted AS nothof
LEFT JOIN people AS pp
ON nothof.playerid=pp.playerid
WHERE yearid>=1980

ORDER BY yearid, inducted DESC, namefull;

-- 10.Write a query that returns each year's highest annual salary for each teamid, 
-- ranked from high to low, along with the corresponding playerid. 
-- Bonus! Return namelast and namefirst in the resulting table. (You can find these in the people table.)

WITH max_sal AS (
SELECT MAX(salary) AS maximum, teamid, yearid
FROM salaries
GROUP BY teamid, yearid)

SELECT s.teamid,
	s.yearid,
	s.playerid,
	maximum
FROM salaries AS s
RIGHT JOIN max_sal AS mxs
ON s.salary=mxs.maximum AND s.teamid = mxs.teamid AND s.yearid = mxs.yearid
ORDER BY teamid, salary DESC;

--11. Select birthyear, deathyear, namefirst, and namelast of all the players born since the birth year of Babe Ruth 
-- (playerid = ruthba01). Sort the results by birth year from low to high.

SELECT birthyear, deathyear, namefirst, namelast
FROM people
WHERE birthyear > (SELECT deathyear
				 FROM people
				 WHERE playerid = 'ruthba01')
ORDER BY birthyear;

-- 12. Using the people table, write a query that returns namefirst, namelast, and a field called usaborn. 
-- The usaborn field should show the following: 
-- if the player's birthcountry is the USA, then the record is 'USA.' Otherwise, it's 'non-USA.' 
-- Order the results by 'non-USA' records first.
SELECT namefirst, 
	namelast,
	CASE 
		WHEN birthcountry= 'USA' THEN 'USA'
		ELSE 'non-USA'
	END AS usaborn
FROM people
ORDER BY usaborn DESC;

-- 13.Calculate the average height for players throwing with their right hand versus their left hand. 
-- Name these fields right_height and left_height, respectively.

SELECT ROUND(AVG(CASE 
		   	WHEN throws = 'R' THEN height
		   END), 2) AS right_height,
	ROUND(AVG(CASE
		 WHEN throws = 'L' THEN height
		END),2) AS left_height
FROM people;

--14.Get the average of each team's maximum player salary since 2010. Hint: WHERE will go outside your CTE.

-- --ASSUMED THEY MEANT AVERAGE ACROSS TEAMS
--  WITH max_sal AS (
--  SELECT MAX(salary) AS maximum
--  FROM salaries
--  WHERE yearid>2009
--  GROUP BY teamid)

--  SELECT ROUND(AVG(maximum), 2), teamid
--  FROM salaries AS s
--  RIGHT JOIN max_sal AS mxs
--  ON s.teamid=s.teamid
--  WHERE yearid>2009
--  ORDER BY teamid;

WITH max_sal_team_year AS
(
SELECT teamid, yearid, MAX(salary) AS max_sal
FROM salaries
GROUP BY teamid, yearid
)
SELECT teamid, ROUND(AVG(max_sal),2) AS avg_max
FROM max_sal_team_year
WHERE yearid > 2009
GROUP BY teamid
ORDER BY teamid;