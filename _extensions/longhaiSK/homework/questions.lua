-- Select and number the questions of a question bank.
--
-- A question is a header whose text starts with "Question", at the level of the
-- first such header; it runs until the next header of the same or a higher
-- level, so lower-level headers such as "### Question 2.1" are parts of it.
-- Its tags are in the header's exam attribute, separated by commas and/or spaces:
--
--   ## Question: Computing Bernoulli NLL at Extreme Log-Odds {exam="test final2026"}
--
-- With `exam: TAG` in the YAML header (or `quarto render ... -M exam:TAG`),
-- only the questions tagged TAG are kept, and the other headers at their level
-- or above (e.g. "# Normal Distribution" groupings in the bank) are dropped.
-- Without it, every question is kept.
--
-- Headers written "Question:" are numbered "Question 1:", "Question 2:", ...
-- in order of the questions kept. Headers that already carry a number, such
-- as "## Question 1.2", are left as they are.

local function split_tags(s)
  local t = {}
  for tag in s:gmatch('[^%s,]+') do t[tag] = true end
  return t
end

local function is_question(b)
  return b.t == 'Header' and pandoc.utils.stringify(b):match('^Question') ~= nil
end

-- "Question:" -> "Question n:"
local function number(h, n)
  local first = h.content[1]
  if first and first.t == 'Str' and first.text == 'Question:' then
    h.content:remove(1)
    h.content:insert(1, pandoc.Str(n .. ':'))
    h.content:insert(1, pandoc.Space())
    h.content:insert(1, pandoc.Str('Question'))
  end
  return h
end

function Pandoc(doc)
  local exam = doc.meta.exam and pandoc.utils.stringify(doc.meta.exam) or ''
  local select = exam ~= ''

  -- level of the question headers, from the first one
  local qlevel = nil
  for _, b in ipairs(doc.blocks) do
    if is_question(b) then qlevel = b.level; break end
  end

  local out = pandoc.List()
  local keep = true    -- whether the current block is kept
  local n = 0

  for _, b in ipairs(doc.blocks) do
    if is_question(b) and b.level == qlevel then
      keep = not select or split_tags(b.attributes.exam or '')[exam] == true
      if keep then
        n = n + 1
        b = number(b, n)
      end
    elseif b.t == 'Header' and qlevel and b.level <= qlevel then
      -- a header outside any question, e.g. a grouping of the bank
      keep = not select
    end
    if keep then out:insert(b) end
  end

  if select and n == 0 then
    quarto.log.warning('no question is tagged "' .. exam .. '"')
  end
  doc.blocks = out
  return doc
end
