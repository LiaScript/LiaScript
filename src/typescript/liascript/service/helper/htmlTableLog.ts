/**
 * Minimalist function to print an array of objects as an HTML table.
 * @param data Array of objects to display
 * @param columns Optional array of column names to display (filter)
 * @param container Optional DOM element to append the table to (defaults to document.body)
 */
export function htmlTableLog(data: any, columns?: string[]): string {
  if (!Array.isArray(data) || data.length === 0) {
    return data
  }

  const allColumns = Object.keys(data[0])
  const cols =
    columns && columns.length
      ? columns.filter((c) => allColumns.includes(c))
      : allColumns
  let html = `<table style="border-collapse:collapse;border:1px solid #444;font-family:sans-serif;background:#222;box-shadow:0 2px 8px rgba(0,0,0,0.24);margin:1em 0;color:#eee;">
    <thead>
      <tr style="background:#333;">
        <th style="padding:0.5em 1em;border:1px solid #444;text-align:right;color:#fff;">#</th>`
  cols.forEach((col) => {
    html += `<th style="padding:0.5em 1em;border:1px solid #444;text-align:left;color:#fff;">${col}</th>`
  })
  html += '</tr></thead><tbody>'
  data.forEach((row, idx) => {
    html += `<tr style="border-bottom:1px solid #333;">`
    html += `<td style="padding:0.5em 1em;border:1px solid #444;text-align:right;background:#222;color:#bbb;">${
      idx + 1
    }</td>`
    cols.forEach((col) => {
      html += `<td style="padding:0.5em 1em;border:1px solid #444;text-align:left;background:#222;color:#eee;">${row[col]}</td>`
    })
    html += '</tr>'
  })
  html += '</tbody></table>'
  return html
}
