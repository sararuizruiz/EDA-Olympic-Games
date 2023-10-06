/*
	Olympic Games End-To-End Data Project
	Author: Sara Ruiz Ruiz
	Email: sararr090@gmail.com
	
	File Name: data_wrangling.sql
	Description:  This script will do an initial exploratory analysis of the data,
    as to understand the data. The results will help us model the Entity Relationship Diagram (ERD) 
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

- An Athletes Table: AthleteId (PRIMARY KEY), Name, Sex, Weight, Height
- A NOCs Table: NOC (PRIMARY KEY), Region, Notes
- A Games Table: Games (PRIMARY KEY), Year, Season, City
- A Categories Table: Category (PRIMARY KEY), Sport
- An Events Table: EventId (PRIMARY KEY), AthleteId, Age, Team, NOC, Games, Category, Medal

Things to consider:
- Create an Event Id
- Check if Sex, Height, Weight and Team of the Athletes change over the years 
    (this could give us a problem if we want to store it just once for each athlete)
*/

/* PROBLEMS ENCOUNTERED AND HOW THEY WERE SOLVED:
1. I cannot include a BirthYear column in the Athletes table because even though I know their 
   age at events, the exact month is unknown and therefore the year. 
   SOL: Leaving this info in the events table as age.
2. I cannot create a Teams Table with unique team values with their corresponding NOCs 
   because some teams have more than one NOC associated to them. 
   SOL: Leave it as NOC table instead of Teams and visualise around NOCs.
3. DATA EXCEPTIONS (FINDINGS): I found while populating my Games Table that the 1956 Summer events were hold
   on Melbourne, Australia with the exception of the equestrian events, which were held in Stockholm, Sweden 
   (due to the Australian quarantine regulations).
   This gave me a problem because now the primary key '1956 Summer' has two cities associated with it.
   SOL: I decided to save just Melbourne as a city since it was the official city host of those games.

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
    Region VARCHAR(255) NOT NULL,
    Notes VARCHAR(255) NULL
);

-- Insert Data into Teams Table
INSERT INTO NOC (NOC, Region, Notes)
SELECT NOC, Region, Notes
FROM RawSportsStats.NocRegions;

-- Create Games Table
CREATE TABLE IF NOT EXISTS Games (
    Games VARCHAR(50) PRIMARY KEY,
    Year INT NOT NULL,
    Season VARCHAR(20) NOT NULL,
    City VARCHAR(50) NOT NULL
);

-- Insert Data into Games Table (considering the 1956 summer games city as Melbourne)
UPDATE RawSportsStats.AthleteEvents
SET City = 'Melbourne'
WHERE Games = '1956 Summer';

INSERT INTO Games (Games, Year, Season, City)
SELECT Games, Year, Season, City
FROM SportsStats.AthleteEvents
GROUP BY Games, Year, Season, City;



----- CONTINUE FROM HERE. Faltan las tables: Categories, Events.

-- Create Events Table
CREATE TABLE IF NOT EXISTS Events (
    EventId INT AUTO_INCREMENT PRIMARY KEY,
    AthleteId VARCHAR(50) NOT NULL,
    Team VARCHAR(50) NOT NULL,
    Games VARCHAR(50) NOT NULL,
    Category VARCHAR(255) NOT NULL,
    Medal VARCHAR(10) NULL,
    FOREIGN KEY (AthleteId) REFERENCES Athletes(AthleteId),
    FOREIGN KEY (Team) REFERENCES Teams(Team),
    FOREIGN KEY (Games) REFERENCES Games(Games),
    FOREIGN KEY (Category) REFERENCES Categories(Category),
);

-- Insert Data into Events Table
INSERT INTO ProcessedSportsStats.Events (EventId, AthleteId, Team, Games, Category, Medal)
SELECT EventId, ID, Team, Games, Event, Medal FROM RawSportsStats.AthleteEvents;