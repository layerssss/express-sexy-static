var express = require('express')
  , http = require('http')
  , fs = require('fs')
  , path = require('path')
  , expressSexyStatic = require('..');
var examples = fs.readdirSync(__dirname);
var app = new express()
examples.forEach(function(example){
  if(fs.statSync(path.join(__dirname, example)).isDirectory()){
    require('./'+example)(app);
  }
});
app.use(expressSexyStatic(__dirname));
http.createServer(app).listen(3000);