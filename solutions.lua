-- Append a native <details> "Show solutions" disclosure to each lab page, read from
-- a sidecar _solutions/<same-path>.md (generated from the master by make_solutions_md.py).
-- Using <details> (not a Quarto callout) so it works regardless of filter order;
-- the code blocks inside are still syntax-highlighted by Quarto's HTML writer.
-- The .ipynb that Colab opens stays clean; solutions appear only on the website.
function Pandoc(doc)
  local input = (quarto and quarto.doc and quarto.doc.input_file)
                or (PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1])
  if not input or not input:match("%.ipynb$") then
    return doc
  end

  local proj = os.getenv("QUARTO_PROJECT_DIR") or "."
  local rel = input
  if #proj > 0 and input:sub(1, #proj) == proj then
    rel = input:sub(#proj + 2)
  end

  local sidecar = proj .. "/_solutions/" .. rel:gsub("%.ipynb$", ".md")
  local fh = io.open(sidecar, "r")
  if not fh then return doc end
  local content = fh:read("*a"); fh:close()
  if not content or content == "" then return doc end

  local extra = pandoc.read(content, "markdown").blocks
  doc.blocks:insert(pandoc.RawBlock("html",
    '<hr>\n<details class="lab-solutions">\n'
    .. '<summary style="cursor:pointer;font-weight:600;font-size:1.1em">▶ Show solutions</summary>'))
  for _, b in ipairs(extra) do
    doc.blocks:insert(b)
  end
  doc.blocks:insert(pandoc.RawBlock("html", "</details>"))
  return doc
end
