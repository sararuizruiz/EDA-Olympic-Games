# Olympic Games Data Exploration 

This repository contains an end-to-end data project used to explore, analyse and visualise Olympic Games data.
The aim of the project is to help interested readers easily understand and navigate through the Olympic Games' history,
as well as answer some related questions.

**Author**: Sara Ruiz Ruiz <br />
**Email**: sararr090@gmail.com <br />
**LinkedIn**: www.linkedin.com/in/sara-ruiz-ruiz  <br />

**Tech stack** 🛠️ 
* SQL - [MySQL](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwijr82z0OiBAxViU6QEHQmBAPwQFnoECAYQAQ&url=https%3A%2F%2Fwww.mysql.com%2F&usg=AOvVaw20c6IrMAtNC1A9NZPsDpWW&opi=89978449), [MySQL Workbench](https://www.mysql.com/products/workbench/)
* Python (via [Jupyter Notebook](https://jupyter.org)) - [Pandas](https://pandas.pydata.org), [Seaborn](https://seaborn.pydata.org), [Matplotlib](https://matplotlib.org)

## Introducing the originial datasets
The project scrapes data from different sources, in particular, we need two different datasets to have the full information for the analysis.

**120 years of Olympic history: athletes and results**.
The dataset and its info can be accessed [here](https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results). <br />
**NOC - Region**.
The dataset and its info can be accessed [here](https://github.com/sararuizruiz/Olympic_Games_Data_Exploration/blob/main/csv_raw/noc_regions.csv).

The SQL script used to load the data from local csv files into my MySQL database can be found [here](https://github.com/sararuizruiz/Olympic_Games_Data_Exploration/blob/main/sql_scripts/upload_raw_data.sql).

## Data Modeling and Data Wrangling: From Raw to Usable 

The data we possess is not ideal for data analysis and performance. That is why we take some time manually designing an Entity Relationship Diagram (ERD)
that makes sense for our use case and helps reducing the number of repeated entries.

#### The initial idea
Separate the AthleteEvents table into:
* An Athletes Table: AthleteId (PRIMARY KEY), Name, Sex, Weight(?), Height, BirthYear(?)
* A NOCs Table: NOC (PRIMARY KEY), Region, Notes
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
   <details>
       <summary>Solution</summary>
       Leaving this info in the events table as age of the athlete when the event happened.
   </details>
2. I cannot include a Teams column in the Athletes table because some athletes have competed for different Teams throughout the years. <br />
   <details>
       <summary>Solution</summary>
       Leaving this info in the events table as team of the athlete for the specific event.
   </details>
3. I cannot create a Teams Table with unique team values with their corresponding NOCs 
   because some teams have more than one NOC associated to them. <br />
      <details>
       <summary>Solution</summary>
       Model around NOCs instead of Teams.
   </details>
4. I found while populating my Games Table that the 1956 Summer events were hold
   on Melbourne, Australia with the exception of the equestrian events, which were held in Stockholm, Sweden.
   This gave me a problem because now the primary key '1956 Summer' has two cities associated with it. <br />
        <details>
       <summary>Solution</summary>
       Creating a new Games id for equestrian events ocurred in 1956 called '1956 Summer Equestrianism'.
   </details>
5. There were a lot of missing data, specially in the height and weight fields of many athletes.
   <details>
       <summary>Solution</summary>
       Excluding these records when (and only when) these fields were crutial for specific analysis (for example on the calculation of the New Metric of Body Mass Index (BMI) of the athletes and its relationship with the sport they were competing at.
   </details>

The SQL cript used to wrangle the data into these five different tables with their corresponding relations between each other can be found [here](https://github.com/sararuizruiz/Olympic_Games_Data_Exploration/blob/main/sql_scripts/data_wrangling.sql).

## ERD Creation

Once our data is modelled adequately, with the help of [MySQL Workbench](https://www.mysql.com/products/workbench/), an automatic Entity Relationship Diagram is created as follows. <br />

![erd](https://github.com/sararuizruiz/Olympic_Games_Data_Exploration/assets/75987848/eb73a6d4-5d28-4bf8-8b69-be63f27f6627)
<br />
The data now follows a Star design where 'Events' is the 'Fact Table' which contains the core metrics.


## The Exploration

### Age Exploration
<details>
    <summary> How old are the oldest and youngest medalists? </summary>
    73 and 10 years old.
</details>

<details>
    <summary> Is there an age where sports performance is at its best?</summary>
    The age distribution of the medalists can be seen in this graph, where clearly one can observe that most medalists are in between 22 and 26 years old, and we conclude this is the age where sports perfomance is at its best. In particular, the mean of the medalists is 25'9 years old with a standard deviation of 5'9.
    <br/>
    <p align="center"> <img width="600" alt="Screenshot 2023-10-18 at 17 12 11" src="https://github.com/sararuizruiz/EDA_Olympic_Games/assets/75987848/0bce4bd7-dd74-4bd3-995f-d19f37179d76"> <p/>
</details>

<details>
    <summary> Does this best age for sports performance vary depending on the sport? </summary>
    To conclude this question, I generated a graph with the corresponding Age mean of medalists according to the sport. One can see that different sports have different best age performance. For example, if we look at the Roque or Art Competition events, the age mean of medalists is clearly above the rest, due to their lesser physically demanding characteristic. However, sports like Swimming or Rhythmic Gymnastics usually have the youngest medalists.
    <br/>
    <p align="center">
    <img width="980" alt="Screenshot 2023-10-20 at 10 15 01" src="https://github.com/sararuizruiz/EDA_Olympic_Games/assets/75987848/92146a33-4600-48eb-99de-bedefa9a7047"> <p/>
</details>

### Country Exploration
<details>
    <summary> What sports is each region/country best at? </summary>
    Here, we can observe the top 10 countries that have won most points (Gold medals are worth 3 points, Silver are worth 2, and Bronze 1) in their top sport.    
<br/>
    
   | Region	| Sport |	Points |
   | :--- | :---: | ---: |
   |USA |	Swimming |	2630 |
   | Germany |	Rowing	| 1107 |
   | Russia |	Gymnastics |	893 |
   | Canada	| Ice Hockey |	881 |
   | Australia |	Swimming |	823 |
   | Italy	| Fencing	| 797 |
   | France |	Fencing |	660 |
   | UK	 | Athletics	| 627 |
   | Netherlands |	Hockey	 | 502 |
   | Hungary | 	Fencing | 	502 |

</details>

<details>
    <summary>Is there a correlation between a country's best sport and its culture/weather/history? </summary>
    Clearly there is. <br/> An example: Countries whose best sport is ice/ski-related (Ice Hockey, Cross-country Skiing, Apline Skiing) are Canada, Sweden, Norway, Czech Republic, Austria and Liechtenstein, due to the great weather conditions for its practice. It would have been a surprise if Spain's best sport were 'Alpine Skiing' given I am Spanish and have almost never seen snow. <br/>
A sencond example: The most popular sport across Africa is well known to be Football, and indeed countries like Nigeria, Cameroon and Ghana's most ranked sport is Football.
</details>

### New Metric: BMI (Body Mass Index) Exploration
<details>
    <summary> What is the average BMI of medalists across different sports?  </summary>
    These bar chart shows exactly that. One can observe that Weightlifting is the sport with highest average bmi within its medalists. 
    This makes sense since they need a highest muscle mass to perform best at their sport. Not the same case for Gymnastics, for example.<br />
    ![bmi](https://github.com/sararuizruiz/EDA_Olympic_Games/assets/75987848/f94a640b-220b-4056-b007-a472a6d591af)


</details>








