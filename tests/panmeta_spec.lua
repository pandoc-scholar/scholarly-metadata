--[[
Panluna test suite

Copyright (c) 2017 Albert Krewinkel

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
package.path = package.path .. ";../src/?.lua"
local panmeta = require "panmeta"
setmetatable(_G, {__index = panmeta})

describe("Panmeta", function ()
  it("specifies a version", function ()
    assert.truthy(panmeta._version)
  end)
  it("canonicalizes a list of authors", function ()
       local orig_authors = {"John Doe", "Jane Doe"}
       local authors, affiliations =
         panmeta.canonicalize_authors(orig_authors)
       assert.is.same(
         authors,
         {
           { name = "John Doe",
             abbreviation = "John Doe",
             index = 1,
             first_author = 1,
             institute = {},
             institute_indices = {},
             institute_alpha_indices = {},
           },
           { name = "Jane Doe",
             abbreviation = "Jane Doe",
             index = 2,
             last_author = 1,
             institute = {},
             institute_indices = {},
             institute_alpha_indices = {},
           }
         }
       )
  end)
  it("canonicalizes a list of authors with institutes", function ()
    panmeta.options.json_values = false
    local orig_authors = {
      {["Jean–Luc Picard"] = { institute = "enterprise" }},
      {["Benjamin Sisko"] = { institute = "ds9" }}
    }
    local orig_institutes = {
      {enterprise = "USS Enterprise NCC-1701-D"},
      {ds9 = "Deep Space 9"},
    }
    local authors, affiliations =
      panmeta.canonicalize_authors(orig_authors, orig_institutes)
    assert.is.same(
      {
        { name = "Jean–Luc Picard",
          abbreviation = "Jean–Luc Picard",
          index = 1,
          first_author = 1,
          institute = {{
              name = "USS Enterprise NCC-1701-D",
              abbreviation = "enterprise",
              index = 1,
              alpha_index = 'a',
          }},
          institute_indices = { 1 },
          institute_alpha_indices = { 'a' },
        },
        { name = "Benjamin Sisko",
          abbreviation = "Benjamin Sisko",
          index = 2,
          last_author = 1,
          institute = {{
            name = "Deep Space 9",
            abbreviation = "ds9",
            index = 2,
            alpha_index = 'b',
          }},
          institute_indices = { 2 },
          institute_alpha_indices = { 'b' },
        }
      },
      authors
    )
  end)
end)
