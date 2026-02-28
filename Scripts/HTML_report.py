#!/usr/bin/env python3
"""
Generate a modern HTML quality report from combined_summary_statistics.tsv.

Creates Reports/quality_report/index.html and per-sample pages with interactive
Plotly charts and a Bootstrap layout, using DataTables for advanced table features.

Usage: python Scripts/HTML_report.py
"""
from __future__ import annotations

import json
from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
TSV = ROOT / "combined_summary_statistics.tsv"
OUTDIR = ROOT / "Reports" / "quality_report"
OUTDIR.mkdir(parents=True, exist_ok=True)


def safe_numeric(s):
    try:
        if pd.isna(s):
            return None
        sstr = str(s).split("(")[0].replace("%", "").strip()
        return float(sstr)
    except Exception:
        return None


def make_index(df: pd.DataFrame):
    samples = list(df["Sample"])

    base_sub = [safe_numeric(x) or 0 for x in df.get("Inspector_Base_substitution", [])]
    small_exp = [safe_numeric(x) or 0 for x in df.get("Inspector_Small-scale_expansion", [])]
    small_col = [safe_numeric(x) or 0 for x in df.get("Inspector_Small-scale_collapse", [])]

    # Prefer CheckM columns, fall back to CheckM2 if necessary
    completeness_col = next((c for c in ("CheckM_Completeness", "CheckM2_Completeness") if c in df.columns), None)
    contamination_col = next((c for c in ("CheckM_Contamination", "CheckM2_Contamination") if c in df.columns), None)
    completeness_vals = [safe_numeric(x) or 0 for x in df.get(completeness_col, [])] if completeness_col else []
    contamination_vals = [safe_numeric(x) or 0 for x in df.get(contamination_col, [])] if contamination_col else []

    # Columns to show by default in table
    default_cols = {
        "Sample", "CheckM_Completeness", "CheckM2_Completeness", 
        "CheckM_Contamination", "CheckM2_Contamination",
        "CRAQ_Avg_CRE", "CRAQ_Avg_CSE",
        "BUSCO_Complete", "BUSCO_Single", "BUSCO_Duplicated", "BUSCO_Fragmented", "BUSCO_Missing",
        "Inspector_Number_of_contigs", "Inspector_QV"
    }

    # All columns in the dataframe
    all_cols = list(df.columns)
    col_info = {}  # col -> (visible_by_default, label)
    for col in all_cols:
        if col == "Sample":
            col_info[col] = (True, "Sample")
        elif col == "Inspector_QV":
            col_info[col] = (True, col.replace("_", " "))
        elif col in default_cols:
            col_info[col] = (True, col.replace("_", " "))
        else:
            col_info[col] = (False, col.replace("_", " "))

    # DataTables table HTML
    headers_html = ""
    for col in all_cols:
        visible, label = col_info[col]
        vis_class = "" if visible else "d-none"
        headers_html += f'        <th data-col="{col}" class="{vis_class}">{label}</th>\n'

    rows_html = ""
    for _, row in df.iterrows():
        rows_html += "      <tr>\n"
        for col in all_cols:
            visible, _ = col_info[col]
            vis_class = "" if visible else "d-none"
            if col == "Sample":
                sample_name = row["Sample"]
                rows_html += f'        <td data-col="{col}" class="{vis_class}"><strong>{sample_name}</strong></td>\n'
            else:
                val = row.get(col, "")
                rows_html += f'        <td data-col="{col}" class="{vis_class}">{val}</td>\n'
        rows_html += "      </tr>\n"

    # Serialize col_info for JS
    col_info_json = json.dumps(col_info)

    html = f"""
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Quality report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/datatables.net-bs5@1.13.6/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/datatables.net@1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/datatables.net-bs5@1.13.6/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.plot.ly/plotly-2.24.1.min.js"></script>
    <style>
      body {{ padding: 1.5rem; background:#f8fafc }}
      .card {{ box-shadow: 0 1px 2px rgba(0,0,0,0.06); }}
      .col-md-6 {{ margin-bottom: 1rem; }}
    </style>
  </head>
  <body>
    <div class="container-fluid">
      <div class="d-flex align-items-center mb-4">
        <h1 class="me-3">Quality Report</h1>
        <small class="text-muted">Generated from combined_summary_statistics.tsv</small>
      </div>

      <div class="row g-3 mb-4">
        <div class="col-md-6">
          <div class="card p-3">
            <h5>CheckM: Completeness</h5>
            <div id="plot_completeness"></div>
          </div>
        </div>
        <div class="col-md-6">
          <div class="card p-3">
            <h5>CheckM: Contamination</h5>
            <div id="plot_contamination"></div>
          </div>
        </div>
      </div>

      <div class="row g-3 mb-4">
        <div class="col-md-12">
          <div class="card p-3">
            <h5>Stacked: small-scale error breakdown</h5>
            <div id="plot_stacked_err"></div>
          </div>
        </div>
      </div>

      <div class="card mb-4 p-3">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h5 class="mb-0">Sample overview</h5>
          <div class="btn-group" role="group">
            <button class="btn btn-sm btn-outline-secondary" onclick="exportCSV()">Export CSV</button>
            <button class="btn btn-sm btn-outline-secondary" onclick="exportJSON()">Export JSON</button>
            <button class="btn btn-sm btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#columnModal">Columns</button>
          </div>
        </div>
        <div class="table-responsive">
          <table id="samplesTable" class="table table-sm table-striped">
            <thead>
              <tr>
{headers_html}              </tr>
            </thead>
            <tbody>
{rows_html}            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Column Visibility Modal -->
    <div class="modal fade" id="columnModal" tabindex="-1">
      <div class="modal-dialog modal-dialog-scrollable">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Column Visibility</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body" id="columnList"></div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Done</button>
          </div>
        </div>
      </div>
    </div>

    <script>
      const samples = {json.dumps(samples)};
      const completeness = {json.dumps(completeness_vals)};
      const contamination = {json.dumps(contamination_vals)};
      const base_sub = {json.dumps(base_sub)};
      const small_exp = {json.dumps(small_exp)};
      const small_col = {json.dumps(small_col)};
      const colInfo = {col_info_json};

      // Initialize DataTable
      $(document).ready(function() {{
        $('#samplesTable').DataTable({{
          paging: false,
          searching: true,
          ordering: true,
          info: false,
          columnDefs: [
            {{ targets: '_all', orderable: true }}
          ]
        }});

        // Build column visibility list
        let colHtml = '';
        Object.entries(colInfo).forEach(([col, [visible, label]]) => {{
          colHtml += `<div class="form-check">
            <input class="form-check-input col-check" type="checkbox" id="col_${{col}}" data-col="${{col}}" ${{visible ? 'checked' : ''}}>
            <label class="form-check-label" for="col_${{col}}">${{label}}</label>
          </div>`;
        }});
        document.getElementById('columnList').innerHTML = colHtml;

        // Column toggle handler
        document.querySelectorAll('.col-check').forEach(check => {{
          check.addEventListener('change', function() {{
            const col = this.dataset.col;
            const visible = this.checked;
            document.querySelectorAll(`[data-col="${{col}}"]`).forEach(el => {{
              if (visible) {{
                el.classList.remove('d-none');
              }} else {{
                el.classList.add('d-none');
              }}
            }});
          }});
        }});
      }});

      // Separate CheckM plots
      Plotly.newPlot('plot_completeness', [{{
        x: samples,
        y: completeness,
        type: 'bar',
        marker: {{ color: '#28a745' }}
      }}], {{title: '', margin:{{t:20}}}});

      Plotly.newPlot('plot_contamination', [{{
        x: samples,
        y: contamination,
        type: 'bar',
        marker: {{ color: '#dc3545' }}
      }}], {{title: '', margin:{{t:20}}}});

      // Stacked small-scale error breakdown
      Plotly.newPlot('plot_stacked_err', [
        {{ x: samples, y: base_sub, name: 'Base substitution', type: 'bar' }},
        {{ x: samples, y: small_exp, name: 'Small-scale expansion', type: 'bar' }},
        {{ x: samples, y: small_col, name: 'Small-scale collapse', type: 'bar' }}
      ], {{barmode:'stack', margin:{{t:20}}}});

      // Export functions
      function exportCSV() {{
        let csv = '';
        const table = document.getElementById('samplesTable');
        const headers = [];
        table.querySelectorAll('thead th:not(.d-none)').forEach(th => {{
          headers.push(th.textContent.trim());
        }});
        csv += headers.join(',') + '\\n';
        table.querySelectorAll('tbody tr').forEach(row => {{
          const cells = [];
          row.querySelectorAll('td:not(.d-none)').forEach(td => {{
            cells.push('"' + td.textContent.trim().replace(/"/g, '""') + '"');
          }});
          csv += cells.join(',') + '\\n';
        }});
        downloadFile(csv, 'report.csv', 'text/csv');
      }}

      function exportJSON() {{
        const table = document.getElementById('samplesTable');
        const headers = [];
        table.querySelectorAll('thead th:not(.d-none)').forEach(th => {{
          headers.push(th.textContent.trim());
        }});
        const rows = [];
        table.querySelectorAll('tbody tr').forEach(row => {{
          const obj = {{}};
          const cells = row.querySelectorAll('td:not(.d-none)');
          cells.forEach((td, i) => {{
            obj[headers[i]] = td.textContent.trim();
          }});
          rows.push(obj);
        }});
        downloadFile(JSON.stringify(rows, null, 2), 'report.json', 'application/json');
      }}

      function downloadFile(content, filename, type) {{
        const blob = new Blob([content], {{ type: type }});
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        a.click();
        URL.revokeObjectURL(url);
      }}
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  </body>
</html>
"""

    (OUTDIR / "index.html").write_text(html)


def main():
    if not TSV.exists():
        print(f"Cannot find {TSV}. Run from repository root.")
        return
    df = pd.read_csv(TSV, sep='\t')
    if 'Sample' not in df.columns:
        df = df.reset_index().rename(columns={'index': 'Sample'})
    df['Sample'] = df['Sample'].astype(str)

    make_index(df)
    print(f"Wrote report to {OUTDIR}")


if __name__ == '__main__':
    main()
