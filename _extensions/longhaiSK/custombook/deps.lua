-- Bundles the extension's stylesheet and scripts as an HTML dependency so
-- Quarto copies them into the output's lib folder and links them correctly.
-- Paths below are resolved relative to this filter's own directory.

-- A page is a landing page (no sidebar, centered content) when its front
-- matter sets `landing-page: true`, or by default when it is the project's
-- root index.qmd.  Set `landing-page: false` to opt out.
local function is_landing(meta)
  local opt = meta["landing-page"]
  if opt ~= nil then
    return opt == true or pandoc.utils.stringify(opt) == "true"
  end
  local input = quarto.doc.input_file
  local root = quarto.project.directory
  if not input or not root then return false end
  return pandoc.path.make_relative(input, root) == "index.qmd"
end

function Pandoc(doc)
  if quarto.doc.is_format("html") then
    quarto.doc.add_html_dependency({
      name = "custombook",
      version = "1.0.0",
      stylesheets = { "bookstyles.css" },
      scripts = { "num_eq.js", "merge-toc.js" }
    })
    if is_landing(doc.meta) then
      quarto.doc.add_html_dependency({
        name = "custombook-landing",
        version = "1.0.0",
        stylesheets = { "landing.css" }
      })
    end
  end
  return doc
end
