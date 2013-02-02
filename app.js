require('iced-coffee-script');
var http = require("http");
http.createServer(require('./showcase/index.iced')).listen(Number(process.env.PORT||3000));