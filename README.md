# Olympic Games Data Exploration 

This repository contains an end-to-end data project used to explore, analyse and visualise Olympic Games data.
The aim of the project is to help interested readers easily understand and navigate through the Olympic Games' history,
as well as answer some related questions.

**Author**: Sara Ruiz Ruiz <br />
**Email**: sararr090@gmail.com <br />
**LinkedIn**: www.linkedin.com/in/sara-ruiz-ruiz  <br />

**Tech stack** 🛠️ 
* SQL - [MySQL](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwijr82z0OiBAxViU6QEHQmBAPwQFnoECAYQAQ&url=https%3A%2F%2Fwww.mysql.com%2F&usg=AOvVaw20c6IrMAtNC1A9NZPsDpWW&opi=89978449), [MySQL Workbench](https://www.mysql.com/products/workbench/)

## Introducing the originial datasets
The project scrapes data from different sources, in particular, we need two different datasets to have the full information for the analysis.

**120 years of Olympic history: athletes and results**.
The dataset and its info can be accessed [here](https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results). <br />
**Country Mapping - ISO, Continent, Region**.
The dataset and its info can be accessed [here](https://www.kaggle.com/datasets/andradaolteanu/country-mapping-iso-continent-region/).

The SQL script used to load the data from local csv files into my MySQL database can be found [here](https://github.com/sararuizruiz/Olympic_Games_Data_Exploration/blob/main/sql_scripts/upload_raw_data.sql).

## Data Wrangling: From Raw to Usable 

The data we possess is not ideal for data analysis and performance. That is why we take some time manually designing an Entity Relationship Diagram (ERD)
that makes sense for our use case and helps reducing the number of repeated entries.

#### The initial idea
Separate the AthleteEvents table into:
* An Athletes Table: AthleteId (PRIMARY KEY), Name, Sex, Weight(?), Height, BirthYear(?)
* A NOCs Table: NOC (PRIMARY KEY), CountryName, PrincipalContinentName
* A Games Table: Games (PRIMARY KEY), Year, Season, City
* A Categories Table: Category (PRIMARY KEY), Sport
* An Events Table: EventId (PRIMARY KEY), AthleteId, Team, NOC, Games, Category, Medal

#### Things to consider
* Create an Event Id
* Check if Sex, Height, Weight and Team of the Athletes change over the years 
    (this could give us a problem if we want to store it just once for each athlete).
    Also, consider whether we can calculate BirthYear with the data we own.

#### Problems Encountered and Solutions
1. I cannot include a BirthYear column in the Athletes table because even though I know their 
   age at events, the exact day/month is unknown and therefore the year of their birth. <br />
   **SOL**: Leaving this info in the events table as age of the athlete when the event happened.
2. I cannot include a Teams column in the Athletes table because some athletes have competed for different Teams throughout the years. <br />
    **SOL**: Leaving this info in the events table as team of the athlete for the specific event.
3. I cannot create a Teams Table with unique team values with their corresponding NOCs 
   because some teams have more than one NOC associated to them. <br />
   **SOL**: Model around NOCs instead of Teams.
4. I found while populating my Games Table that the 1956 Summer events were hold
   on Melbourne, Australia with the exception of the equestrian events, which were held in Stockholm, Sweden.
   This gave me a problem because now the primary key '1956 Summer' has two cities associated with it. <br />
   **SOL**: Creating a new Games id for equestrian events ocurred in 1956 called '1956 Summer Equestrianism'.
5. While populating my NOCs Table I encountered countries that
   belong to both continents Europe and Asia. <br />
   **SOL**: Decided to group them around a PrincipalContinentName.

The SQL cript used to wrangle the data into these five different tables with their corresponding relations between each other can be found [here](https://github.com/sararuizruiz/Olympic_Games_Data_Exploration/blob/main/sql_scripts/data_wrangling.sql).

## Creating the ERD

Once our data is modelled adequately, with the help of [MySQL Workbench](https://www.mysql.com/products/workbench/), an automatic Entity Relationship Diagram is created as follows. <br />

![erd](https://github.com/sararuizruiz/Olympic_Games_Data_Exploration/assets/75987848/0d6595e0-a25f-48fd-852f-930c33e891ec)


## An initial exploration

## ML with Scikit-Learn and Tensorflow

## A second exploration

## Data visualisation via Tableau
