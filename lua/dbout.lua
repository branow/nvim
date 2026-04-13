local M = {}

local state = {}
local ns    = vim.api.nvim_create_namespace('dbout_status')

-- ── State ──────────────────────────────────────────────────────────────────

local function get_buf_state(bufnr)
  if not state[bufnr] then
    state[bufnr] = {
      original_lines        = nil,
      table_states          = {},
      rendered_table_ranges = {},
    }
  end
  return state[bufnr]
end

local function get_table_state(bs, tidx)
  if not bs.table_states[tidx] then
    bs.table_states[tidx] = {
      sort_col_name   = nil,
      sort_asc        = true,
      filter_col_name = nil,
      filter_val      = nil,
      pinned          = {},
    }
  end
  return bs.table_states[tidx]
end

-- ── Column helpers ─────────────────────────────────────────────────────────

local function parse_cols(sep_line)
  local cols = {}
  local i    = 1
  while i <= #sep_line do
    while i <= #sep_line and sep_line:sub(i, i) ~= '-' do i = i + 1 end
    if i > #sep_line then break end
    local start = i
    while i <= #sep_line and sep_line:sub(i, i) == '-' do i = i + 1 end
    cols[#cols + 1] = { start = start, stop = i - 1 }
  end
  return cols
end

local function col_at(cols, pos)
  local result = 1
  for i, col in ipairs(cols) do
    if pos >= col.start then result = i end
  end
  return result
end

local function extract(line, cols, idx)
  local from = cols[idx].start
  local to   = cols[idx + 1] and (cols[idx + 1].start - 1) or #line
  if from > #line then return '' end
  return vim.trim(line:sub(from, math.min(to, #line)))
end

-- ── Segment parser ─────────────────────────────────────────────────────────
-- Splits buffer lines into { type='text', lines } and
-- { type='table', header_line, sep_line, data_lines } segments.
-- Table detection: lines[i] is non-empty + not starting with '-',
-- and lines[i+1] starts with '---'.

local function parse_segments(lines)
  local segments = {}
  local i        = 1

  while i <= #lines do
    if i < #lines
      and lines[i]:match('%S')
      and not lines[i]:match('^%-')
      and lines[i + 1]:match('^%-+')
    then
      -- Table segment
      local header_line = lines[i]
      local sep_line    = lines[i + 1]
      local data_lines  = {}
      local j           = i + 2

      while j <= #lines do
        local l = lines[j]
        if l:match('^%s*$') then break end
        -- Stop if next pair looks like a new table header+sep
        if j < #lines
          and l:match('%S')
          and not l:match('^%-')
          and lines[j + 1]:match('^%-+')
        then break end
        data_lines[#data_lines + 1] = l
        j = j + 1
      end

      segments[#segments + 1] = {
        type        = 'table',
        header_line = header_line,
        sep_line    = sep_line,
        data_lines  = data_lines,
      }
      i = j

    else
      -- Text segment: collect until next table start
      local text_lines = {}
      while i <= #lines do
        local is_table = i < #lines
          and lines[i]:match('%S')
          and not lines[i]:match('^%-')
          and lines[i + 1]:match('^%-+')
        if is_table then break end
        text_lines[#text_lines + 1] = lines[i]
        i = i + 1
      end
      if #text_lines > 0 then
        segments[#segments + 1] = { type = 'text', lines = text_lines }
      end
    end
  end

  return segments
end

-- ── Rendering ──────────────────────────────────────────────────────────────

local function set_lines(bufnr, lines)
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
end

local update_indicators  -- forward declaration

-- Render one table segment with table state ts applied; return lines.
local function render_table(seg, ts)
  ts = ts or {}
  local pinned = ts.pinned or {}

  local cols    = parse_cols(seg.sep_line)
  local headers = {}
  for i = 1, #cols do
    headers[i] = extract(seg.header_line, cols, i)
  end

  local rows = {}
  for _, line in ipairs(seg.data_lines) do
    local row = {}
    for i = 1, #cols do row[i] = extract(line, cols, i) end
    rows[#rows + 1] = row
  end

  -- Apply filter
  if ts.filter_col_name and ts.filter_val then
    local ci = nil
    for i, h in ipairs(headers) do
      if h == ts.filter_col_name then ci = i; break end
    end
    if ci then
      local fv = ts.filter_val
      rows = vim.tbl_filter(function(r) return (r[ci] or '') == fv end, rows)
    end
  end

  -- Apply sort
  if ts.sort_col_name then
    local ci = nil
    for i, h in ipairs(headers) do
      if h == ts.sort_col_name then ci = i; break end
    end
    if ci then
      local asc   = ts.sort_asc ~= false
      local rows2 = vim.deepcopy(rows)
      table.sort(rows2, function(a, b)
        local va, vb = a[ci] or '', b[ci] or ''
        local na, nb = tonumber(va), tonumber(vb)
        if na and nb then return asc and na < nb or na > nb end
        return asc and va < vb or va > vb
      end)
      rows = rows2
    end
  end

  -- Column order: pinned columns first, then the rest
  local col_order  = {}
  local pinned_set = {}
  for _, name in ipairs(pinned) do
    for i, h in ipairs(headers) do
      if h == name and not pinned_set[i] then
        col_order[#col_order + 1] = i
        pinned_set[i] = true
        break
      end
    end
  end
  for i = 1, #headers do
    if not pinned_set[i] then col_order[#col_order + 1] = i end
  end

  -- Compute max column widths
  local maxw = {}
  for _, ci in ipairs(col_order) do
    maxw[ci] = #headers[ci]
    for _, row in ipairs(rows) do
      local w = #(row[ci] or '')
      if w > maxw[ci] then maxw[ci] = w end
    end
  end

  -- Extra width for indicator extmarks (display cells, not bytes)
  -- [N]=3, ' ▲'/' ▼'=2, ' ◉'=2
  for _, ci in ipairs(col_order) do
    local h   = headers[ci]
    local pad = 0
    for _, name in ipairs(pinned) do
      if name == h then pad = pad + 3; break end
    end
    if ts.sort_col_name   == h then pad = pad + 2 end
    if ts.filter_col_name == h then pad = pad + 2 end
    maxw[ci] = maxw[ci] + pad
  end

  local function fmt(getter)
    local parts = {}
    for _, ci in ipairs(col_order) do
      parts[#parts + 1] = string.format('%-' .. maxw[ci] .. 's', getter(ci))
    end
    return vim.trim(table.concat(parts, '  '))
  end

  local out = {
    fmt(function(ci) return headers[ci] end),
    fmt(function(ci) return string.rep('-', maxw[ci]) end),
  }
  for _, row in ipairs(rows) do
    out[#out + 1] = fmt(function(ci) return row[ci] or '' end)
  end
  return out
end

-- Rebuild the entire buffer from original_lines + current table states.
local function render_buffer(bufnr)
  local bs = get_buf_state(bufnr)
  if not bs.original_lines then return end

  local segs   = parse_segments(bs.original_lines)
  local result = {}
  local ranges = {}
  local tidx   = 0

  for _, seg in ipairs(segs) do
    if seg.type == 'text' then
      vim.list_extend(result, seg.lines)
    else
      tidx = tidx + 1
      local tlines   = render_table(seg, bs.table_states[tidx])
      local start_ln = #result + 1
      vim.list_extend(result, tlines)
      ranges[tidx] = {
        header     = start_ln,
        sep        = start_ln + 1,
        data_start = start_ln + 2,
        data_end   = #result,
      }
    end
  end

  bs.rendered_table_ranges = ranges
  set_lines(bufnr, result)
  update_indicators(bufnr)
end

-- Place sort/filter/pin indicators on header lines via extmarks.
update_indicators = function(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  local bs = state[bufnr]
  if not bs then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for tidx, range in pairs(bs.rendered_table_ranges or {}) do
    local ts = bs.table_states[tidx]
    if ts then
      local sep_ln = lines[range.sep]
      local hdr_ln = lines[range.header]
      if sep_ln and hdr_ln then
        local cols    = parse_cols(sep_ln)
        local hdr_row = range.header - 1  -- 0-indexed for nvim_buf_set_extmark

        for i = 1, #cols do
          local col_name = extract(hdr_ln, cols, i)
          local parts    = {}

          for pin_pos, name in ipairs(ts.pinned or {}) do
            if name == col_name then
              parts[#parts + 1] = { '[' .. pin_pos .. ']', 'DiagnosticHint' }
              break
            end
          end
          if ts.sort_col_name == col_name then
            parts[#parts + 1] = { ts.sort_asc and ' ▲' or ' ▼', 'DiagnosticWarn' }
          end
          if ts.filter_col_name == col_name then
            parts[#parts + 1] = { ' ◉', 'DiagnosticError' }
          end

          if #parts > 0 then
            local byte_pos = cols[i].start - 1 + #col_name
            vim.api.nvim_buf_set_extmark(bufnr, ns, hdr_row, byte_pos, {
              virt_text     = parts,
              virt_text_pos = 'overlay',
            })
          end
        end
      end
    end
  end
end

-- Return (tidx, range, cursor) for the table containing the cursor, or nil.
local function get_cursor_table(bufnr)
  local bs     = get_buf_state(bufnr)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cur_ln = cursor[1]

  for tidx, range in pairs(bs.rendered_table_ranges or {}) do
    if cur_ln >= range.header and cur_ln <= range.data_end then
      return tidx, range, cursor
    end
  end
  return nil, nil, cursor
end

-- Capture original_lines and initialize rendered_table_ranges on first op.
local function ensure_original(bufnr, bs)
  if not bs.original_lines then
    bs.original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local segs = parse_segments(bs.original_lines)
    local lnum = 0
    local tidx = 0
    for _, seg in ipairs(segs) do
      if seg.type == 'table' then
        tidx = tidx + 1
        bs.rendered_table_ranges[tidx] = {
          header     = lnum + 1,
          sep        = lnum + 2,
          data_start = lnum + 3,
          data_end   = lnum + 2 + #seg.data_lines,
        }
        lnum = lnum + 2 + #seg.data_lines
      else
        lnum = lnum + #seg.lines
      end
    end
  end
end

-- ── Public API ─────────────────────────────────────────────────────────────

function M.sort()
  local bufnr = vim.api.nvim_get_current_buf()
  local bs    = get_buf_state(bufnr)
  ensure_original(bufnr, bs)

  local tidx, range, cursor = get_cursor_table(bufnr)
  if not tidx then vim.notify('No table under cursor', vim.log.levels.WARN); return end

  local lines    = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cols     = parse_cols(lines[range.sep])
  local col_name = extract(lines[range.header], cols, col_at(cols, cursor[2] + 1))

  local ts = get_table_state(bs, tidx)
  if ts.sort_col_name == col_name then
    ts.sort_asc = not ts.sort_asc
  else
    ts.sort_col_name = col_name
    ts.sort_asc      = true
  end

  render_buffer(bufnr)
  vim.notify('Sorted by ' .. col_name .. (ts.sort_asc and ' ▲' or ' ▼'))
end

function M.filter()
  local bufnr = vim.api.nvim_get_current_buf()
  local bs    = get_buf_state(bufnr)
  ensure_original(bufnr, bs)

  local tidx, range, cursor = get_cursor_table(bufnr)
  if not tidx then vim.notify('No table under cursor', vim.log.levels.WARN); return end

  if cursor[1] <= range.sep then
    vim.notify('Move cursor to a data row', vim.log.levels.WARN); return
  end

  local lines      = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cols       = parse_cols(lines[range.sep])
  local col_idx    = col_at(cols, cursor[2] + 1)
  local col_name   = extract(lines[range.header], cols, col_idx)
  local filter_val = extract(lines[cursor[1]], cols, col_idx)

  if filter_val == '' then vim.notify('No value under cursor', vim.log.levels.WARN); return end

  local ts = get_table_state(bs, tidx)
  ts.filter_col_name = col_name
  ts.filter_val      = filter_val

  render_buffer(bufnr)

  local new_range = bs.rendered_table_ranges[tidx]
  local row_count = new_range and math.max(0, new_range.data_end - new_range.data_start + 1) or 0
  vim.notify('Filter: ' .. col_name .. ' = "' .. filter_val .. '" — ' .. row_count .. ' rows')
end

function M.clear()
  local bufnr = vim.api.nvim_get_current_buf()
  local bs    = state[bufnr]
  if not bs or not bs.original_lines then vim.notify('Nothing to clear'); return end

  local tidx = get_cursor_table(bufnr)
  if tidx then
    bs.table_states[tidx] = nil
    render_buffer(bufnr)
    vim.notify('Cleared')
  else
    bs.table_states = {}
    render_buffer(bufnr)
    vim.notify('Cleared all')
  end
end

function M.clear_sort()
  local bufnr = vim.api.nvim_get_current_buf()
  local bs    = state[bufnr]
  if not bs or not bs.original_lines then vim.notify('Nothing to clear'); return end

  local tidx, range, cursor = get_cursor_table(bufnr)
  if not tidx then vim.notify('No table under cursor', vim.log.levels.WARN); return end

  local ts = bs.table_states[tidx]
  if not ts or not ts.sort_col_name then vim.notify('No sort active'); return end

  local lines    = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cols     = parse_cols(lines[range.sep])
  local col_name = extract(lines[range.header], cols, col_at(cols, cursor[2] + 1))

  if ts.sort_col_name ~= col_name then
    vim.notify('"' .. col_name .. '" is not sorted (sorted by: ' .. ts.sort_col_name .. ')', vim.log.levels.WARN)
    return
  end

  ts.sort_col_name = nil
  ts.sort_asc      = true
  render_buffer(bufnr)
  vim.notify('Sort cleared')
end

function M.clear_filter()
  local bufnr = vim.api.nvim_get_current_buf()
  local bs    = state[bufnr]
  if not bs or not bs.original_lines then vim.notify('Nothing to clear'); return end

  local tidx, range, cursor = get_cursor_table(bufnr)
  if not tidx then vim.notify('No table under cursor', vim.log.levels.WARN); return end

  local ts = bs.table_states[tidx]
  if not ts or not ts.filter_col_name then vim.notify('No filter active'); return end

  local lines    = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cols     = parse_cols(lines[range.sep])
  local col_name = extract(lines[range.header], cols, col_at(cols, cursor[2] + 1))

  if ts.filter_col_name ~= col_name then
    vim.notify('"' .. col_name .. '" is not filtered (filtered by: ' .. ts.filter_col_name .. ')', vim.log.levels.WARN)
    return
  end

  ts.filter_col_name = nil
  ts.filter_val      = nil
  render_buffer(bufnr)
  vim.notify('Filter cleared')
end

function M.pin_col()
  local bufnr = vim.api.nvim_get_current_buf()
  local bs    = get_buf_state(bufnr)
  ensure_original(bufnr, bs)

  local tidx, range, cursor = get_cursor_table(bufnr)
  if not tidx then vim.notify('No table under cursor', vim.log.levels.WARN); return end

  local lines    = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cols     = parse_cols(lines[range.sep])
  local col_name = extract(lines[range.header], cols, col_at(cols, cursor[2] + 1))

  local ts = get_table_state(bs, tidx)
  for _, name in ipairs(ts.pinned) do
    if name == col_name then vim.notify('"' .. col_name .. '" already pinned'); return end
  end

  ts.pinned[#ts.pinned + 1] = col_name
  render_buffer(bufnr)
  vim.notify('Pinned: ' .. col_name .. ' (position ' .. #ts.pinned .. ')')
end

function M.unpin_col()
  local bufnr = vim.api.nvim_get_current_buf()
  local bs    = get_buf_state(bufnr)
  if not bs.original_lines then return end

  local tidx, range, cursor = get_cursor_table(bufnr)
  if not tidx then vim.notify('No table under cursor', vim.log.levels.WARN); return end

  local lines    = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cols     = parse_cols(lines[range.sep])
  local col_name = extract(lines[range.header], cols, col_at(cols, cursor[2] + 1))

  local ts = get_table_state(bs, tidx)
  local found = false
  for i, name in ipairs(ts.pinned) do
    if name == col_name then table.remove(ts.pinned, i); found = true; break end
  end

  if not found then vim.notify('"' .. col_name .. '" is not pinned'); return end
  render_buffer(bufnr)
  vim.notify('Unpinned: ' .. col_name)
end


-- ── Column navigation ──────────────────────────────────────────────────────

local function jump_col(delta)
  local bufnr             = vim.api.nvim_get_current_buf()
  local tidx, range, cursor = get_cursor_table(bufnr)
  if not tidx then return end

  local lines  = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cols   = parse_cols(lines[range.sep])
  local cur_ci = col_at(cols, cursor[2] + 1)  -- cursor[2] is 0-indexed
  local count  = vim.v.count1
  local new_ci = math.max(1, math.min(#cols, cur_ci + delta * count))

  -- Preserve relative offset within the source column, clamped to new col width
  local offset    = (cursor[2] + 1) - cols[cur_ci].start   -- 0-based within col
  local col_width = cols[new_ci].stop - cols[new_ci].start  -- width in bytes
  local new_byte  = cols[new_ci].start - 1 + math.min(offset, col_width)

  vim.api.nvim_win_set_cursor(0, { cursor[1], new_byte })
end

function M.next_col() jump_col(1)  end
function M.prev_col() jump_col(-1) end

-- ── Cleanup ────────────────────────────────────────────────────────────────

vim.api.nvim_create_autocmd('BufDelete', {
  callback = function(ev) state[ev.buf] = nil end,
})

return M
