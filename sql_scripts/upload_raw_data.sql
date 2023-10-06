/*
	Olympic Games End-To-End Data Project
	Author: Sara Ruiz Ruiz
	Email: sararr090@gmail.com
	
	File Name: upload_raw_data.sql
	Description:  This script will import data from the CSV files and create the 
	schema and tables for this project in MySQL.
*/

-- Create and Use Database
CREATE DATABASE IF NOT EXISTS RawSportsStats;
USE RawSportsStats;

-- Create Table AthleteEvents describing schema
CREATE TABLE IF NOT EXISTS AthleteEvents (
     ID INTEGER(255),
     Name VARCHAR(255),
     Sex VARCHAR(255),
     Age INTEGER(255),
     Height INTEGER(255),
     Weight INTEGER(255),
     Team VARCHAR(255),
     NOC VARCHAR(255),
     Games VARCHAR(255),
     Year INTEGER(255),
     Season VARCHAR(255),
     City VARCHAR(255),
     Sport VARCHAR(255),
     Event VARCHAR(255),
     Medal VARCHAR(255)
);

-- Upload Raw Data into AthleteEvents Table (Transforming 'NA' into NULL values)
LOAD DATA local INFILE '.../SportsStats/csv_raw/athlete_events.csv' INTO TABLE AthleteEvents
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS
    (ID,Name,Sex,@a,@h,@w,Team,NOC,Games,Year,Season,City,Sport,Event,@m)
    SET Weight = NULLIF(@w, 'NA'), 
    Height = NULLIF(@h, 'NA'), 
    Age = NULLIF(@a, 'NA'), 
    Medal = NULLIF(@m, 'NA');

-- Create Table NocRegions describing schema
CREATE TABLE IF NOT EXISTS NocRegions (
     NOC VARCHAR(255),
     Region VARCHAR(255),
     Notes  VARCHAR(255)
);

-- Upload Raw Data into NocRegions Table (Transforming '' into NULL values)
LOAD DATA local INFILE '.../SportsStats/csv_raw/noc_regions.csv' INTO TABLE NocRegions
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r'
    IGNORE 1 ROWS
    (NOC, Region,@n)
    SET Notes = NULLIF(@n,'');










