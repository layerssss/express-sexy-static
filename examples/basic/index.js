var express = require('express')
  , http = require('http')
  , expressSexyStatic = require('../..');
var app = new express()
  .use(expressSexyStatic(__dirname + '/../../..'));

http.createServer(app).listen(3000);