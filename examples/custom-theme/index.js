var expressSexyStatic = require('../..')
  , path = require('path');
module.exports=function(app){
  app.use('/examples/custom-theme', expressSexyStatic(__dirname,{
    theme: path.join(__dirname,'clean.ejs')
  }));
};