# Power BI Dashboard Design Guide: Industry Financial Benchmarker

This document outlines the step-by-step setup, data modeling, DAX formulations, and layout blueprints for creating a world-class, interactive **Industry Financial Benchmarking Dashboard** in Power BI Desktop using the provided CSV dataset.

---

## 1. Data Connection & Preparation (Power Query)

1. Open **Power BI Desktop**.
2. Click **Get Data** -> **Text/CSV**, and select `industry_financials.csv`.
3. In the Power Query preview window, click **Transform Data** to inspect schemas:
   * Validate that numeric columns (`revenue`, `cogs`, `netIncome`, `marketCap`, `rAndD`, `employees`) are set to **Decimal Number** or **Whole Number** data types.
   * Validate that textual columns (`id`, `name`, `industry`, `country`) are set to **Text**.
4. Geocode Country field: Click on the `country` column, go to the **Column Tools** tab in the main ribbon, and change the **Data Category** from "Uncategorized" to **Country/Region**. This enables native bubble mapping.
5. Click **Close & Apply** to load the fact table into the memory model.

---

## 2. Calculated Columns & Measures (DAX)

To build professional and interactive financial intelligence, create the following measures under your data table:

### Core Financial Ratios
```dax
Gross Profit Margin = 
DIVIDE(
    SUM('industry_financials'[revenue]) - SUM('industry_financials'[cogs]), 
    SUM('industry_financials'[revenue]), 
    0
)
```

```dax
Net Profit Margin = 
DIVIDE(
    SUM('industry_financials'[netIncome]), 
    SUM('industry_financials'[revenue]), 
    0
)
```

```dax
PE Ratio (P/E) = 
DIVIDE(
    SUM('industry_financials'[marketCap]), 
    SUM('industry_financials'[netIncome]), 
    0
)
```

---

### Topic 1, Part 1 DAX: 1% COGS Saving Impact (What-If Analysis)

To make your dashboard highly professional, we will configure a dynamic Slider Parameter for COGS optimization:
1. In the **Modeling** tab, click **New Parameter** -> **Numeric Range**.
2. Name the parameter `COGS Savings Pct`. Set the data type to **Decimal**, Minimum: **0.00** (0%), Maximum: **0.05** (5%), Increment: **0.001** (0.1%), Default: **0.01** (1.0%).
3. This creates a slicer table and a dynamic measure: `COGS Savings Pct Value = SELECTEDVALUE('COGS Savings Pct'[COGS Savings Pct], 0.01)`.

Now, write the following dynamic analytical measures:

```dax
Dynamic COGS Savings ($) = 
SUM('industry_financials'[cogs]) * [COGS Savings Pct Value]
```

```dax
Pro Forma Net Income ($) = 
SUM('industry_financials'[netIncome]) + [Dynamic COGS Savings ($)]
```

```dax
Net Income Increase (%) = 
DIVIDE(
    [Dynamic COGS Savings ($)], 
    SUM('industry_financials'[netIncome]), 
    0
)
```

```dax
Operating Leverage Multiplier = 
DIVIDE(
    SUM('industry_financials'[cogs]), 
    SUM('industry_financials'[netIncome]), 
    0
)
```

---

### Topic 1, Part 2 DAX: Linear Regression & Correlation

Power BI calculates trendlines natively, but calculating the Pearson Correlation ($r$) and R-Squared ($R^2$) via DAX provides elegant card telemetry:

```dax
Pearson Correlation Coefficient (r) = 
VAR AvgX = AVERAGE('industry_financials'[netIncome])
VAR AvgY = AVERAGE('industry_financials'[marketCap])
VAR DevX = SUMX('industry_financials', ('industry_financials'[netIncome] - AvgX) * ('industry_financials'[marketCap] - AvgY))
VAR VarX = SUMX('industry_financials', POWER('industry_financials'[netIncome] - AvgX, 2))
VAR VarY = SUMX('industry_financials', POWER('industry_financials'[marketCap] - AvgY, 2))
RETURN
DIVIDE(DevX, SQRT(VarX * VarY), 0)
```

```dax
R-Squared (R2) = 
POWER([Pearson Correlation Coefficient (r)], 2)
```

---

## 3. Visual Layout Blueprint (4-Page Report)

### Theme Palette (Swiss Tech Minimalist)
* **Primary Deep Charcoal**: `#1e293b` (Slate 800)
* **Secondary Light Off-White**: `#f8fafc` (Slate 50)
* **Accent Electric Blue**: `#2563eb` (Blue 600)
* **Highlight Pink-Red**: `#db2777` (Pink 600)

### Page 1: Overview & Industrial Landscape
* **Header Bar**: Title "GCPS Industry Benchmarking Workspace" + User Email Card.
* **Top KPI cards**: Total Market Cap, Total Revenue, Average Profit Margin, Active Industries count.
* **Main Visual (Left)**: Horizontal Bar Chart of *Market Cap by Industry*.
* **Main Visual (Right)**: Scatter Plot of *Market Cap vs. Revenue* to observe industry sizing.
* **Slicers**: Country, Industry (multi-select).

### Page 2: Part 1 - COGS Impact Analytics (Financial Sensitivity)
* **What-If Slicer**: Slider control connected to `COGS Savings Pct Value`.
* **Before/After KPI Blocks**:
  * Block 1: *Current Net Income* vs. *Pro Forma Net Income* (with conditional green arrow if pro-forma increases).
  * Block 2: *Net Income Increase (%)* (Large bold display).
  * Block 3: *Leverage Multiplier* (Displays sector sensitivity).
* **Matrix Grid Table**: Rows: Company Name. Columns: `Revenue`, `COGS`, `Net Income`, `COGS Savings ($)`, `Net Income Increase (%)`, `Leverage Multiplier`. Sorted descending by Leverage Multiplier.
* **Visual Anchor**: Clustered Column Chart showing *Current Net Income* and *Pro Forma Net Income* side-by-side for each firm in the selected industry.

### Page 3: Part 2 - Valuation & Regression (Market Cap vs. Net Income)
* **Regression Cards**: Display *R-Squared ($R^2$)*, *Pearson Correlation Coefficient ($r$)*, and *Benchmark P/E Ratio*.
* **Primary Visual**: **Scatter Chart**.
  * **X-Axis**: `netIncome` (Net Income in $M)
  * **Y-Axis**: `marketCap` (Market Capitalization in $M)
  * **Details**: Company Name.
  * **Legend/Color**: Industry.
  * **Analytics Pane**: Enable **Trend Line** -> Style: Dashed, Color: Red (`#db2777`), **Show Intercept & Formula**: True.
* **Context Cards**: Explanatory text block outlining how semiconductors display high P/E multiples due to forward growth expectations, while older sectors display tighter correlations.

### Page 4: Strategic Location & Entry Matrix
* **Map Visual (Bubble Map)**:
  * **Location**: `country`
  * **Bubble Size**: `marketCap` or `revenue`
  * **Tooltip**: Net Profit Margin, Operating Leverage.
* **Decomposition Tree**: Analyze *Total Market Cap* branching into -> *Industry* -> *Country* -> *Company*.
* **Location Fitness Table**: Shows Country scores comparing operating costs and talent index.
