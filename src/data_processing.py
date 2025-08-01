"""
Data Processing Module

This module contains functions for loading, cleaning, and preprocessing NBA player data.
"""

from typing import List, Optional, Tuple

import numpy as np
import pandas as pd


def load_nba_data(
    player_data_path: str, seasons_stats_path: str, all_star_path: str
) -> Tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """
    Load the three main NBA datasets.

    Args:
        player_data_path: Path to player demographic data CSV
        seasons_stats_path: Path to season statistics CSV
        all_star_path: Path to All-Star selections CSV

    Returns:
        Tuple of (player_data, seasons_stats, all_star) DataFrames
    """
    player_data = pd.read_csv(player_data_path)
    seasons_stats = pd.read_csv(seasons_stats_path)
    all_star = pd.read_csv(all_star_path)

    return player_data, seasons_stats, all_star


def merge_datasets(
    player_data: pd.DataFrame, seasons_stats: pd.DataFrame, all_star: pd.DataFrame
) -> pd.DataFrame:
    """
    Merge the three datasets and create the target variable.

    Args:
        player_data: Player demographic data
        seasons_stats: Season statistics data
        all_star: All-Star selections data

    Returns:
        Merged DataFrame with is_all_star target variable
    """
    # Rename columns for consistency
    seasons_stats = seasons_stats.rename(columns={"Player": "PlayerName"})
    player_data = player_data.rename(columns={"name": "PlayerName"})
    all_star = all_star.rename(columns={"Player": "PlayerName"})

    # Merge seasons_stats with players
    merged = pd.merge(seasons_stats, player_data, on="PlayerName", how="left")

    # Filter seasons from 2000 to 2016
    merged = merged[(merged["Year"] >= 2000) & (merged["Year"] <= 2016)]

    # Standardize player name formatting
    merged["PlayerName"] = merged["PlayerName"].str.strip()
    all_star["PlayerName"] = all_star["PlayerName"].str.strip()

    # Add 'is_all_star' column
    all_star["is_all_star"] = 1
    labeled = pd.merge(
        merged,
        all_star[["PlayerName", "Year", "is_all_star"]],
        on=["PlayerName", "Year"],
        how="left",
    )

    # Fill NaNs in is_all_star with 0
    labeled["is_all_star"] = labeled["is_all_star"].fillna(0).astype(int)

    return labeled


def clean_missing_values(df: pd.DataFrame) -> pd.DataFrame:
    """
    Clean missing values in the dataset.

    Args:
        df: Input DataFrame

    Returns:
        DataFrame with missing values handled
    """
    df = df.copy()

    # Remove unnecessary columns
    cols_to_drop = ["Unnamed: 0", "blanl", "blank2"]
    df = df.drop(columns=[col for col in cols_to_drop if col in df.columns])

    # Convert numeric columns
    cols_to_float = [
        "PER",
        "TS%",
        "3PAr",
        "FTr",
        "ORB%",
        "DRB%",
        "TRB%",
        "AST%",
        "STL%",
        "BLK%",
        "TOV%",
        "USG%",
        "WS/48",
        "eFG%",
        "FG",
        "FGA",
        "3P",
        "3PA",
        "2P",
        "2PA",
        "FT",
        "FTA",
    ]

    for col in cols_to_float:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")

    # Calculate shooting percentages only if required columns exist
    if "3P%" in df.columns and "3P" in df.columns and "3PA" in df.columns:
        df["3P%"] = df["3P%"].fillna(df["3P"] / df["3PA"])
    elif "3P" in df.columns and "3PA" in df.columns:
        df["3P%"] = df["3P"] / df["3PA"]

    if "2P%" in df.columns and "2P" in df.columns and "2PA" in df.columns:
        df["2P%"] = df["2P%"].fillna(df["2P"] / df["2PA"])
    elif "2P" in df.columns and "2PA" in df.columns:
        df["2P%"] = df["2P"] / df["2PA"]

    if "FG%" in df.columns and "FG" in df.columns and "FGA" in df.columns:
        df["FG%"] = df["FG%"].fillna(df["FG"] / df["FGA"])
    elif "FG" in df.columns and "FGA" in df.columns:
        df["FG%"] = df["FG"] / df["FGA"]

    if "FT%" in df.columns and "FT" in df.columns and "FTA" in df.columns:
        df["FT%"] = df["FT%"].fillna(df["FT"] / df["FTA"])
    elif "FT" in df.columns and "FTA" in df.columns:
        df["FT%"] = df["FT"] / df["FTA"]

    if (
        "eFG%" in df.columns
        and "FG" in df.columns
        and "3P" in df.columns
        and "FGA" in df.columns
    ):
        df["eFG%"] = df["eFG%"].fillna((df["FG"] + 0.5 * df["3P"]) / df["FGA"])
    elif "FG" in df.columns and "3P" in df.columns and "FGA" in df.columns:
        df["eFG%"] = (df["FG"] + 0.5 * df["3P"]) / df["FGA"]

    # Fill remaining NaNs in percentages with 0.0
    percentage_cols = ["3P%", "2P%", "FG%", "FT%", "eFG%"]
    existing_percentage_cols = [col for col in percentage_cols if col in df.columns]
    if existing_percentage_cols:
        df[existing_percentage_cols] = df[existing_percentage_cols].fillna(0.0)

    # Fill advanced stats with 0.0
    advanced_stats = [
        "PER",
        "TS%",
        "3PAr",
        "FTr",
        "ORB%",
        "DRB%",
        "TRB%",
        "AST%",
        "STL%",
        "BLK%",
        "TOV%",
        "USG%",
        "WS/48",
    ]
    for col in advanced_stats:
        if col in df.columns:
            df[col] = df[col].fillna(0.0)

    # Fill categorical columns
    if "college" in df.columns:
        df["college"] = df["college"].fillna("Unknown")
    if "position" in df.columns:
        df["position"] = df["position"].fillna("Unknown")

    return df


def process_height_weight(df: pd.DataFrame) -> pd.DataFrame:
    """
    Process height and weight data.

    Args:
        df: Input DataFrame

    Returns:
        DataFrame with processed height and weight
    """
    df = df.copy()

    def height_to_cm(height_str):
        """Convert height string (e.g., '6-10') to centimeters."""
        try:
            feet, inches = map(int, height_str.split("-"))
            return round(feet * 30.48 + inches * 2.54, 1)
        except:
            return None

    # Convert height to cm
    if "height" in df.columns:
        df["height_cm"] = df["height"].apply(height_to_cm)
        df["height_cm"] = df["height_cm"].fillna(df["height_cm"].median())

    # Fill weight with median
    if "weight" in df.columns:
        df["weight"] = df["weight"].fillna(df["weight"].median())

    return df


def process_age_data(df: pd.DataFrame) -> pd.DataFrame:
    """
    Process birth date and age data.

    Args:
        df: Input DataFrame

    Returns:
        DataFrame with processed age data
    """
    df = df.copy()

    if "birth_date" in df.columns:
        # Convert birth_date to datetime
        df["birth_date"] = pd.to_datetime(df["birth_date"], errors="coerce")

        # Extract birth year and calculate age
        df["birth_year"] = df["birth_date"].dt.year
        df["age_calc"] = df["Year"] - df["birth_year"]

        # Remove unrealistic ages (NBA range: 18-44)
        df = df[
            (df["age_calc"].isna()) | ((df["age_calc"] >= 18) & (df["age_calc"] <= 44))
        ]

        # Fill missing values with median
        df["birth_year"] = df["birth_year"].fillna(df["birth_year"].median())
        df["age_calc"] = df["age_calc"].fillna(df["age_calc"].median())

    # Fill career timeline data
    if "year_start" in df.columns:
        df["year_start"] = df["year_start"].fillna(df["Year"])
    if "year_end" in df.columns:
        df["year_end"] = df["year_end"].fillna(df["Year"])

    return df


def preprocess_data(
    player_data_path: str, seasons_stats_path: str, all_star_path: str
) -> pd.DataFrame:
    """
    Complete data preprocessing pipeline.

    Args:
        player_data_path: Path to player demographic data CSV
        seasons_stats_path: Path to season statistics CSV
        all_star_path: Path to All-Star selections CSV

    Returns:
        Fully preprocessed DataFrame ready for modeling
    """
    # Load data
    player_data, seasons_stats, all_star = load_nba_data(
        player_data_path, seasons_stats_path, all_star_path
    )

    # Merge datasets
    df = merge_datasets(player_data, seasons_stats, all_star)

    # Clean missing values
    df = clean_missing_values(df)

    # Process height and weight
    df = process_height_weight(df)

    # Process age data
    df = process_age_data(df)

    return df
