gulp =                  require "gulp"
browserSync =           require "browser-sync"
reload =                browserSync.reload
watch =                 require "gulp-watch"
rimraf =                require "rimraf"
pug =                   require "gulp-pug"
stylus =                require "gulp-stylus"
autoprefixer =          require "gulp-autoprefixer"
nib =                   require "nib"
notify =                require "gulp-notify"
plumber =               require "gulp-plumber"
util =                  require "gulp-util"
uglify =                require "gulp-uglify"
sequence =              require "run-sequence"
coffee =                require "gulp-coffee"
jsdoc =                 require "gulp-jsdoc3"
sourcemaps =            require "gulp-sourcemaps"
environments =          require "gulp-environments"
w3cjs =                 require "gulp-w3cjs"

dev = environments.development
prod = environments.production
moduleName = process.cwd().slice(process.cwd().lastIndexOf('/')+1, process.cwd().toString().length)
packageName = require("./package.json").name

onError = (err) ->
  util.beep()
  util.log util.colors.red err
  notify.onError(err.plugin)(err)

gulp.task "browserSync", ->
  browserSync
    server:
      baseDir: "./"
      directory: true
    logPrefix: moduleName
    logConnections: true
    startPath: "./dist/index.html"
    port: 1717
    ui:
      port: 1718
    ghostMode:
      clicks: true
      forms: true
      scroll: true
    online: false
    notify: false
    open: true
    xip: false
    reloadDelay: 800

gulp.task "pug", ->
  rimraf "./dist/*.html", ->
    gulp.src "./src/*.pug"
    .pipe plumber errorHandler: onError
    .pipe dev sourcemaps.init()
    .pipe dev pug
      pretty: true
      locals:
        moduleName: moduleName
        packageName : packageName
    .pipe dev sourcemaps.write()
    .pipe prod pug
      pretty: false
      locals:
        moduleName: moduleName
        packageName : packageName
    .pipe w3cjs()
    .pipe gulp.dest "./dist"
    .pipe reload stream: true

gulp.task "styl", ->
  rimraf "./dist/*.css", ->
    gulp.src "./src/*.styl"
    .pipe plumber errorHandler: onError
    .pipe dev sourcemaps.init()
    .pipe dev stylus use: nib(), linenos: true
    .pipe prod stylus use: nib(), linenos: false, compress: true
    .pipe autoprefixer browsers: "last 4 versions"
    .pipe gulp.dest "./dist"
    .pipe reload stream: true

gulp.task "coffee", ->
  rimraf "./dist/*.js", ->
    gulp.src "./src/*.coffee", read: true
    .pipe plumber errorHandler: onError
    .pipe dev sourcemaps.init()
    .pipe coffee()
    .pipe dev sourcemaps.write()
    .pipe prod uglify()
    .pipe gulp.dest "./dist"
    .pipe reload stream: true

gulp.task "doc", ->
  rimraf "./docs", ->
    gulp.src './dist/*.js', {read: false}
    .pipe plumber errorHandler: onError
    .pipe jsdoc()
    .pipe reload stream: true

gulp.task "watch", ->
  watch "./src/*.pug", ->
    gulp.start "pug"
    reload
  watch "./src/*.styl", ->
    gulp.start "styl"
    reload
  watch "./src/*.coffee", ->
    gulp.start "coffee"
    reload

gulp.task "default", ->
  sequence [
    "styl"
    "coffee"
  ], "pug", "browserSync", "watch"