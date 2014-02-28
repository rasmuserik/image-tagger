// Generated by CoffeeScript 1.6.3
(function() {
  var arrBufToStr, dbGet, dbSet, fileSelect, size;

  dbGet = void 0;

  dbSet = void 0;

  (function() {
    var db, req;
    db = void 0;
    req = indexedDB.open("keyvaluestore");
    req.onerror = function(e) {
      throw e;
    };
    return req.onsuccess = function(e) {
      return db = e;
    };
  })();

  arrBufToStr = function(arrBuf) {
    var arr, i, res, step, _i, _ref;
    step = 1000;
    arr = new Uint8Array(arrBuf);
    res = [];
    for (i = _i = 0, _ref = arr.length - 1; step > 0 ? _i <= _ref : _i >= _ref; i = _i += step) {
      res.push(String.fromCharCode.apply(null, [].slice.call(arr, i, i + step)));
    }
    return res.join("");
  };

  size = 256 * 256;

  fileSelect = function(e) {
    var ctx, file, files, img, processFiles, _i, _len, _ref;
    files = [];
    img = new Image();
    ctx = canvas.getContext("2d");
    processFiles = function(done) {
      var file, fr;
      if (files.length === 0) {
        return typeof done === "function" ? done() : void 0;
      }
      file = files.pop();
      if (file.name.match(/\.jpg$/i)) {
        fr = new FileReader();
        fr.readAsArrayBuffer(file);
        return fr.onload = function() {
          var str, t0, url;
          console.log(file);
          /*
          JPEG.readExifMetaData new Blob([fr.result], {type: "image/jpeg"}), (err, data) ->
            throw err if err
            undefined
          */

          if (true) {
            t0 = Date.now();
            str = arrBufToStr(fr.result);
            console.log(Date.now() - t0);
            t0 = Date.now();
            url = "data:image/jpeg;base64," + (btoa(str));
            console.log(Date.now() - t0);
            console.log(url);
            img.src = url;
            return img.onload = function() {
              var h, scale, w;
              scale = Math.sqrt(size / img.width / img.height);
              w = Math.round(img.width * scale);
              h = Math.round(img.height * scale);
              canvas.width = ctx.width = w;
              canvas.height = ctx.height = h;
              ctx.drawImage(img, 0, 0, w, h);
              return setTimeout((function() {
                return processFiles(done);
              }), 0);
            };
          }
        };
      } else {
        return setTimeout((function() {
          return processFiles(done);
        }), 0);
      }
    };
    _ref = e.target.files;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      file = _ref[_i];
      files.push(file);
    }
    return processFiles();
  };

  document.getElementById("getfile").addEventListener("change", fileSelect);

}).call(this);
