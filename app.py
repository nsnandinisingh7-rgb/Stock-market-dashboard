"""
Stock Market Analysis in SQL - Streamlit dashboard
Six NSE stocks, 1 Jan 2015 to 31 Jul 2018.

The CSV files in /data are loaded into an in-memory SQLite database when the app
starts, and every number on the dashboard comes from SQL queries (window functions:
AVG() OVER, LAG, ROW_NUMBER) - the same logic as the MySQL project file.
"""
import sqlite3
from pathlib import Path

import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st

st.set_page_config(page_title="NSE Stock Signals", page_icon="📈", layout="wide")

# --------------------------------------------------------------------------- #
# Configuration
# --------------------------------------------------------------------------- #
_BASE = Path(__file__).parent
# CSV files may sit in a "data" folder or directly next to app.py (flat GitHub upload).
DATA_DIR = _BASE / "data" if (_BASE / "data").is_dir() else _BASE

FILES = {  # display name -> (csv file, table name)
    "Bajaj Auto": ("Bajaj_Auto.csv", "bajaj_auto"),
    "Eicher Motors": ("Eicher_Motors.csv", "eicher_motors"),
    "Hero MotoCorp": ("Hero_Motocorp.csv", "hero_motocorp"),
    "Infosys": ("Infosys.csv", "infosys"),
    "TCS": ("TCS.csv", "tcs"),
    "TVS Motors": ("TVS_Motors.csv", "tvs_motors"),
}
STOCK_NAMES = list(FILES)

# 1:1 bonus issues -> price halves on the ex-date. Prices BEFORE the date are divided by 2.
BONUS_EVENTS = {"TCS": "2018-05-31", "Infosys": "2015-06-15"}
BONUS_FACTOR = 2

COLUMNS = [
    "date", "open_price", "high_price", "low_price", "close_price", "wap",
    "no_of_shares", "no_of_trades", "total_turnover", "deliverable_qty",
    "pct_deli_qty", "spread_high_low", "spread_close_open",
]

C_PRICE, C_MA20, C_MA50 = "#7F7F7F", "#F28E2B", "#1F5FBF"
C_BUY, C_SELL = "#2E9E4F", "#D62728"

# --------------------------------------------------------------------------- #
# SQL
# --------------------------------------------------------------------------- #
SQL_PRICES_RAW = " UNION ALL ".join(
    f"SELECT '{name}' AS stock, date, close_price FROM {tbl}" for name, (_, tbl) in FILES.items()
)

SQL_PRICES_ADJ = """
SELECT stock, date,
       CASE
         WHEN stock = 'TCS'     AND date < '{tcs}' THEN close_price / {f}
         WHEN stock = 'Infosys' AND date < '{infy}' THEN close_price / {f}
         ELSE close_price
       END AS close_price
FROM prices_raw
""".format(tcs=BONUS_EVENTS["TCS"], infy=BONUS_EVENTS["Infosys"], f=BONUS_FACTOR)

# Task 5 + 7 + 10 in one query: moving averages, lags and signals for all six stocks.
SQL_SIGNALS = """
WITH ma AS (
  SELECT stock, date, close_price,
    CASE WHEN ROW_NUMBER() OVER (PARTITION BY stock ORDER BY date) >= 20
         THEN AVG(close_price) OVER (PARTITION BY stock ORDER BY date
                                     ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) END AS ma20,
    CASE WHEN ROW_NUMBER() OVER (PARTITION BY stock ORDER BY date) >= 50
         THEN AVG(close_price) OVER (PARTITION BY stock ORDER BY date
                                     ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) END AS ma50
  FROM {src}
),
lagged AS (
  SELECT *,
         LAG(ma20) OVER (PARTITION BY stock ORDER BY date) AS prev_ma20,
         LAG(ma50) OVER (PARTITION BY stock ORDER BY date) AS prev_ma50
  FROM ma
)
SELECT stock, date, close_price, ma20, ma50,
  CASE
    WHEN ma20 IS NULL OR ma50 IS NULL OR prev_ma20 IS NULL OR prev_ma50 IS NULL THEN 'Hold'
    WHEN ma20 > ma50 AND prev_ma20 <= prev_ma50 THEN 'Buy'
    WHEN ma20 < ma50 AND prev_ma20 >= prev_ma50 THEN 'Sell'
    ELSE 'Hold'
  END AS signal
FROM lagged
"""

# Task 10 + 11: buys, sells, latest signal and first-to-last change for every stock.
SQL_SUMMARY = """
WITH ends AS (
  SELECT stock, MIN(date) AS first_date, MAX(date) AS last_date FROM {sig} GROUP BY stock
),
latest AS (
  SELECT stock, date, signal,
         ROW_NUMBER() OVER (PARTITION BY stock ORDER BY date DESC) AS rn
  FROM {sig} WHERE signal <> 'Hold'
),
counts AS (
  SELECT stock, SUM(signal = 'Buy') AS buys, SUM(signal = 'Sell') AS sells
  FROM {sig} GROUP BY stock
)
SELECT e.stock,
       f.close_price AS first_close,
       l.close_price AS last_close,
       ROUND(100.0 * (l.close_price - f.close_price) / f.close_price, 1) AS pct_change,
       c.buys, c.sells,
       la.date AS last_signal_date, la.signal AS last_signal
FROM ends e
JOIN {sig} f  ON f.stock = e.stock AND f.date = e.first_date
JOIN {sig} l  ON l.stock = e.stock AND l.date = e.last_date
JOIN counts c ON c.stock = e.stock
JOIN latest la ON la.stock = e.stock AND la.rn = 1
"""

# Task 12: each stock's single worst day.
SQL_WORST_DAY = """
WITH moves AS (
  SELECT stock, date, close_price,
         100.0 * (close_price / LAG(close_price) OVER (PARTITION BY stock ORDER BY date) - 1) AS pct_move
  FROM {src}
),
ranked AS (
  SELECT stock, date, close_price, ROUND(pct_move, 1) AS pct_move,
         ROW_NUMBER() OVER (PARTITION BY stock ORDER BY pct_move ASC) AS rn
  FROM moves WHERE pct_move IS NOT NULL
)
SELECT stock, date, close_price, pct_move FROM ranked WHERE rn = 1 ORDER BY pct_move
"""


# --------------------------------------------------------------------------- #
# Data loading
# --------------------------------------------------------------------------- #
@st.cache_resource(show_spinner="Loading data into SQLite...")
def get_connection() -> sqlite3.Connection:
    con = sqlite3.connect(":memory:", check_same_thread=False)
    for _, (csv_name, table) in FILES.items():
        df = pd.read_csv(DATA_DIR / csv_name, header=0, names=COLUMNS)
        df["date"] = pd.to_datetime(df["date"].str.strip(), format="%d-%B-%Y").dt.strftime("%Y-%m-%d")
        df.to_sql(table, con, index=False, if_exists="replace")
    con.execute(f"CREATE TABLE prices_raw AS {SQL_PRICES_RAW}")
    con.execute(f"CREATE TABLE prices_adj AS {SQL_PRICES_ADJ}")
    con.execute("CREATE TABLE sig_raw AS " + SQL_SIGNALS.format(src="prices_raw"))
    con.execute("CREATE TABLE sig_adj AS " + SQL_SIGNALS.format(src="prices_adj"))
    con.commit()
    return con


def table_for(adjusted: bool) -> str:
    return "sig_adj" if adjusted else "sig_raw"


@st.cache_data(show_spinner=False)
def load_series(adjusted: bool) -> pd.DataFrame:
    df = pd.read_sql(f"SELECT * FROM {table_for(adjusted)} ORDER BY stock, date", get_connection())
    df["date"] = pd.to_datetime(df["date"])
    return df


@st.cache_data(show_spinner=False)
def load_summary(adjusted: bool) -> pd.DataFrame:
    sql = SQL_SUMMARY.format(sig=table_for(adjusted)) + " ORDER BY pct_change DESC"
    return pd.read_sql(sql, get_connection())


@st.cache_data(show_spinner=False)
def load_worst_day(adjusted: bool) -> pd.DataFrame:
    src = "prices_adj" if adjusted else "prices_raw"
    return pd.read_sql(SQL_WORST_DAY.format(src=src), get_connection())


@st.cache_data(show_spinner=False)
def load_raw_vs_adjusted(stock: str) -> pd.DataFrame:
    sql = """
    SELECT r.date, r.close_price AS raw_close, a.close_price AS adjusted_close
    FROM prices_raw r JOIN prices_adj a ON a.stock = r.stock AND a.date = r.date
    WHERE r.stock = ? ORDER BY r.date
    """
    df = pd.read_sql(sql, get_connection(), params=(stock,))
    df["date"] = pd.to_datetime(df["date"])
    return df


def backtest(series: pd.DataFrame) -> pd.DataFrame:
    """Simple back-test: buy at the close on a Buy day, sell at the close on the next Sell day."""
    rows = []
    for stock, g in series.groupby("stock"):
        g = g.sort_values("date")
        growth, entry = 1.0, None
        for _, r in g[g["signal"] != "Hold"].iterrows():
            if r["signal"] == "Buy" and entry is None:
                entry = r["close_price"]
            elif r["signal"] == "Sell" and entry is not None:
                growth *= r["close_price"] / entry
                entry = None
        if entry is not None:  # still holding at the end of the data
            growth *= g["close_price"].iloc[-1] / entry
        hold = g["close_price"].iloc[-1] / g["close_price"].iloc[0]
        rows.append({"Stock": stock,
                     "Following the signals (%)": round(100 * (growth - 1), 1),
                     "Buy and hold (%)": round(100 * (hold - 1), 1)})
    return pd.DataFrame(rows).sort_values("Buy and hold (%)", ascending=False)


def style_signal(v):
    return {"Buy": f"color:{C_BUY};font-weight:600", "Sell": f"color:{C_SELL};font-weight:600"}.get(v, "")


# --------------------------------------------------------------------------- #
# Sidebar
# --------------------------------------------------------------------------- #
st.sidebar.title("📈 NSE Stock Signals")
st.sidebar.caption("Six stocks · 1 Jan 2015 to 31 Jul 2018 · 889 trading days each")
adjusted = st.sidebar.toggle(
    "Adjust TCS and Infosys for bonus issues",
    value=True,
    help="Both companies did a 1:1 bonus issue that halved the share price overnight "
         "(TCS on 31 May 2018, Infosys on 15 Jun 2015). Switch this off to see the raw, misleading numbers.",
)
if adjusted:
    st.sidebar.success("Showing bonus-adjusted prices (correct).")
else:
    st.sidebar.warning("Showing raw prices. TCS and Infosys results are distorted.")
st.sidebar.markdown("---")
st.sidebar.caption("Signal rule: **Buy** when the 20-day average crosses above the 50-day average, "
                   "**Sell** when it crosses below.")

series = load_series(adjusted)
summary = load_summary(adjusted)

st.title("Stock Market Analysis in SQL")
st.caption("Moving averages, golden-cross signals and the data problem hiding in plain sight")

tab_overview, tab_price, tab_compare, tab_trap, tab_sql = st.tabs(
    ["Overview", "Price and signals", "Compare stocks", "The data trap", "SQL used"]
)

# --------------------------------------------------------------------------- #
# Overview
# --------------------------------------------------------------------------- #
with tab_overview:
    best = summary.iloc[0]
    worst = summary.iloc[-1]
    k1, k2, k3, k4 = st.columns(4)
    k1.metric("Total Buy signals", int(summary["buys"].sum()))
    k2.metric("Total Sell signals", int(summary["sells"].sum()))
    k3.metric("Best performer", best["stock"], f"{best['pct_change']:+.1f}%")
    k4.metric("Weakest performer", worst["stock"], f"{worst['pct_change']:+.1f}%")

    st.subheader("Summary by stock")
    show = summary.rename(columns={
        "stock": "Stock", "first_close": "First close", "last_close": "Last close",
        "pct_change": "Change (%)", "buys": "Buys", "sells": "Sells",
        "last_signal_date": "Latest signal date", "last_signal": "Latest signal"})
    st.dataframe(
        show.style.map(style_signal, subset=["Latest signal"])
            .format({"First close": "{:,.2f}", "Last close": "{:,.2f}", "Change (%)": "{:+.1f}"}),
        hide_index=True)

    st.subheader("Raw vs bonus-adjusted change")
    raw_s = load_summary(False)[["stock", "pct_change"]].assign(Prices="Raw")
    adj_s = load_summary(True)[["stock", "pct_change"]].assign(Prices="Adjusted")
    both = pd.concat([raw_s, adj_s])
    fig = px.bar(both, x="stock", y="pct_change", color="Prices", barmode="group",
                 color_discrete_map={"Raw": "#BDBDBD", "Adjusted": "#1F3864"},
                 labels={"stock": "", "pct_change": "Change, first to last day (%)"},
                 category_orders={"stock": list(adj_s.sort_values("pct_change", ascending=False)["stock"])},
                 text="pct_change")
    fig.update_traces(texttemplate="%{text:+.1f}%", textposition="outside")
    fig.update_layout(height=420, margin=dict(t=20, b=10), legend_title_text="")
    st.plotly_chart(fig)

    st.info(
        "**Key finding.** On raw prices TCS (-23.8%) and Infosys (-30.9%) look like losers. "
        "That is wrong: both did a 1:1 bonus issue that halved the price without any loss. "
        "Adjusted, TCS is **+52.4%** and Infosys **+38.2%**, and TCS's latest signal changes "
        "from Sell to **Buy**."
    )

# --------------------------------------------------------------------------- #
# Price and signals
# --------------------------------------------------------------------------- #
with tab_price:
    c1, c2 = st.columns([1, 2])
    stock = c1.selectbox("Stock", STOCK_NAMES, index=0)
    g_all = series[series["stock"] == stock]
    d_min, d_max = g_all["date"].min().date(), g_all["date"].max().date()
    d_from, d_to = c2.slider("Date range", min_value=d_min, max_value=d_max, value=(d_min, d_max))
    o1, o2, o3 = st.columns(3)
    show_ma20 = o1.checkbox("20-day average", value=True)
    show_ma50 = o2.checkbox("50-day average", value=True)
    show_sig = o3.checkbox("Buy / Sell markers", value=True)

    g = g_all[(g_all["date"].dt.date >= d_from) & (g_all["date"].dt.date <= d_to)]
    fig = go.Figure()
    fig.add_trace(go.Scatter(x=g["date"], y=g["close_price"], name="Close", line=dict(color=C_PRICE, width=1.4)))
    if show_ma20:
        fig.add_trace(go.Scatter(x=g["date"], y=g["ma20"], name="20-day average", line=dict(color=C_MA20, width=2)))
    if show_ma50:
        fig.add_trace(go.Scatter(x=g["date"], y=g["ma50"], name="50-day average", line=dict(color=C_MA50, width=2)))
    if show_sig:
        for label, color, symbol in [("Buy", C_BUY, "triangle-up"), ("Sell", C_SELL, "triangle-down")]:
            s = g[g["signal"] == label]
            fig.add_trace(go.Scatter(x=s["date"], y=s["close_price"], mode="markers", name=label,
                                     marker=dict(color=color, size=13, symbol=symbol,
                                                 line=dict(color="white", width=1))))
    fig.update_layout(height=520, margin=dict(t=20, b=10), hovermode="x unified",
                      yaxis_title="Close price (Rs.)", legend=dict(orientation="h", y=1.08))
    st.plotly_chart(fig)

    row = summary[summary["stock"] == stock].iloc[0]
    m1, m2, m3, m4 = st.columns(4)
    m1.metric("Change over full period", f"{row['pct_change']:+.1f}%")
    m2.metric("Buys / Sells", f"{int(row['buys'])} / {int(row['sells'])}")
    m3.metric("Latest signal", row["last_signal"])
    m4.metric("Latest signal date", row["last_signal_date"])

    st.subheader(f"Signal log: {stock}")
    log = g[g["signal"] != "Hold"][["date", "signal", "close_price", "ma20", "ma50"]].copy()
    log["date"] = log["date"].dt.strftime("%Y-%m-%d")
    log = log.rename(columns={"date": "Date", "signal": "Signal", "close_price": "Close",
                              "ma20": "20-day avg", "ma50": "50-day avg"})
    st.dataframe(log.style.map(style_signal, subset=["Signal"])
                    .format({"Close": "{:,.2f}", "20-day avg": "{:,.2f}", "50-day avg": "{:,.2f}"}),
                 hide_index=True)

    st.subheader("Did following the signals beat buy-and-hold?")
    st.caption("Simple back-test over the full period: buy at the close on a Buy day, sell at the close on the "
               "next Sell day, no brokerage, tax or slippage. Real costs would make the signal results worse.")
    st.dataframe(backtest(series), hide_index=True)

# --------------------------------------------------------------------------- #
# Compare stocks
# --------------------------------------------------------------------------- #
with tab_compare:
    chosen = st.multiselect("Stocks to compare", STOCK_NAMES, default=STOCK_NAMES)
    if not chosen:
        st.warning("Pick at least one stock.")
    else:
        wide = series[series["stock"].isin(chosen)].pivot(index="date", columns="stock", values="close_price")
        rebased = wide / wide.iloc[0] * 100
        fig = px.line(rebased, labels={"value": "Rebased to 100 on the first day", "date": "", "stock": ""})
        fig.add_hline(y=100, line_dash="dot", line_color="#999999")
        fig.update_layout(height=520, margin=dict(t=20, b=10), hovermode="x unified", legend_title_text="")
        st.plotly_chart(fig)
        st.caption("Each line starts at 100. A line ending at 150 means the price rose 50% over the period."
                   + ("" if adjusted else " Raw prices: the TCS and Infosys lines show a false cliff."))

        st.subheader("Closing prices (master table)")
        master = wide.copy()
        master.index = master.index.strftime("%Y-%m-%d")
        st.dataframe(master.reset_index().rename(columns={"date": "Date"}).sort_values("Date", ascending=False),
                     hide_index=True)

# --------------------------------------------------------------------------- #
# The data trap
# --------------------------------------------------------------------------- #
with tab_trap:
    st.subheader("Each stock's single worst day")
    st.write("A large, profitable company does not lose half its value in one day with no headlines. "
             "Two rows below are about -50%.")
    w1, w2 = st.columns(2)
    w1.markdown("**Raw prices**")
    w1.dataframe(load_worst_day(False).rename(columns={"stock": "Stock", "date": "Date",
                 "close_price": "Close", "pct_move": "Move (%)"}), hide_index=True)
    w2.markdown("**After bonus adjustment**")
    w2.dataframe(load_worst_day(True).rename(columns={"stock": "Stock", "date": "Date",
                 "close_price": "Close", "pct_move": "Move (%)"}), hide_index=True)

    st.subheader("The cliff, before and after the fix")
    ev_stock = st.radio("Stock", list(BONUS_EVENTS), horizontal=True)
    ev_date = BONUS_EVENTS[ev_stock]
    d = load_raw_vs_adjusted(ev_stock)
    fig = go.Figure()
    fig.add_trace(go.Scatter(x=d["date"], y=d["raw_close"], name="Raw close", line=dict(color="#D62728", width=1.6)))
    fig.add_trace(go.Scatter(x=d["date"], y=d["adjusted_close"], name="Adjusted close",
                             line=dict(color="#1F3864", width=2)))
    fig.add_shape(type="line", x0=ev_date, x1=ev_date, y0=0, y1=1, yref="paper",
                  line=dict(color="#555555", dash="dot"))
    fig.add_annotation(x=ev_date, y=1, yref="paper", text=f"Bonus issue {ev_date}", showarrow=False,
                       yanchor="bottom", font=dict(size=12))
    fig.update_layout(height=460, margin=dict(t=30, b=10), hovermode="x unified",
                      yaxis_title="Close price (Rs.)", legend=dict(orientation="h", y=1.1))
    st.plotly_chart(fig)

    st.markdown(
        f"""
**What happened.** In a 1:1 bonus issue every shareholder receives one extra share for each share held.
The number of shares doubles, so the price halves, but nobody gains or loses anything. To compare prices across
the event date, every price **before** it is divided by 2.

| | TCS | Infosys |
|---|---|---|
| Date the price changes (ex-date) | 2018-05-31 | 2015-06-15 |
| Raw change over the period | -23.8% | -30.9% |
| Adjusted change | **+52.4%** | **+38.2%** |

**Why it matters for signals.** The cliff also drags the 20-day average below the 50-day average, which can
create a Sell that never reflected a real price move. On raw prices TCS shows 12 Buys / 13 Sells and a latest
signal of Sell (2018-06-05); adjusted, it shows 12 / 12 and a latest signal of **Buy (2018-04-20)**.

Sources: [NSE circular on the TCS bonus issue](https://nsearchives.nseindia.com/content/circulars/FAOP37820.pdf) ·
[Business Standard on Infosys going ex-bonus](https://www.business-standard.com/article/markets/infosys-turns-ex-bonus-ex-dividend-today-115061500129_1.html)
"""
    )

# --------------------------------------------------------------------------- #
# SQL used
# --------------------------------------------------------------------------- #
with tab_sql:
    st.write("Every number in this dashboard comes from SQL run on an in-memory SQLite database built from the CSV files. "
             "The MySQL version of the full project is in `stock_market_analysis.sql`.")
    st.subheader("Bonus-adjusted prices")
    st.code(SQL_PRICES_ADJ.strip(), language="sql")
    st.subheader("Moving averages and golden-cross signals (all six stocks)")
    st.code(SQL_SIGNALS.format(src="prices_adj").strip(), language="sql")
    st.subheader("Summary: buys, sells, latest signal and change")
    st.code(SQL_SUMMARY.format(sig="sig_adj").strip(), language="sql")
    st.subheader("Worst day per stock")
    st.code(SQL_WORST_DAY.format(src="prices_raw").strip(), language="sql")
