# Stock Market Analysis in SQL: Streamlit dashboard

Interactive dashboard for a SQL project on six NSE stocks (Bajaj Auto, Eicher Motors, Hero MotoCorp,
Infosys, TCS, TVS Motors), 1 Jan 2015 to 31 Jul 2018.

- 20-day and 50-day moving averages
- Golden-cross **Buy / Sell** signals
- The **data trap**: TCS and Infosys bonus issues that halve the share price overnight, and how adjusting for them
  changes returns (TCS -23.8% to +52.4%, Infosys -30.9% to +38.2%) and signals

Every number comes from SQL (window functions: `AVG() OVER`, `LAG`, `ROW_NUMBER`) run on an in-memory
SQLite database that the app builds from the six CSV files when it starts.
The original MySQL 8 project file is `stock_market_analysis.sql`.

## Project structure

```
app.py                       the Streamlit app
requirements.txt             Python packages
stock_market_analysis.sql    full MySQL 8 project (tasks 1-13)
*.csv                        the six CSV files (keep the file names exactly; they can also sit in a data/ folder)
```

## Run locally

```bash
pip install -r requirements.txt
streamlit run app.py
```

## Deploy on Streamlit Community Cloud

1. Push this folder to a **public** GitHub repository (`app.py` must be in the repository root).
2. Go to https://share.streamlit.io and sign in with GitHub.
3. Click **Create app**, choose the repository and branch `main`, set **Main file path** to `app.py`, and click **Deploy**.

## Dashboard tabs

| Tab | What it shows |
|---|---|
| Overview | Buys, sells, latest signal and % change per stock; raw vs adjusted chart |
| Price and signals | Price with 20/50-day averages and Buy/Sell markers; signal log; signals vs buy-and-hold |
| Compare stocks | All stocks rebased to 100 on the first day; master table of closing prices |
| The data trap | Worst day per stock, and the TCS / Infosys price cliff before and after adjustment |
| SQL used | The SQL queries behind the dashboard |

Use the sidebar switch to turn the bonus-issue adjustment on or off.

## Notes

- Bonus events: TCS 1:1 ex-date 2018-05-31; Infosys 1:1 ex-date 2015-06-15. Prices before the date are divided by 2.
- The signals back-test is simple (buy and sell at the close, no brokerage, tax or dividends).
- This is a student project, not investment advice.
