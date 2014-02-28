#{{{1 setup
dbGet = undefined
dbSet = undefined

do ->
  db = undefined
  req = indexedDB.open "keyvaluestore"
  req.onerror = (e) -> throw e
  req.onsuccess = (e) -> db = e




arrBufToStr = (arrBuf) ->
  step = 1000
  arr = new Uint8Array arrBuf
  res = []
  for i in [0..arr.length-1] by step
    res.push String.fromCharCode.apply null, [].slice.call arr, i, i+step
  res.join ""



size = 256*256

fileSelect = (e) ->
  files = []
  img = new Image()
  ctx = canvas.getContext "2d"

  t0 = Date.now()
  processFiles = (done) ->
    return done?()  if files.length == 0
    file = files.pop()
    if file.name.match /\.jpg$/i
      fr = new FileReader()
      fr.readAsArrayBuffer(file)
      fr.onload = ->
        JPEG.readExifMetaData new Blob([fr.result], {type: "image/jpeg"}), (err, data) ->
          throw err if err

          str = arrBufToStr fr.result
          url = "data:image/jpeg;base64,#{btoa str}"
          img.src = url
          img.onload = ->
            scale = Math.sqrt(size / img.width/img.height)
            w = Math.round(img.width * scale)
            h = Math.round(img.height * scale)
            canvas.width = ctx.width = w
            canvas.height = ctx.height = h
            ctx.drawImage(img,0,0,w,h)
            console.log "time:", Date.now() - t0
            t0 = Date.now()
            setTimeout (-> processFiles done), 0
    else
      setTimeout (-> processFiles done), 0

  for file in e.target.files
    files.push file
  processFiles()

document.getElementById("getfile").addEventListener "change", fileSelect
