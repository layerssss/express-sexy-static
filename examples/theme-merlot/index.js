expressSexyStatic = require('../..');
module.exports=function(app){
  app.use('/examples/theme-merlot', expressSexyStatic(__dirname,{
    theme: 'merlot'
  }));
};