/*-------------------------*Use of Temporary Table-----------------------------------------
Instead of coming up with a complex code, the problem statement can be broken down
into simpler steps through temporary tables-----------------------------------------------*/


/*---------------------------Question----------------------------------------------------------
----Find the movies whose rankscore is greater than the average rank of its genre------*/


-- Extract the genre and average rankscore of each genre into a temp table
SELECT 
MG.GENRE
,AVG (CASE WHEN MV.RANKSCORE >0 THEN MV.RANKSCORE ELSE 0 END) AS "RANKSCORE"
INTO #T1
FROM MOVIES MV INNER JOIN MOVIES_GENRES MG
ON MV.ID = MG.MOVIE_ID
GROUP BY MG.GENRE
ORDER BY 2 DESC

--Club the above with a new column - movie id
SELECT MG.MOVIE_ID, MG.GENRE,T.RANKSCORE
INTO #T2
FROM #T1 T INNER JOIN MOVIES_GENRES MG
ON T.GENRE = MG.GENRE

--Join the above temp table with movie column to get name of the movie
SELECT MV.NAME, MV.YEAR, MV.RANKSCORE, T2.RANKSCORE
FROM MOVIES MV INNER JOIN #T2 T2
ON MV.ID = T2.MOVIE_ID
WHERE  MV.RANKSCORE >=T2.RANKSCORE 
ORDER BY 2 DESC


DROP TABLE #T2, #T1


