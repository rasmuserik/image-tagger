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



size = 150

t0 = Date.now()
time = (desc) ->
  t1 = Date.now()
  console.log desc, t1 - t0
  t0 = t1

fileSelect = (e) ->
  files = []
  img = new Image()
  ctx = canvas.getContext "2d"

  processFiles = (done) ->
    return done?()  if files.length == 0
    file = files.pop()
    if file.name.match /\.jpg$/i
      fr = new FileReader()
      fr.readAsArrayBuffer(file)
      fr.onload = ->
        time "readAsArrayBuffer"
        blob = new Blob([fr.result], {type: "image/jpeg"})
        time "newBlob"
        ok = false
        setTimeout (->
          if !ok
            console.log "timeout error, trying next", file.name
            processFiles done
        ), 20000
        JPEG.readExifMetaData blob, (err, exif) ->
          ok = true
          time "readExif"
          console.log exif.Orientation
          if err
            console.log err
            return processFiles done
          fr.readAsDataURL(blob)
          fr.onload = ->
            time "readAsDataUrl"
            img.src = fr.result
            img.onerror = (err) ->
              console.log err
              processFiles done
            img.onload = ->
              time "img.src=.."
              scale = Math.sqrt(size*size / img.width/img.height)
              w = Math.round(img.width * scale)
              h = Math.round(img.height * scale)
              canvas.width = ctx.width = w
              canvas.height = ctx.height = h
              ctx.drawImage(img,0,0,w,h)
              time "drawImage"
              thumb = canvas.toDataURL "image/jpeg", 0.8
              localforage.setItem "thumb:#{file.name}", thumb, (err) ->
                time "todataurl+savetodatabase"
                setTimeout (-> processFiles done), 0
    else
      setTimeout (-> processFiles done), 0

  for file in e.target.files
    files.push file
  processFiles()

document.getElementById("getfile").addEventListener "change", fileSelect
