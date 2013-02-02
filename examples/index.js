var express = require('express')
  , http = require('http')
  , fs = require('fs')
  , path = require('path')
  , expressSexyStatic = require('..');
var examples = fs.readdirSync(__dirname);
var app = new express()
examples.forEach(function(example){
  app.use('/' + example, expressSexyStatic(path.join(__dirname, example)));
});
app.use(expressSexyStatic(__dirname));
http.createServer(app).listen(3000);