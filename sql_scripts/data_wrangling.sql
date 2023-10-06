/*
	Olympic Games End-To-End Data Project
	Author: Sara Ruiz Ruiz
	Email: sararr090@gmail.com
	
	File Name: data_wrangling.sql
	Description:  This script will do an initial exploratory analysis of the data,
    as to understand it. The results will help us model the Entity Relationship Diagram (ERD) 
    we will afterwards build with cleaned and wrangled new data tables.
*/

-- Show what tables look like (inside RawSportsStats Database)
USE RawSportsStats;

SELECT *
FROM AthleteEvents
LIMIT 15;

SELECT *
FROM NocRegions
LIMIT 15;

/* To model the ERD, I though a good idea would be to separate The AthleteEvents table into:

- An Athletes Table: AthleteId (PRIMARY KEY), Name, Sex, Weight(?), Height, BirthYear(?)
- A NOCs Table: NOC (PRIMARY KEY), Region, Notes
- A Games Table: Games (PRIMARY KEY), Year, Season, City
- A Categories Table: Category (PRIMARY KEY), Sport
- An Events Table: EventId (PRIMARY KEY), AthleteId, Team, NOC, Games, Category, Medal

Things to consider:
- Create an Event Id
- Check if Sex, Height, Weight and Team of the Athletes change over the years 
    (this could give us a problem if we want to store it just once for each athlete).
    Also, consider whether we can calculate BirthYear with the data we own.

PROBLEMS ENCOUNTERED AND HOW THEY WERE SOLVED:
1. I cannot include a BirthYear column in the Athletes table because even though I know their 
   age at events, the exact day/month is unknown and therefore the year of their birth. 
   SOLUTION: Leaving this info in the events table as age of the athlete when the event happened.
2. I cannot create a Teams Table with unique team values with their corresponding NOCs 
   because some teams have more than one NOC associated to them. 
   SOLUTION: Model around NOCs instead of Teams.
3. DATA EXCEPTIONS (FINDINGS): I found while populating my Games Table that the 1956 Summer events were hold
   on Melbourne, Australia with the exception of the equestrian events, which were held in Stockholm, Sweden 
   (due to the Australian quarantine regulations).
   This gave me a problem because now the primary key '1956 Summer' has two cities associated with it.
   SOLUTION: Creating a new Games id for equestrian events ocurred in 1956 called '1956 Summer Equestrianism'.

*/

-- Create an EventId
ALTER TABLE AthleteEvents ADD EventId INT NOT NULL AUTO_INCREMENT KEY;

-- Check Sex, Height and Weight of the Athletes don't change over the years. What about Team?
SELECT COUNT(DISTINCT ID)
FROM AthleteEvents;

SELECT COUNT(*)
FROM (
    SELECT ID, Sex, Height, Weight 
    FROM AthleteEvents 
    GROUP BY ID, Sex, Height, Weight
    ) AS TotalDiffQualities;
/* Both Queries result in 135571, which means these are all the athletes appearing in the data, and everytime
   they appear, they do so with same Sex, Height and Weight (this is a bit unreal since people tend to change
   over time, mostly the weight characteristic). However, if we also add the Team distinction, more cases
   appear, meaning some athletes have played for diff teams, and that is why it cannot form part of the athletes
   table but of the events one. */

-- Now, we are ready to create and model the ERD

-- LET'S DIVE INTO THE CREATION OF THE CLEANED AND READY-TO-USE DATA FOLLOWING OUR JUST CREATED ERD

CREATE DATABASE IF NOT EXISTS ProcessedSportsStats;
USE ProcessedSportsStats;

-- Create Athletes Table
CREATE TABLE IF NOT EXISTS Athletes (
    AthleteId INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Sex VARCHAR(1) NOT NULL,
    Height INT NULL,
    Weight INT NULL
);

-- Insert Data into Athletes Table
INSERT INTO Athletes (AthleteId, Name, Sex, Height, Weight)
SELECT ID, 
       Name, 
       Sex, 
       Height, 
       Weight
FROM RawSportsStats.AthleteEvents
GROUP BY ID, Name, Sex, Height, Weight;

-- Create NOCs Table
CREATE TABLE IF NOT EXISTS NOC (
    NOC VARCHAR(3) PRIMARY KEY,
    Region VARCHAR(255) NULL, -- there are four NOCs with NULL region: SGP, ROT, UNK, TUV
    Notes VARCHAR(255) NULL
);

-- Insert Data into Teams Table (For NOCs appearing in our data)
INSERT INTO NOC (NOC, Region, Notes)
SELECT a.NOC, b.Region, b.Notes
FROM SportsStats.AthleteEvents a
LEFT JOIN SportsStats.NocRegions b ON a.NOC = b.NOC
GROUP BY a.NOC, b.Region, b.Notes;

-- Create Games Table
CREATE TABLE IF NOT EXISTS Games (
    Games VARCHAR(50) PRIMARY KEY,
    Year INT NOT NULL,
    Season VARCHAR(20) NOT NULL,
    City VARCHAR(50) NOT NULL
);

-- Insert Data into Games Table (dealing with the 1956 summer games city exception)
INSERT INTO Games (Games, Year, Season, City)
SELECT '1956 Summer Equestrianism' AS Games, Year, Season, City
FROM RawSportsStats.AthleteEvents
WHERE (Games = '1956 Summer' AND Sport = 'Equestrianism')
GROUP BY Games, Year, Season, City;

INSERT INTO Games (Games, Year, Season, City)
SELECT Games, Year, Season, City
FROM RawSportsStats.AthleteEvents
WHERE NOT (Games = '1956 Summer' AND Sport = 'Equestrianism')
GROUP BY Games, Year, Season, City;

-- Create Categories Table
CREATE TABLE IF NOT EXISTS Categories (
    Category VARCHAR(255) PRIMARY KEY,
    Sport VARCHAR(255) NOT NULL
);

-- Insert Data into Categories Table
INSERT INTO Categories (Category, Sport)
SELECT Event, Sport
FROM RawSportsStats.AthleteEvents
GROUP BY Event, Sport;

-- Create Events Table
CREATE TABLE IF NOT EXISTS Events (
    EventId INT AUTO_INCREMENT PRIMARY KEY,
    AthleteId INT NOT NULL,
    Age INT NULL,
    Team VARCHAR(50) NOT NULL,
    NOC VARCHAR(3) NOT NULL,
    Games VARCHAR(50) NOT NULL,
    Category VARCHAR(255) NOT NULL,
    Medal VARCHAR(10) NULL,
    FOREIGN KEY (AthleteId) REFERENCES Athletes(AthleteId),
    FOREIGN KEY (NOC) REFERENCES NOC(NOC),
    FOREIGN KEY (Games) REFERENCES Games(Games),
    FOREIGN KEY (Category) REFERENCES Categories(Category)
);

-- Insert Data into Events Table
INSERT INTO ProcessedSportsStats.Events (EventId, AthleteId, Age, Team, NOC, Games, Category, Medal)
SELECT EventId, ID, Age, Team, NOC, '1956 Summer Equestrianism', Event, Medal 
FROM SportsStats.AthleteEvents
WHERE (Games = '1956 Summer' AND Sport = 'Equestrianism');

INSERT INTO ProcessedSportsStats.Events (EventId, AthleteId, Age, Team, NOC, Games, Category, Medal)
SELECT EventId, ID, Age, Team, NOC, Games, Event, Medal 
FROM SportsStats.AthleteEvents
WHERE NOT (Games = '1956 Summer' AND Sport = 'Equestrianism');