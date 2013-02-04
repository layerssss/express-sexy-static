fs = require 'fs'
url = require 'url'
path = require 'path'
send = require 'send'
querystring = require 'querystring'
spawn = require('child_process').spawn


simpleStatic = (root, opt)->
  options =
    index: false
  options[k] = v for k,v of opt
  (req, res, next)->
    directory = ->
      pathname = url.parse(req.originalUrl).pathname
      if pathname.match /\/$/
        return next()
      res.statusCode = 301
      res.setHeader "Location", pathname + "/"
      res.end "Redirecting to " + escape(pathname) + "/"
    await send(req, url.parse(req.url).pathname).maxage(options.maxAge or 0).root(root).hidden(options.hidden).index(options.index).on("directory", directory).on("error", defer err).pipe(res)
    return next err if err.status!=404
    next()

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
      '.md': 'markdown'
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
      markdown: '<span class="icon-file"></span>'
    defaultIcon: '<span class="icon-file"></span>'
  options[k]=v for k,v of opt

  (req, res, next)->
    return next()  if "GET" isnt req.method and "HEAD" isnt req.method
    await simpleStatic(root) req, res, defer err
    return next err if err
    if 0==req.url.indexOf '/sexy_assets/'
      originalUrl = req.url
      req.url = req.url.substring '/sexy_assets/'.length
      await simpleStatic(path.join(__dirname, '..', 'theme'), options) req, res, defer err
      return next err if err
      req.url = originalUrl

    
    request = url.parse req.url
    request.query = querystring.parse request.query if request.query

    dstpath = path.join root, decodeURIComponent request.pathname.substring 1
    

    await fs.exists dstpath, defer exists
    return next() if !exists
    await fs.stat dstpath, defer err, stat
    return next err if err
    return next() if !stat.isDirectory()

    if request.query && request.query.download=='zip'
      zip = spawn("zip", ["-rj", "-", dstpath])
      res.contentType "application/x-zip"
      basename = dstpath.split '/'
      basename = basename[basename.length-1]||'root'
      res.setHeader 'Content-Disposition', "attachment; filename=\"#{basename}.zip\""
      # Keep writing stdout to res
      zip.stdout.on "data", (data) ->
        res.write data
      # zip.stderr.on "data", (data) ->
      #   console.error data.toString 'utf8'
      # End the response on zip exit
      zip.on "exit", (code) ->
        if code isnt 0
          res.statusCode = 500
          console.log "zip process exited with code " + code
          res.end()
        else
          res.end()
      return
    if request.query && request.query.download=='tgz'
      tar = spawn "tar", ["-cz", "."], 
        cwd: dstpath
      res.type "application/x-tgz"
      basename = dstpath.split '/'
      basename = basename[basename.length-1]||'root'
      res.setHeader 'Content-Disposition', "attachment; filename=\"#{basename}.tar.gz\""
      # Keep writing stdout to res
      tar.stdout.on "data", (data) ->
        res.write data
      # tar.stderr.on "data", (data) ->
      #   console.error data.toString 'utf8'
      # End the response on tar exit
      tar.on "exit", (code) ->
        if code isnt 0
          res.statusCode = 500
          console.log "tar process exited with code " + code
          res.end()
        else
          res.end()
      return

    await fs.readdir dstpath, defer err, files
    return next err if err
      
    files = files.filter options.filter if options.filter
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
    segs = request.pathname.replace(/(^\/)|(\/$)/g,'').split('/').filter((seg)->seg)

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
    await fs.exists path.join(__dirname, '..', 'theme', options.theme, 'index.html.ejs'), defer exists
    if exists
      res.render path.join(__dirname, '..', 'theme', options.theme, 'index.html.ejs')
    else
      res.render options.theme

