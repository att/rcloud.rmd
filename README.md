
# ![](inst/rcloud.rmd.png)

## Install

1. Install this package on RCloud, using `devtools::install_github()`,
   or `install-github.me`:
   ```R
   source("https://install-github.me/att/rcloud.rmd")
   ```
2. In the RCloud *Settings* menu, in the *Enable Extensions* line, add
   `rcloud.rmd`, so that the package is loaded automatically.
3. Reload RCloud in the browser. This loads the package, and you should
   have the *Import Rmarkdown file* and *Export Rmarkdown file* items added
   int the *Advanced* menu on the top.

## Usage

### In RCloud

Choose the *Import Rmarkdown file* item from the *Advanced* menu and
then select the file to import from your computer.

### In R Studio

`rcloud.rmd` contains an RStudio addin, that can be used to export R Markdown
files from RStudio to RCloud.

1. Open the R Markdown file in RStudio, and then select the
   *Export to RCloud notebook* item from the *Addins* menu.
2. This will open a new tab or window in your default browser, with a form.
   Select or type in the URL of your RCloud installation, and click on *Export*.
   The browser will load RCloud, with the newly created RCloud notebook. If you
   are not logged in to RCloud, then before the notebook is added you will need
   to log in, the usual way.

If used from RStudio, the package also needs the `jsonlite`, `rstudioapi` and
`whisker` packages to be installed.

### Conversion details

The text chunks of the `Rmd` will be converted to `markdown` cells in the
RCLoud notebook. The code chunks will be imported as `R` cells. If the `Rmd`
file has a YAML header, that is converted to a `markdown` cell as well.

Chunk headers are parsed and inserted into the code chunk they refer to,
as R comments. When exporting the notebook from RCloud to R Markdown, these
will be converted back to proper chunk options. While chunk options are kept,
they are not interpreted by the converter in any way.

The title of the `Rmd` document will be used as the name of the new notebook.
If it does not have a title, then its file name is used.

## Developer notes

### The `Rmd` parser

The parser currently uses internal functions from the `knitr` package to
parse the `Rmd` file. Unfortunately there is no publicly available, supported
`Rmd` parser that returns the parsed document as an object.

The advantage of the current implementation is that is will always be compatible
with `knitr`, which has the de-facto standard `Rmd` parser. The downside is that
we are using internal functions, and their API is subject to change without
notice.

One alternative to this would be writing a parser from scratch, but that would
require extensive testing to make sure that it is equivalent to the `knitr`
parser.

Another alternative is copying the current `knitr` implementation into the
`rcloud.rmd` package. This is unfortunately technically difficult, because
the parser is using non-pure functions, and a global state in `knitr`.

### The RStudio Addin

The addin is relatively straightforward, the most difficult part is the HTTP
submission and its authentication.

We currently use a static HTML web page, and a static JS file (`submit.js`),
created by the addin. The JS file contains the JSON version of the Rmd
already.

Doing a form submission instead of a proper HTTP POST API call has the advantage
that we can use the token from the user's browser to authenticate to RCloud.
With a proper API call, the user would have to handle the token manually,
although apart this hurdle, this way is technically superior, and probably
should be used in the future.

The list of RCloud URLs is currently built into the app. For a better solution
and storing the previously used URLs locally on the client, we would need to
use a proper Shiny app instead of a static HTML page. A previous version of the
addin did use a Shiny app indeed, this is here in git:
https://github.com/att/rcloud.rmd/commit/0cd1a560c2e2d2a1fbd74880f056dc9ee3abc710

See the next subsection for the server-side part of the notebook submission.

### The RCLoud API

The `htdocs/api.R` file contains the code for the `/api.R/create` endpoint
that implements the server side of the notebook submission. This is a POST
request, and if the user is logged in, then the token/cookie automatically
submitted by the browser is enough to authenticate the request, and the
notebook can be created right away.

If the user is not logged in, then the situation is tricker, because we
need to redirect them to the login page, which invokes more redirects to GitHub,
potentially. The `login.R` page can redirect to another page after a successful
login, so we ask it to redirect back to the `/api.R/create` page. These
redirects lose the POSTed notebooks, of course. So if the user is not logged in,
then before performing the redirects, we store the notebook in a temporary
file, where the file name is the digest of the file. We pass this token as a
query parameter to `login.R`, and we will get it back at the end of the redirect
chain. Then we get retrieve the submitted file using the token, and create the
notebook.
