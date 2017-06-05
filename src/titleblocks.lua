--[[
TitleBlocks – generate title components

Copyright © 2017 Albert Krewinkel

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
]]
local M = {}

local panlunatic = require "panlunatic"

local default_marks = {
  corresponding_author = panlunatic.Str "✉",
  equal_contributor = panlunatic.Str "*",
}

--- Check whether the given author is a corresponding author
local function is_corresponding_author(author)
  return author.correspondence and author.email
end

--- Create inlines for a single author (includes all author notes)
local function create_author_inline(author, get_mark)
  local author_marks = {}
  if is_corresponding_author(author) then
    author_marks[#author_marks + 1] = get_mark "corresponding_author"
  end
  if author.equal_contributor then
    author_marks[#author_marks + 1] = get_mark "equal_contributor"
  end
  for _, idx in ipairs(author.institute_indices) do
    author_marks[#author_marks + 1] = panlunatic.Str(tostring(idx))
  end
  return author.name ..
    panlunatic.Superscript(table.concat(author_marks, panlunatic.Str ","))
end

--- Create equal contributors note.
function M.create_equal_contributors_block(authors, mark)
  local has_equal_contributors = false
  for i = 1, #authors do
    if authors.equal_contributor then
      has_equal_contributors = true
    end
  end
  if has_equal_contributors then
    local mark = mark or function (mark_name) return default_marks[mark_name] end
    local contributors =
      panlunatic.Superscript(panlunatic.Str "*") ..
      panlunatic.Space() ..
      panlunatic.Str "These authors contributed equally to this work."
    return panlunatic.Para(contributors)
  else
    return nil
  end
end

--- Generate a block element containing the correspondence information
function M.create_correspondence_block(authors, mark)
  local mark = mark or function (mark_name) return default_marks[mark_name] end
  local envelope = panlunatic.Superscript(mark "corresponding_author")
  local corresponding_authors = {}
  local attr = {id = "", class = ""}
  for _, author in ipairs(authors) do
    if is_corresponding_author(author) then
      local mailto = "mailto:" .. panlunatic.decode(author.email).c
      local author_with_mail =
        author.name .. panlunatic.Space() .. panlunatic.Str "<" ..
        author.email .. panlunatic.Str ">"
      local link = panlunatic.Link(author_with_mail, mailto, "", attr)
      table.insert(corresponding_authors, link)
    end
  end
  if 0 < #corresponding_authors then
    local correspondence = panlunatic.Str "Correspondence:" .. panlunatic.Space()
    local sep = panlunatic.Str "," .. panlunatic.Space()
    return panlunatic.Para(correspondence .. table.concat(corresponding_authors, sep))
  else
    return nil
  end
end

--- Generate a list of inlines containing all authors.
function M.create_authors_inlines(authors, mark)
  local mark = mark or function (mark_name) return default_marks[mark_name] end
  local res = {}
  for i = 1, #authors do
    res[#res + 1] = create_author_inline(authors[i], mark)
  end
  local and_str = panlunatic.Space() .. panlunatic.Str "and" .. panlunatic.Space()
  if #res <= 2 then
    return table.concat(res, and_str)
  else
    local last_author = res[#res]
    res[#res] = nil
    return table.concat(res, panlunatic.Str "," .. panlunatic.Space()) ..
      panlunatic.Str "," .. and_str .. last_author
  end
end

function M.create_affiliations_block(affiliations)
  local affil_blocks = {}
  for i, affil in ipairs(affiliations) do
    affil_blocks[i] = panlunatic.Superscript(panlunatic.Str(tostring(i))) ..
      panlunatic.Space() .. affil.name
  end
  return panlunatic.Para(table.concat(affil_blocks, panlunatic.LineBreak()))
end

--- Generate a block containing all authors.
function M.create_authors_block(authors, mark)
  return panlunatic.Plain(M.create_authors_inlines(authors, mark))
end

return M
