"""
Tests for data processing module.
"""

import pytest
import pandas as pd
import numpy as np
from src.data_processing import (
    merge_datasets,
    clean_missing_values, 
    process_height_weight,
    process_age_data
)


class TestDataProcessing:
    """Test cases for data processing functions."""
    
    def test_merge_datasets(self):
        """Test dataset merging functionality."""
        # Create sample data
        player_data = pd.DataFrame({
            'name': ['Player A', 'Player B'],
            'height': ['6-6', '6-8'],
            'weight': [200, 220]
        })
        
        seasons_stats = pd.DataFrame({
            'Player': ['Player A', 'Player B'],
            'Year': [2015, 2015],
            'PTS': [20.0, 15.0],
            'AST': [5.0, 8.0]
        })
        
        all_star = pd.DataFrame({
            'Player': ['Player A'],
            'Year': [2015]
        })
        
        result = merge_datasets(player_data, seasons_stats, all_star)
        
        assert 'is_all_star' in result.columns
        assert result['is_all_star'].sum() == 1
        assert len(result) == 2
    
    def test_clean_missing_values(self):
        """Test missing value cleaning."""
        df = pd.DataFrame({
            'PTS': [20.0, np.nan, 15.0],
            'FG': [8.0, 6.0, 5.0],
            'FGA': [16.0, 12.0, 10.0],
            'FG%': [0.5, np.nan, 0.5],
            'college': ['Duke', np.nan, 'UNC']
        })
        
        result = clean_missing_values(df)
        
        # Check that FG% was calculated for missing values
        assert not pd.isna(result.loc[1, 'FG%'])
        assert result.loc[1, 'FG%'] == 0.5  # 6/12
        
        # Check that college was filled
        assert result.loc[1, 'college'] == 'Unknown'
    
    def test_process_height_weight(self):
        """Test height and weight processing."""
        df = pd.DataFrame({
            'height': ['6-6', '6-8', None],
            'weight': [200, np.nan, 220]
        })
        
        result = process_height_weight(df)
        
        assert 'height_cm' in result.columns
        assert result.loc[0, 'height_cm'] == pytest.approx(198.1, rel=1e-1)
        assert not pd.isna(result['weight']).any()
    
    def test_process_age_data(self):
        """Test age data processing."""
        df = pd.DataFrame({
            'birth_date': ['1990-01-01', '1985-06-15', None],
            'Year': [2015, 2015, 2015],
            'year_start': [2010, np.nan, 2012],
            'year_end': [2018, np.nan, 2020]
        })
        
        result = process_age_data(df)
        
        assert 'age_calc' in result.columns
        assert result.loc[0, 'age_calc'] == 25  # 2015 - 1990
        assert not pd.isna(result['year_start']).any()
        assert not pd.isna(result['year_end']).any()
