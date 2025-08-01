"""
Feature Engineering Module

This module contains functions for creating new features and selecting optimal 
feature sets for NBA All-Star prediction.
"""

import pandas as pd
import numpy as np
from typing import List, Tuple


def create_efficiency_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Create efficiency and per-minute statistics.
    
    Args:
        df: Input DataFrame
        
    Returns:
        DataFrame with additional efficiency features
    """
    df = df.copy()
    
    # Per-minute statistics
    if 'PTS' in df.columns and 'MP' in df.columns:
        df['pts_per_minute'] = df['PTS'] / df['MP']
    if 'FGA' in df.columns and 'MP' in df.columns:
        df['fga_per_minute'] = df['FGA'] / df['MP']
    if 'FTA' in df.columns and 'MP' in df.columns:
        df['fta_per_minute'] = df['FTA'] / df['MP']
    if '3PA' in df.columns and 'MP' in df.columns:
        df['3pa_per_minute'] = df['3PA'] / df['MP']
    
    # Assist-to-turnover ratio
    if 'AST' in df.columns and 'TOV' in df.columns:
        df['ast_to_turnover_ratio'] = df.apply(
            lambda row: row['AST'] / row['TOV'] if row['TOV'] != 0 else 0, axis=1
        )
    
    return df


def create_role_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Create features that indicate player role and contribution type.
    
    Args:
        df: Input DataFrame
        
    Returns:
        DataFrame with role-based features
    """
    df = df.copy()
    
    # Win share ratios
    if 'OWS' in df.columns and 'WS' in df.columns:
        df['offensive_ws_ratio'] = df.apply(
            lambda row: row['OWS'] / row['WS'] if row['WS'] != 0 else 0, axis=1
        )
    
    if 'DWS' in df.columns and 'WS' in df.columns:
        df['defensive_ws_ratio'] = df.apply(
            lambda row: row['DWS'] / row['WS'] if row['WS'] != 0 else 0, axis=1
        )
    
    return df


def create_career_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Create career-related features.
    
    Args:
        df: Input DataFrame
        
    Returns:
        DataFrame with career features
    """
    df = df.copy()
    
    # Career length
    if 'year_end' in df.columns and 'year_start' in df.columns:
        df['years_played'] = df['year_end'] - df['year_start']
    
    return df


def select_modeling_features() -> List[str]:
    """
    Select optimal features for modeling based on correlation analysis.
    
    Returns:
        List of feature names for modeling
    """
    return [
        # Core box score stats
        'PTS', 'AST', 'TRB', 'STL', 'BLK', 'MP',
        
        # Shooting efficiency  
        'FG%', '3P%', 'FT%', 'TS%',
        
        # Advanced metrics
        'PER', 'VORP', 'WS/48',
        
        # Player profile
        'age_calc', 'height_cm', 'weight', 'years_played',
        
        # Engineered features
        'ast_to_turnover_ratio'
    ]


def get_correlation_matrix(df: pd.DataFrame, features: List[str]) -> pd.DataFrame:
    """
    Calculate correlation matrix for selected features.
    
    Args:
        df: Input DataFrame
        features: List of feature names
        
    Returns:
        Correlation matrix DataFrame
    """
    # Add target variable to features for correlation analysis
    analysis_features = features + ['is_all_star']
    
    # Filter and compute correlation
    corr_df = df[analysis_features].dropna()
    corr_matrix = corr_df.corr()
    
    return corr_matrix


def engineer_all_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Apply all feature engineering steps.
    
    Args:
        df: Input DataFrame
        
    Returns:
        DataFrame with all engineered features
    """
    df = create_efficiency_features(df)
    df = create_role_features(df)  
    df = create_career_features(df)
    
    return df


def prepare_modeling_data(
    df: pd.DataFrame, 
    features: List[str] = None
) -> Tuple[pd.DataFrame, pd.Series]:
    """
    Prepare data for modeling by selecting features and target.
    
    Args:
        df: Input DataFrame
        features: List of feature names (uses default if None)
        
    Returns:
        Tuple of (X, y) for modeling
    """
    if features is None:
        features = select_modeling_features()
    
    # Ensure all features exist in DataFrame
    available_features = [f for f in features if f in df.columns]
    missing_features = [f for f in features if f not in df.columns]
    
    if missing_features:
        print(f"Warning: Missing features: {missing_features}")
    
    X = df[available_features].copy()
    y = df['is_all_star'].copy()
    
    return X, y
