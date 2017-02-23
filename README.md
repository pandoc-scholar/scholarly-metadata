# Panmeta

[![github release](https://img.shields.io/github/release/formatting-science/panmeta.svg?label=current+release)](https://github.com/formatting-science/panmeta/releases)
[![travis build status](https://img.shields.io/travis/formatting-science/panmeta/master.svg?style=flat-square)](https://travis-ci.org/formatting-science/panmeta)
[![license](https://img.shields.io/github/license/formatting-science/panmeta.svg?style=flat-square)](./LICENSE)

Process and normalize metadata for use with scientific articles.

Panmeta is intended to be used with [pandoc](http://pandoc.org), the universal
document converter. It consists of two parts: the module library and the
writers. Both parts are written in [lua](https://lua.org), a small scripting
language build into pandoc.

1. The modules distributed with panmeta are used to process article metadata.
   They process pure lua structures and ensure conversion of metadata into a
   canonical form suitable for the creation of documents including rich
   metadata.

2. Writer scripts are intended to be called directly from pandoc. They use
   panmeta's libraries internally and output JSON data which can be fed back
   into pandoc, or other formats related to metadata.

The most common use-case will involve only the writer scripts, but the library
scripts are available for custom writers extending the present capabilities.


## Installation

Download a release archive of the latest release using the link above. Unpack
the downloaded file to the directory in which your Markdown documents reside.

## Usage

After unpacking, there should be a directory `panmeta` in the folder. Assuming
an article is written in Markdown and stored in a file named `article.md`, the
following will canonicalize the author- and affiliation metadata and convert the
document to pandoc's JSON format:

    pandoc --to panmeta/writers/affiliations.lua -o article.enriched.json article.md

The resulting file `article.enriched.json` can be read back into pandoc to
create any output format supported by pandoc, e.g.

    pandoc --from json --to html -o article.html article.enriched.json

Note that the default pandoc templates do not support enriched metadata, leading
to unexpected output. It's hence advised to provide a custom template or produce
flattened JSON instead, using the writer in `panmeta/writers/default.lua`.


## License

This software is published under the liberal ISC license. See
the [`LICENSE`](./LICENSE) file for details.
