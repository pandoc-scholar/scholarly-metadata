--
-- scholarlyjsonld.lua
--
-- Copyright (c) 2017 Albert Krewinkel, Robert Winkler
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the ISC license. See LICENSE for details.

local json = require "dkjson"
local cito = require "cito"

local citation_ids = {}

local function Organizations(orgs)
  local affil_json = {}
  for i = 1, #orgs do
    affil_json[i] = {
      ["@type"] = "Organization",
      ["name"]  = orgs[i].name,
      ['url']   = orgs[i].url,
    }
  end
  return affil_json
end

local function Authors(authors)
  local authors_json = {}
  for i = 1, #authors do
    authors_json[i] = {
      ['@type']       = "Person",
      ['@id']         = authors[i].orcid and ("https://orcid.org/" .. authors[i].orcid),
      ["name"]        = authors[i].name,
      ["affiliation"] = authors[i].institute and Organizations(authors[i].institute),
      ['email']       = authors[i].email,
      ['url']         = authors[i].url,
    }
  end
  return authors_json
end

local function Cito (bibjson, cites_by_cito_property)
  function find_citation(id)
    -- sloooow
    for i = 1, #bibjson do
      if bibjson[i].id == id then
        return bibjson[i]
      end
    end
  end

  local res = {}
  local bibentry, citation_ld
  for citation_type, typed_citation_ids in pairs(cites_by_cito_property) do
    for i = 1, #typed_citation_ids do
      bibentry = find_citation(typed_citation_ids[i])
      if bibentry and bibentry.DOI then
        citation_ld = {
          ["@id"] = "http://dx.doi.org/" .. bibentry.DOI
        }
        cito_type_str = "cito:" .. citation_type
        if not res[cito_type_str] then
          res[cito_type_str] = {}
        end
        table.insert(res[cito_type_str], citation_ld)
      end
    end
  end
  return res
end

local function Citations (bibjson, citation_ids)
  function find_citation(id)
    -- sloooow
    for i = 1, #bibjson do
      if bibjson[i].id == id then
        return bibjson[i]
      end
    end
  end

  function CitationSchema(record)
    local type
    if record.type == "report" then
      type = "Report"
    elseif record.type == "article-journal" then
      type = "ScholarlyArticle"
    else
      type = "Article"
    end

    local authors = {}
    if record.author then
      for i = 1, #record.author do
        local name = {
          record.author[i].family,
          record.author[i].given
        }
        authors[i] = {
          name = table.concat(name, ", ")
        }
      end
    end

    return {
      ["@context"] = {
        ["@vocab"]    = "http://schema.org/",
        ["title"]     = "headline",
        ["page"]      = "pagination",
        ["date"]      = "datePublished",
        ["publisher"] = "publisher",
        ["author"]    = "author",
      },
      ["@type"]     = type,
      ["@id"]       = record.DOI and ("http://dx.doi.org/" .. record.DOI),
      ["title"]     = record.title,
      ["author"]    = Authors(authors),
      ["date"]      = record.issued and
        record.issued["date-parts"] and
        table.concat(record.issued["date-parts"][1], "-"),
      ["publisher"] = record.publisher and
        { ["@type"] = "Organization", ["name"] = record.publisher },
      ["page"]      = record.page,
    }
  end

  local res = {}
  for cit_id, _ in pairs(citation_ids) do
    local citation_record = find_citation(cit_id)
    if citation_record then
      res[#res + 1] = CitationSchema(citation_record)
    end
  end
  return res
end

function json_ld(meta)
  local default_image = "https://upload.wikimedia.org/wikipedia/commons/f/fa/Globe.svg"
  local accessible_for_free
  if type(meta.accessible_for_free) == "boolean" then
    accessible_for_free = meta.accessible_for_free
  else
    accessible_for_free = true
  end
  local context = {
    ["@vocab"]    = "http://schema.org/",
    ["cito"]      = "http://purl.org/spar/cito/",
    ["author"]    = "author",
    ["name"]      = "name",
    ["title"]     = "headline",
    ["subtitle"]  = "alternativeTitle",
    ["publisher"] = "publisher",
    ["date"]      = "datePublished",
    ["isFree"]    = "isAccessibleForFree",
    ["image"]     = "image",
    ["citation"]  = "citation",
  }

  local res = {
    ["@context"]  = context,
    ["@type"]     = "ScholarlyArticle",
    ["author"]    = Authors(meta.author),
    ["name"]      = meta.title,
    ["title"]     = meta.title,
    ["subtitle"]  = meta.subtitle,
    ["date"]      = meta.date or os.date("%Y-%m-%d"),
    -- ["image"]     = meta.image or default_image,
    ["isFree"]    = accessible_for_free,
    ["citation"]  = Citations(meta.bibliography_records, meta.citation_ids),
  }
  for k, v in pairs(Cito(meta.bibliography_records, meta.cito_cites)) do
    res[k] = v
  end
  return res
end

return {
  _version = "0.2.0",
  json_ld = json_ld,
}
