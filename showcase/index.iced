express = require("express")
http = require("http")
fs = require("fs")
path = require("path")
expressSexyStatic = require("..")
app = new express()
for example in fs.readdirSync path.join __dirname, '..', 'examples'
  require("../examples/" + example) app  if fs.statSync(path.join(__dirname, '..', 'examples', example)).isDirectory()
for theme in fs.readdirSync path.join __dirname, '..', 'theme'
  if fs.existsSync path.join __dirname, '..', 'theme', theme, 'index.html.ejs'
    app.use '/'+theme, expressSexyStatic path.join(__dirname, 'theme'),
      theme: theme
app.use express.static __dirname
app.use expressSexyStatic path.join(__dirname, '..', 'theme'),
  theme: path.join __dirname, 'index.html.ejs'
  filter: (tf)->!(tf in ['font','icomoon.css'])
module.exports = app