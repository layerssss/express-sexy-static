expressSexyStatic = require('../..');
module.exports=function(app){
  app.use('/theme-merlot', expressSexyStatic(__dirname,{
    theme: 'merlot'
  }));
};