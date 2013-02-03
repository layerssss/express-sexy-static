express = require("express")
http = require("http")
fs = require("fs")
path = require("path")
expressSexyStatic = require("..")
marked = require 'marked'
app = new express()
for example in fs.readdirSync path.join __dirname, '..', 'examples'
  require("../examples/" + example) app  if fs.statSync(path.join(__dirname, '..', 'examples', example)).isDirectory()

app.use '/examples', expressSexyStatic path.join __dirname, '..', 'examples'

for theme in fs.readdirSync path.join __dirname, '..', 'theme'
  if fs.existsSync path.join __dirname, '..', 'theme', theme, 'index.html.ejs'
    app.use '/'+theme, expressSexyStatic path.join(__dirname, 'theme'),
      theme: theme

app.use express.static __dirname
app.use (req, res, next)->
  res.locals.README =  marked fs.readFileSync path.join(__dirname, '..', 'README.md'), 'utf8'
  next()
app.use expressSexyStatic path.join(__dirname, '..', 'theme'),
  theme: path.join __dirname, 'index.html.ejs'
  filter: (tf)->!(tf in ['fonts','icomoon.css'])
module.exports = app