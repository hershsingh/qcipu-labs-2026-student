-- Prepend an "Open in Colab" badge to every rendered notebook page.
-- Repo/branch come from _quarto.yml metadata (colab-repo / colab-branch).
function Pandoc(doc)
  local input = (quarto and quarto.doc and quarto.doc.input_file)
                or (PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1])
  if not input or not input:match("%.ipynb$") then
    return doc
  end

  -- path relative to the project root (what GitHub/Colab expect)
  local proj = os.getenv("QUARTO_PROJECT_DIR") or ""
  local rel = input
  if #proj > 0 and input:sub(1, #proj) == proj then
    rel = input:sub(#proj + 2)
  end

  local repo   = doc.meta["colab-repo"]   and pandoc.utils.stringify(doc.meta["colab-repo"])   or ""
  local branch = doc.meta["colab-branch"] and pandoc.utils.stringify(doc.meta["colab-branch"]) or "main"
  if repo == "" then return doc end

  local url = "https://colab.research.google.com/github/" .. repo .. "/blob/" .. branch .. "/" .. rel
  local html = '<p><a href="' .. url .. '" target="_blank" rel="noopener">'
    .. '<img src="https://colab.research.google.com/assets/colab-badge.svg" '
    .. 'alt="Open in Colab"></a></p>'
  table.insert(doc.blocks, 1, pandoc.RawBlock("html", html))
  return doc
end
