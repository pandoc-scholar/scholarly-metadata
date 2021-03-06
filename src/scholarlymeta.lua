--[[
ScholarlyMeta – normalize author/affiliation meta variables

Copyright (c) 2017 Albert Krewinkel, Robert Winkler

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
local _version = "1.0.2"
local options = {
  json_values = true
}

local panlunatic = require "panlunatic"

--- List of canonicalized metadata objects.
local MetaObjectList = {}
function MetaObjectList:new (item_class)
  local o = {item_class = item_class}
  setmetatable(o, self)
  self.__index = self
  return o
end
function MetaObjectList:init (raw_list)
  local meta_objects = {}
  setmetatable(meta_objects, self)
  self.__index = self
  if type(raw_list) == "table" then
    for i, raw_item in ipairs(raw_list) do
      meta_objects[#meta_objects + 1] = self.item_class:canonicalize(raw_item, i)
    end
    return meta_objects
  else
    meta_objects[1] = self.item_class:canonicalize(raw_list, 1)
    return meta_objects
  end
end
function MetaObjectList:map (fn)
  local res = {}
  for k, v in ipairs(self) do
    res[k] = fn(v)
  end
  return res
end
function MetaObjectList:each (fn)
  for k, v in pairs(self) do
    fn(k, v)
  end
end

--- Metadata object with a name. The name is either taken directly from the
-- `name` field, or from the *only* field name if the object is a dictionary
-- with just one entry.
local NamedObject = {}
function NamedObject:new (o)
  local o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end
function NamedObject:canonicalize (raw_item, index)
  local item = self:new{index = index}
  if type(raw_item) ~= "table" then
    -- if the object isn't a table, just use its value as a name.
    item.name = tostring(raw_item)
    item.abbreviation = tostring(raw_item)
  elseif raw_item.name ~= nil then
    -- object has name attribute → just use the object as is
    for k, v in pairs(raw_item) do
      item[k] = v
    end
  else
    -- the first entry's key is taken as the name, the value contains the
    -- attributes. Other key/value pairs are silently ignored.
    raw_name, item_attributes = next(raw_item)
    if options.json_values then
      item.name = panlunatic.Str(tostring(raw_name))
      item.abbreviation = panlunatic.Str(tostring(raw_name))
    else
      item.name = raw_name
      item.abbreviation = raw_name
    end
    if type(item_attributes) ~= "table" then
      item.name = item_attributes
    else
      for k, v in pairs(item_attributes) do
        item[k] = v
      end
    end
  end
  return item
end

--- Institutes / Affiliations
local Institute = NamedObject:new()
local Institutes = MetaObjectList:new(Institute)

--- Author
local Author = NamedObject:new()
local Authors = MetaObjectList:new(Author)
function Authors:resolve_institutes (institutes)
  function find_by_abbreviation(index)
    for _, v in pairs(institutes) do
      if v.abbreviation == index then
        return v
      end
    end
  end
  for i, author in ipairs(self) do
    if author.institute ~= nil then
      local authinst
      if type(author.institute) == "string" or type(author.institute) == "number" then
        authinst = {author.institute}
      else
        authinst = author.institute
      end
      local res = Institutes:init{}
      for j, inst in ipairs(authinst) do
        res[#res + 1] =
          institutes[tonumber(inst)] or
          find_by_abbreviation(inst) or
          Institute:canonicalize(inst)
      end
      author.institute = res
    end
  end
end

--- Insert a named object into a list; if an object of the same name exists
-- already, add all properties only present in the new object to the existing
-- item.
function insertMergeUniqueName (list, namedObj)
  for _, obj in pairs(list) do
    if obj.name == namedObj.name then
      for k, v in pairs(namedObj) do
        obj[k] = obj[k] or v
      end
      return obj
    end
  end
  list[#list + 1] = namedObj
  return namedObj
end

local function to_alpha_index(i)
  local alphabet = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
  }
  return alphabet[i]
end

local function canonicalize_authors(raw_authors, raw_institutes)
  local authors = Authors:init(raw_authors)
  local all_institutes = Institutes:init(raw_institutes)
  authors:resolve_institutes(all_institutes)

  -- ordered affiliations
  local affiliations = Institutes:init{}
  authors:each(function (_, author)
      if not author.institute then
        author.institute = Institutes:init{}
      end
      for i, authinst in ipairs(author.institute) do
        author.institute[i] = insertMergeUniqueName(affiliations, authinst)
      end
  end)
  -- add indices to affiliations
  affiliations:each(function (i, affl) affl.index = i end)
  affiliations:each(function (i, affl)
      if options.json_values then
        affl.alpha_index = panlunatic.Str(to_alpha_index(i))
      else
        affl.alpha_index = to_alpha_index(i)
      end
  end)
  authors:each(function (k, author)
      -- set institute_indices for all authors
      author.institute_alpha_indices = author.institute:map(
        function(inst) return inst.alpha_index end
      )
      author.institute_indices = author.institute:map(
        function(inst) return inst.index end
      )
  end)
  -- add additional positional information to authors
  authors[1].first_author = 1
  authors[#authors].last_author = 1
  return authors, affiliations
end

return {
  _version = _version,
  Authors = Authors,
  Institutes = Institutes,
  canonicalize_authors = canonicalize_authors,
  options = options,
}
