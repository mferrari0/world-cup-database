#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate existing tables
$PSQL "TRUNCATE TABLE teams, games CASCADE;"

# Create teams table
$PSQL "CREATE TABLE IF NOT EXISTS teams (
  team_id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);"

# Create games table
$PSQL "CREATE TABLE IF NOT EXISTS games (
  game_id SERIAL PRIMARY KEY,
  year INT NOT NULL,
  round VARCHAR(255) NOT NULL,
  winner_id INT NOT NULL REFERENCES teams(team_id),
  opponent_id INT NOT NULL REFERENCES teams(team_id),
  winner_goals INT NOT NULL,
  opponent_goals INT NOT NULL
);"

# Read the CSV file and insert data into the database
while IFS="," read -r year round winner opponent winner_goals opponent_goals
do
  if [[ $year != "year" ]]
  then
    # Get or create winner team ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    if [[ -z $WINNER_ID ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$winner')" > /dev/null
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    fi

    # Get or create opponent team ID
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    if [[ -z $OPPONENT_ID ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$opponent')" > /dev/null
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    fi

    # Insert game data
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)" > /dev/null
  fi
done < games.csv



