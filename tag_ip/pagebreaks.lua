-- Lua filter to add page breaks before chapters and parts
function Header(el)
  if el.level == 1 then
    -- Add page break before Part I, II, III and major sections
    return {pandoc.RawBlock('openxml', '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'), el}
  elseif el.level == 2 then
    -- Check if header contains "Chapitre" or "PARTIE"
    local text = pandoc.utils.stringify(el.content)
    if text:match("^Chapitre") or text:match("^PARTIE") then
      return {pandoc.RawBlock('openxml', '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'), el}
    end
  end
  return nil
end
