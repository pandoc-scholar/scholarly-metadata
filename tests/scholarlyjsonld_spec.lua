--[[
Scholarly JSON-LD test suite

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
local sjsonld = require "scholarlyjsonld"

local function example_meta ()
  return {
    author = {
      {
        name = "John Doe",
        institute = {
          name = "Starfleet",
        },
      }
    },
    institute = {
      { name = "Starfleet" }
    },
    cito_cites = {},
    citation_ids = {},
  }
end

describe("Scholarly JSON-LD", function ()
  it("specifies a version", function ()
    assert.truthy(sjsonld._version)
  end)
  it("Ensures the 'date' field is always set", function ()
    local example = example_meta()
    example["date"] = nil
    assert.truthy(sjsonld.json_ld(example)["date"])
  end)
end)
