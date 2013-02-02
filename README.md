Sexy Static
===================

sexy static content server for express.

## Installation

npm:

    npm install express-sexy-static

## Usage

    var expressSexyStatic = require('express-sexy-static');
    app.use(new expressSexyStatic(__dirname + '/public'));

## Features

### Not just files

SexyStatic is a combinition of `connect.directory`, `connect.static` and more within a simple middleware. Just use it with:

    ```
    app.use(expressSexyStatic(__dirname + '/public'));
    ```

### View like a pro

SexyStatic is not just a static file server. It can also view documents in a friendly way.

All supported friendly views:

* images: simple preview
* html pages: preview via iframe
* text file and source code: view source via ajax
* markdown: preview single markdown file and README.md (rendered via [marked](https://github.com/chjj/marked) in browser)

### Be sexy

A few crafted <a id="themes">sexy themes<a> are shiped with SexyStatic. Try them and pick one.

    TODO list themes and previews

### Be sexy by your self

You can also define custom template for SexyStatic! To use your custom template:

1. View [an existing theme](https://github.com/pansafe/express-sexy-static/blob/master/theme/merlot/index.html.ejs) for template data reference.
2. Prepare a template (ejs/jade/.. whatever you can render in express) into your own [view path](http://expressjs.com/api.html#app-settings), and make sure it doesn't have the same name as any [existing theme](#themes)
3. Set your template name as `theme` option, then done!





