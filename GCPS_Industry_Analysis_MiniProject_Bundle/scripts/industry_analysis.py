# -*- coding: utf-8 -*-
"""
Industry Analysis Mini-Project Analytical Suite
Author: Industry Analyst / AI Workspace
Description: This script loads industrial financial datasets, calculates the impact of a
             1% saving of COGS on the net income (Topic 1, Part 1), and models the 
             correlation between market cap and net income with linear regression (Topic 1, Part 2).
"""

import io
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats

# ==========================================
# 1. DEFINE & LOAD INDUSTRIAL DATASET
# ==========================================

csv_data = """id,name,industry,country,revenue,cogs,netIncome,marketCap,employees,rAndD
SC01,Nvidia Corp,Semiconductors & Electronics,United States,96310,23890,52990,3120000,29600,11200
SC02,TSMC,Semiconductors & Electronics,Taiwan,75880,34150,30120,840000,76000,5800
SC03,Intel Corp,Semiconductors & Electronics,United States,54200,32520,1680,110000,124800,16500
SC04,Samsung Electronics,Semiconductors & Electronics,South Korea,198500,136200,11400,360000,270000,22100
SC05,ASML Holding,Semiconductors & Electronics,Netherlands,29600,14450,8430,380000,42400,4100
SC06,Broadcom Inc,Semiconductors & Electronics,United States,42600,13800,11580,780000,20000,5300
SC07,AMD,Semiconductors & Electronics,United States,22680,11250,850,260000,26000,5900
SC08,Qualcomm Inc,Semiconductors & Electronics,United States,35820,15720,7230,190000,50000,8800
SC09,Tokyo Electron,Semiconductors & Electronics,Japan,15400,8470,3100,95000,17200,1400
SC10,MediaTek,Semiconductors & Electronics,Taiwan,14200,7380,2540,52000,22000,1900
PH01,Eli Lilly & Co,Pharmaceuticals & Biotech,United States,34120,7120,6240,810000,43000,9300
PH02,Novo Nordisk,Pharmaceuticals & Biotech,Netherlands,33700,5390,12100,590000,64000,4800
PH03,Pfizer Inc,Pharmaceuticals & Biotech,United States,58500,23400,2130,160000,88000,10700
PH04,Roche Holding,Pharmaceuticals & Biotech,Netherlands,64800,16200,13200,240000,101000,14100
PH05,Merck & Co,Pharmaceuticals & Biotech,United States,60100,16830,3650,290000,72000,13600
AV01,Tesla Inc,Automotive & Electric Vehicles,United States,96770,79120,15000,740000,140000,3960
AV02,Toyota Motor,Automotive & Electric Vehicles,Japan,295000,236000,33100,290000,375000,8900
AV03,BYD Company,Automotive & Electric Vehicles,China,85000,68000,4200,98000,570000,5200
AV04,Volkswagen Group,Automotive & Electric Vehicles,Germany,348000,288760,19400,65000,684000,15800
EC01,Amazon.com Inc,E-Commerce & Digital Retail,United States,574800,304600,30400,1950000,1525000,85200
EC02,Alibaba Group,E-Commerce & Digital Retail,China,130200,81300,11200,185000,220000,7300
RE01,NextEra Energy,Renewable Energy & Cleantech,United States,28100,12400,7310,148000,16800,300
RE02,First Solar,Renewable Energy & Cleantech,United States,3300,2200,830,22000,6700,180
"""

df = pd.read_csv(io.StringIO(csv_data))

print("=== INDUSTRY ANALYSIS MINI-PROJECT DATASET SUCCESSFULLY LOADED ===")
print(f"Loaded {len(df)} key global firms across {df['industry'].nunique()} sectors.\n")

# ==========================================
# 2. PART 1: 1% COGS SAVING IMPACT ANALYSIS
# ==========================================
print("--- PART 1: Impact of 1% Saving of COGS on Net Income ---")

# Calculate absolute COGS savings (1%)
df['COGS_Savings_1pct'] = df['cogs'] * 0.01

# Pro forma Net Income after COGS savings
df['Pro_Forma_Net_Income'] = df['netIncome'] + df['COGS_Savings_1pct']

# Calculate Net Income % Increase
df['Net_Income_Increase_Pct'] = (df['COGS_Savings_1pct'] / df['netIncome'].replace(0, np.nan)) * 100

# Leverage Multiplier (Symmetric impact ratio)
# How many percent does Net Income grow for every 1% decline in COGS
df['Leverage_Multiplier'] = df['cogs'] / df['netIncome'].replace(0, np.nan)

# Display top 10 firms sorted by leverage multiplier (where COGS saving is most impactful)
impact_df = df[['name', 'industry', 'revenue', 'cogs', 'netIncome', 'COGS_Savings_1pct', 'Net_Income_Increase_Pct', 'Leverage_Multiplier']].sort_values(by='Leverage_Multiplier', ascending=False)
print(impact_df.head(10).to_string(index=False, formatters={
    'revenue': '${:,.0f}M'.format,
    'cogs': '${:,.0f}M'.format,
    'netIncome': '${:,.0f}M'.format,
    'COGS_Savings_1pct': '${:,.1f}M'.format,
    'Net_Income_Increase_Pct': '{:.2f}%'.format,
    'Leverage_Multiplier': '{:.2f}x'.format
}))
print("\nSummary: Sectors with thin profit margins and heavy cost bases (like Automotive and E-Commerce) ")
print("display massive sensitivity multipliers. In contrast, R&D-intensive software/chip designers ")
print("like Nvidia have lower multipliers but high absolute dollar benefits.\n")


# ==========================================
# 3. PART 2: CORRELATION BETWEEN MARKET CAP AND NET INCOME
# ==========================================
print("--- PART 2: Correlation Analysis (Market Cap vs Net Income) ---")

# Filter out negative net incomes for a clean, logical regression model
regression_df = df[df['netIncome'] > 0]

x = regression_df['netIncome']
y = regression_df['marketCap']

# Compute Pearson correlation and linear regression parameters
slope, intercept, r_value, p_value, std_err = stats.linregress(x, y)
r_squared = r_value ** 2

print(f"Pearson Correlation Coefficient (r): {r_value:.4f}")
print(f"Coefficient of Determination (R²): {r_squared:.4f}")
print(f"Regression Line Equation: Market_Cap = {slope:.2f} * Net_Income + {intercept:.2f}")
print(f"P-Value: {p_value:.2e} (Statistically {'significant' if p_value < 0.05 else 'not significant'})\n")

# ==========================================
# 4. PLOTTING THE RESULTS
# ==========================================
print("Generating regression scatter plot...")
plt.figure(figsize=(10, 6), dpi=100)
plt.style.use('seaborn-v0_8-whitegrid' if 'seaborn-v0_8-whitegrid' in plt.style.available else 'default')

# Create scatter points colored by industry
colors = {'Semiconductors & Electronics': '#3b82f6', 
          'Pharmaceuticals & Biotech': '#ec4899', 
          'Automotive & Electric Vehicles': '#f59e0b', 
          'E-Commerce & Digital Retail': '#10b981', 
          'Renewable Energy & Cleantech': '#8b5cf6'}

for ind, color in colors.items():
    sub_df = regression_df[regression_df['industry'] == ind]
    plt.scatter(sub_df['netIncome'], sub_df['marketCap'], label=ind, color=color, s=80, alpha=0.8, edgecolors='black')

# Plot the linear regression trendline
x_line = np.linspace(x.min(), x.max(), 100)
y_line = slope * x_line + intercept
plt.plot(x_line, y_line, color='#ef4444', linestyle='--', linewidth=2.5, 
         label=f"Trendline: MC = {slope:.1f}*NI + {intercept:.1f}\n(R² = {r_squared:.3f})")

plt.title("Industry Analysis: Market Capitalization vs Net Income", fontsize=14, fontweight='bold', pad=15)
plt.xlabel("Net Income ($ Millions USD)", fontsize=11, labelpad=10)
plt.ylabel("Market Capitalization ($ Millions USD)", fontsize=11, labelpad=10)
plt.gca().get_yaxis().set_major_formatter(plt.FuncFormatter(lambda val, loc: f"${val:,.0f}M"))
plt.gca().get_xaxis().set_major_formatter(plt.FuncFormatter(lambda val, loc: f"${val:,.0f}M"))

plt.legend(frameon=True, facecolor='white', framealpha=0.9, fontsize=10)
plt.tight_layout()

# Save the plot as an artifact
plt.savefig('market_cap_net_income_correlation.png')
print("Plot successfully saved as 'market_cap_net_income_correlation.png'.")
print("=== PYTHON ANALYTICAL EXECUTION COMPLETE ===")
