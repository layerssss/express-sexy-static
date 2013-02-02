fs = require 'fs'
url = require 'url'
path = require 'path'
connect = require 'connect'


module.exports = (root, opt)->
  options = 
    hidden: true
    theme: 'merlot'
    types:
      '.jpg': 'image'
      '.bmp': 'image'
      '.jpeg': 'image'
      '.gif': 'image'
      '.png': 'image'
      '.tif': 'image'
      '.svg': 'image'
      '.htm': 'html'
      '.html': 'html'
      '.mht': 'html'
      '.mp4': 'vodeo'
      '.mkv': 'vodeo'
      '.rmvb': 'vodeo'
      '.wmv': 'vodeo'
      '.ogv': 'vodeo'
      '.avi': 'vodeo'
      '.mp3': 'audio'
      '.wma': 'audio'
      '.ogg': 'audio'
      '.swf': 'plugin'
      '.zip': 'package'
      '.7z': 'package'
      '.gz': 'package'
      '.tar': 'package'
      '.exe': 'executable'
      '.com': 'executable'
      '.dll': 'executable'
      '.sys': 'executable'
      '.so': 'executable'
      '.pkg': 'executable'
      '.url': 'link'
      '.css': 'text'
      '.c': 'text'
      '.cpp': 'text'
      '.txt': 'text'
      '.yml': 'text'
      '.json': 'text'
      '.h': 'text'
      '.rb': 'text'
      '.go': 'text'
      '.py': 'text'
      '.cs': 'text'
      '.s': 'text'
      '.js': 'text'
      '.coffee': 'text'
      '.iced': 'text'
      '.java': 'text'
      '.php': 'text'
      '.aspx': 'text'
      '.asp': 'text'
    icons: 
      image: '<span class="icon-pictures"></span>'
      html: '<span class="icon-file-xml"></span>'
      text: '<span class="icon-file"></span>'
      video: '<span class="icon-film"></span>'
      audio: '<span class="icon-music"></span>'
      plugin: '<span class="icon-puzzle"></span>'
      package: '<span class="icon-file-zip"></span>'
      directory: '<span class="icon-folder"></span>'
      executable: '<span class="icon-cube"></span>'
      link: '<span class="icon-share"></span>'
    defaultIcon: '<span class="icon-file"></span>'
  options[k]=v for k,v of opt
  (req, res, next)->
    console.log req.url
    await connect.static(root, options) req, res, defer err
    return next err if err
    if 0==req.url.indexOf '/sexy_assets/'
      originalUrl = req.url
      req.url = req.url.substring '/sexy_assets/'.length
      await connect.static(path.join(__dirname, 'theme'), options) req, res, defer err
      return next err if err
      req.url = originalUrl

    
    dstpath = path.join root, decodeURIComponent req.url.substring 1
    return next() if 'GET' != req.method && 'HEAD' != req.method

    await fs.exists dstpath, defer exists
    return next() if !exists
    await fs.stat dstpath, defer err, stat
    return next err if err
    return next() if !stat.isDirectory()

    await fs.readdir dstpath, defer err, files
    return next err if err
      
    files = files.filter filter if options.filter
    if options.hidden
      files = files.filter (file)->file[0]!='.'
    res.locals.items=[]
    for file in files
      await fs.stat path.join(dstpath, file), defer err, stat
      continue if err
      item = 
        basename: file
        extname: path.extname file
        stat: stat
      item.type = if stat.isDirectory() then 'directory' else options.types[item.extname.toLowerCase()]
      item.icon = options.icons[item.type]||options.defaultIcon
      res.locals.items.push item
    segs = req.url.replace(/(^\/)|(\/$)/g,'').split('/').filter((seg)->seg)

    res.locals.path_to_root = segs.map((seg)->'..').join('/')||'.'
    res.locals.path = [
      basename: '[ROOT]'
      path: res.locals.path_to_root
    ]
    for seg,i in segs
      seg =
        basename: decodeURIComponent seg
        path: ''
      while i<segs.length-1
        i++
        seg.path += '../'
      res.locals.path.push seg  
    await fs.exists path.join(__dirname, 'theme', options.theme, 'index.html.ejs'), defer exists
    if exists
      res.render path.join(__dirname, 'theme', options.theme, 'index.html.ejs')
    else
      res.render options.theme

