{
  all_lines[NR] = $0
}
END {
  # First pass: calculate max column widths from actual data
  for (r = 1; r <= NR; r++) {
    if (r == 2) continue
    if (index(all_lines[r], "|") == 0) continue
    n = split(all_lines[r], fields, /\|/)
    for (i = 1; i <= n; i++) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", fields[i])
      if (length(fields[i]) > maxw[i]) maxw[i] = length(fields[i])
      if (n > ncols) ncols = n
    }
  }

  # Second pass: print formatted output
  first_data = 1
  for (r = 1; r <= NR; r++) {
    if (r == 2) continue
    if (index(all_lines[r], "|") == 0) { print all_lines[r]; continue }
    n = split(all_lines[r], fields, /\|/)
    for (i = 1; i <= n; i++) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", fields[i])
      printf "%-*s%s", maxw[i], fields[i], (i < ncols ? "  " : "\n")
    }
    if (first_data) {
      for (i = 1; i <= ncols; i++) {
        for (j = 1; j <= maxw[i]; j++) printf "-"
        printf (i < ncols ? "  " : "\n")
      }
      first_data = 0
    }
  }
}
