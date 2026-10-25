# quarto-extensions

Personal Quarto extensions, namespaced `longhaiSK`.

| Extension | Format | Used by |
|---|---|---|
| `profweb` | `profweb-html` | course landing pages (compstat, sampling, software, longhaiSK.github.io) |
| `custombook` | `custombook-html`, `custombook-pdf` | course books (compstat_book, sampling_book) |
| `homework` | `homework-typst`, `homework-html` | homework, tests and exams; YAML options `exam:` (select questions by tag) and `show_solutions:` |
| `banner_slides` | `banner_slides-revealjs` | course slides (compstat, sampling, Zresidual) |

Install into a project with `quarto add longhaiSK/quarto-extensions` (choose the extension),
or copy the folder from `_extensions/longhaiSK/` into the project's `_extensions/`.
Update an installed copy with `quarto update extension longhaiSK/quarto-extensions`.
