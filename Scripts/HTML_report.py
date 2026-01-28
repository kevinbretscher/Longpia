import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

# Load combined TSV
df = pd.read_csv("combined_summary_statistics.tsv", sep="\t")

# Ensure numeric columns
numeric_cols = [
    "QV",
    "Base substitution",
    "Small-scale expansion",
    "Small-scale collapse",
]
df[numeric_cols] = df[numeric_cols].apply(pd.to_numeric, errors="coerce")

# -------------------------
# QV color scale table
# -------------------------
def qv_to_color(qv):
    if pd.isna(qv):
        return "#f9fafb"  # light gray

    if qv < 30:
        return "#dc2626"  # red
    elif qv < 50:
        return "#facc15"  # yellow
    else:
        return "#15803d"  # dark green


table_fig = go.Figure(
    data=[
        go.Table(
            header=dict(
                values=list(df.columns),
                fill_color="#1f2937",
                font=dict(color="white", size=13),
                align="left",
            ),
            cells=dict(
                values=[df[col] for col in df.columns],
                fill_color=[
                    [
                        qv_to_color(v) if col == "QV" else "#f9fafb"
                        for v in df[col]
                    ]
                    for col in df.columns
                ],
                align="left",
                font=dict(size=12),
            ),
        )
    ]
)

table_height = 40 + 70 * len(df)   # header + rows

table_fig.update_layout(
    title="Assembly Summary Statistics",
    height=table_height,
    margin=dict(t=40, b=10, l=20, r=20)
)

# -------------------------
# Stacked bar plot
# -------------------------
bar_fig = px.bar(
    df,
    x="Sample",
    y=[
        "Base substitution",
        "Small-scale expansion",
        "Small-scale collapse",
    ],
    title="Small-scale Assembly Errors",
    labels={"value": "Error count", "variable": "Error type"},
)

bar_fig.update_layout(
    barmode="stack",
    template="plotly_white",
    margin=dict(t=40, b=40, l=40, r=40)
)

# -------------------------
# Export HTML
# -------------------------
html_output = "Inspector_report.html"

with open(html_output, "w") as f:
    
    f.write("<html><head><title>Inspector Report</title></head><body>")
    f.write("<h1 style='font-family:Arial'>Inspector Assembly Report</h1>")
    f.write(table_fig.to_html(full_html=False, include_plotlyjs="cdn"))
    f.write(bar_fig.to_html(full_html=False, include_plotlyjs=False))
    f.write("</body></html>")

print(f"HTML report written to: {html_output}")
