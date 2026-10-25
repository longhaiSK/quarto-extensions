-- Select and number the questions of a homework, test or question bank.
--
-- Every level-2 header is a question and every level-3 header under it is a
-- part of it. A question runs until the next header of level 2 or 1. Its tags
-- are in the header's exam attribute, separated by commas and/or spaces:
--
--   ## Computing Bernoulli NLL at Extreme Log-Odds {exam="test final2026"}
--   ### MLE by Newton-Raphson
--
-- The headers are numbered "Question 1: ...", "Question 1.1: ...", in order of
-- the questions kept. A "Question" word or a number already at the start of a
-- header ("Question 2.3 (STAT 812 only): ...", "1.1 Midpoint rule") is replaced
-- by the new one. Headers with the class unnumbered ({-} or {.unnumbered}) are
-- left as they are and not counted.
--
-- With `exam: TAG` in the YAML header (or `quarto render ... -M exam:TAG`),
-- only the questions tagged TAG are kept, and the level-1 headers (e.g. the
-- "# Monte Carlo" groupings of a question bank) are dropped. Without it, every
-- question is kept.

local QLEVEL = 2

local function split_tags(s)
  local t = {}
  for tag in s:gmatch('[^%s,]+') do t[tag] = true end
  return t
end

-- Remove a leading "Question", "Question:", "1.2", "1.2:" or "Question 1.2:"
-- from the inlines; return what is left and whether a colon was removed.
local function strip_label(inlines)
  local rest = inlines:clone()
  local colon = false
  local function drop_space()
    while rest[1] and rest[1].t == 'Space' do rest:remove(1) end
  end
  local function take(pattern)
    local first = rest[1]
    if first and first.t == 'Str' and first.text:match(pattern) then
      colon = first.text:sub(-1) == ':'
      rest:remove(1)
      drop_space()
      return true
    end
    return false
  end
  local had_word = take('^Question:?$')
  take('^%d+[%.%d]*:?$')
  if rest[1] and rest[1].t == 'Str' and rest[1].text == ':' then
    colon = true
    rest:remove(1)
    drop_space()
  end
  return rest, colon, had_word
end

-- "Question <label>: <title>", or "Question <label> <rest>" when a header
-- starting with "Question" went on without a colon, as in
-- "Question 1.2 (STAT 812 only): ..."
local function relabel(h, label)
  local rest, colon, had_word = strip_label(h.content)
  local content = pandoc.List({ pandoc.Str('Question'), pandoc.Space() })
  if #rest == 0 then
    content:insert(pandoc.Str(label))
  elseif colon or not had_word then
    content:insert(pandoc.Str(label .. ':'))
    content:insert(pandoc.Space())
    content:extend(rest)
  else
    content:insert(pandoc.Str(label))
    content:insert(pandoc.Space())
    content:extend(rest)
  end
  h.content = content
  return h
end

local function numbered(b)
  return not b.classes:includes('unnumbered')
end

function Pandoc(doc)
  local exam = doc.meta.exam and pandoc.utils.stringify(doc.meta.exam) or ''
  local select = exam ~= ''

  local out = pandoc.List()
  local keep = true     -- whether the current block is kept
  local inq = false     -- whether the current block is inside a question
  local n, m = 0, 0     -- numbers of the current question and part

  for _, b in ipairs(doc.blocks) do
    if b.t == 'Header' and b.level == QLEVEL then
      inq = true
      keep = not select or split_tags(b.attributes.exam or '')[exam] == true
      if keep and numbered(b) then
        n, m = n + 1, 0
        b = relabel(b, tostring(n))
      end
    elseif b.t == 'Header' and b.level < QLEVEL then
      -- a header outside any question, e.g. a grouping of the bank
      inq = false
      keep = not select
    elseif b.t == 'Header' and b.level == QLEVEL + 1 and inq and keep and numbered(b) then
      m = m + 1
      b = relabel(b, n .. '.' .. m)
    end
    if keep then out:insert(b) end
  end

  if select and n == 0 then
    quarto.log.warning('no question is tagged "' .. exam .. '"')
  end
  doc.blocks = out
  return doc
end
