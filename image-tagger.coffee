#{{{1 setup
size = 200

t0 = Date.now()
time = (desc) ->
  t1 = Date.now()
  console.log desc, t1 - t0
  t0 = t1

getMeta = (file, cb) -> #{{{1
  localforage.getItem "meta:#{file.name}", (result) ->
    return cb result if result
    ok = false
    setTimeout (-> cb null if !ok), 20000
    fr = new FileReader()
    fr.readAsArrayBuffer(file)
    fr.onload = ->
      blob = new Blob([fr.result], {type: "image/jpeg"})
      JPEG.readExifMetaData blob, (err, meta) ->
        ok = true
        meta.filename = file.name
        meta.size = file.size
        localforage.setItem "meta:#{file.name}", meta, ->
          cb meta

getThumb = (file, cb) -> #{{{1
  localforage.getItem "thumb:#{file.name}", (result) ->
    return cb result if result
    fr = new FileReader()
    cnv = document.createElement "canvas"
    ctx = cnv.getContext "2d"
    img = new Image()
    fr.readAsDataURL file
    fr.onerror = -> cb null
    fr.onload = ->
      img.src = fr.result
      img.onerror = (err) -> cb null
      img.onload = ->
        scale = Math.sqrt(size*size / img.width/img.height)
        w = Math.round(img.width * scale)
        h = Math.round(img.height * scale)
        cnv.width = ctx.width = w
        cnv.height = ctx.height = h
        ctx.drawImage(img,0,0,w,h)
        thumb = cnv.toDataURL "image/jpeg", 0.8
        localforage.setItem "thumb:#{file.name}", thumb, ->
          cb thumb

fileSelect = (e) -> #{{{1
  files = []
  img = new Image()
  ctx = canvas.getContext "2d"

  processFiles = (done) ->
    return done?()  if files.length == 0
    file = files.pop()
    if file.name.match /\.jpg$/i
      getMeta file, (meta) ->
        console.log file.name, meta
      getThumb file, (thumb) ->
        im.src = thumb
        setTimeout (-> processFiles done), 0
    else
      setTimeout (-> processFiles done), 0

  for file in e.target.files
    files.push file
  processFiles()

document.getElementById("getfile").addEventListener "change", fileSelect #{{{1
