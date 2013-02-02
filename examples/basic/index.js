expressSexyStatic = require('../..');
module.exports=function(app){
  app.use('/basic', expressSexyStatic(__dirname));
};