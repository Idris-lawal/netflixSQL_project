
/*
-- 15 Business Problems & Solutions

			1. Count the number of Movies vs TV Shows
			2. Find the most common rating for movies and TV shows
			3. List all movies released in a specific year (e.g., 2020)
			4. Find the top 5 countries with the most content on Netflix
			5. Identify the longest movie
			6. Find content added in the last 5 years
			7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
			8. List all TV shows with more than 5 seasons
			9. Count the number of content items in each genre
			10.Find each year and the average numbers of content release in India on netflix. 
			return top 5 year with highest avg content release!
			11. List all movies that are documentaries
			12. Find all content without a director
			13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
			14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
			15.
			Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
			the description field. Label content containing these keywords as 'Bad' and all other 
			content as 'Good'. Count how many items fall into each category.
*/

SELECT * FROM netflix


-- 1. Count the number of Movies vs TV Shows

		SELECT TYPE, Count(*) as CNT FROM netflix
		Group by Type

--2. Find the most common rating for movies and TV shows

	SELECT R.type,r.rating 
		FROM 
		(
		SELECT  type,rating, Count(*) as CNT,
		RANK() over(PARTITION BY type order by Count(*) desc ) as rank
		FROM netflix
		Group by type,rating
		--Order by type,CNT desc 
		) as R
		Where R.rank = 1


--3. List all movies released in a specific year (e.g., 2020)
		
		SELECT * FROM 
		Netflix
		Where Type = 'Movie' and release_year = '1998'

--4. Find the top 5 countries with the most content on Netflix

		SELECT top 5 
			Trim(s.value) as country, 
			COUNT(Show_id) as contents
		FROM netflix a CROSS APPLY string_split(a.country,',') as s
		Group by Trim(s.value)
		Order by contents desc;

--5. Identify the longest movie


		SELECT  title
		FROM netflix
		Where Type = 'Movie' AND
			  duration = (Select Max(duration) From netflix);


--6. Find content added in the last 5 years

	   SELECT *
	   FROM netflix
	   WHERE TRY_CONVERT(date,date_added,107) >= DATEADD(YEAR,-5,GETDATE());

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
	   
	   SELECT * 
	   FROM netflix a cross apply string_split(a.director,',') s 
	   Where s.value = 'Rajiv Chilaka'


--8. List all TV shows with more than 5 seasons

		SELECT * 
		FROM netflix
		WHERE type = 'TV Show'
		and Cast(substring(duration,1,1) as int) > 5

		
--9. Count the number of content items in each genre

		SELECT Trim(s.value) as genre, Count(show_id) as cnt_content 
		FROM netflix a cross Apply string_split(a.listed_in, ',') s
		Group by s.value

/*
10.Find each year and the average numbers of content release in India on netflix. 
			return top 5 year with highest avg content release!
*/

	Select top 5 s.value as country , release_year, count(show_id) as total_Release,
	Round((Cast(Count(*) as float)/Cast((Select Count(show_id) from netflix where s.value= 'India') as float)) *100,2) as Avg_Release
	From	netflix a cross Apply string_split(a.country,',') s
	Where S.value = 'India' COLLATE SQL_Latin1_General_CP1_CI_AS
	Group by release_year,s.value
	Order by Avg_Release Desc

-- 11. List all movies that are documentaries

	SELECT *
	FROM netflix a CROSS APPLY string_split(a.listed_in,',') as s
	Where S.value = 'Documentaries' COLLATE SQL_Latin1_General_CP1_CI_AS


-- 12. Find all content without a director

	SELECT * 
	FROM netflix
	Where director is null

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

	SELECT * 
	From netflix
	Where Casts like '%Salman Khan%' COLLATE SQL_Latin1_General_CP1_CI_AS
	AND Cast(release_year as int) > Year(GETDATE()) - 10
	And Type = 'Movie'

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

	SELECT  top 10 Trim(s.value) as actors , Count(show_id) as CNT
	FROM netflix a Cross Apply string_split(a.casts,',') s
	Where Type = 'Movie' and country like 'India' COLLATE SQL_Latin1_General_CP1_CI_AS
	Group by  Trim(s.value)
	Order by CNT desc

/*
	15.  Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
			the description field. Label content containing these keywords as 'Bad' and all other 
			content as 'Good'. Count how many items fall into each category.
*/

	SELECT a.label, count(show_id) as CNT 
	FROM 
	(
			SELECT * ,
					Case when description like '%kill%' COLLATE SQL_Latin1_General_CP1_CI_AS OR description like '%violence%' COLLATE SQL_Latin1_General_CP1_CI_AS  then 'Bad Content'
						Else 'Good Content' End as label 
			FROM Netflix
	) as A
	Group by A.label

