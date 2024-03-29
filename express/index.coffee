require './lib/passport_integration'
passport = require 'passport'
express = require 'express'
{join} = require 'path'
{config} = require './config'
controllers = require './controllers'
albums = require('./models/albums')
api_getcollection = require('./controllers/api/getcollection')
#User = require('./models')('user')

app = express()
app.configure 'production', ->
  app.use express.limit '5mb'

app.configure ->
  app.set 'views', join __dirname, 'views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.compress()
  app.use express.cookieParser(config.cookie.secret)
  app.use express.session({
    secret: "test",
    cookie: {httpOnly: true}
  })
  #app.use(passport.initialize())
  #app.use(passport.session())

  app.use express.csrf()
  app.use((req, res, next) ->
    res.cookie('_csrf', req.csrfToken())
    next()
  )
  app.use app.router
  app.use express.static join __dirname, '..', 'public'

app.configure 'development', ->
  app.use express.errorHandler()
  app.locals.pretty = true

app.get('/api/getsongs/:album_id', api_getcollection.getsongs)
app.get('/api/getcollection', api_getcollection.get)
app.get('/api/getartists/:artist_id', api_getcollection.getartist)
app.get('/api/getalbum/:album_id', api_getcollection.getalbum)

#app.get('/login', controllers.login)
#app.post('/login',
#  passport.authenticate('local', {
#    failureFlash: true
#  })
#)

app.get(/^[^.]+$/, (req, res) ->
  res.sendfile('./public/index.html')
)

#Assign the model to express variable
app.use (req, res, next) ->
  req.albums = albums
  next()
  return

# Set angular controllers references
#app.get '/', controllers.landing()
app.get '/collection', controllers.collection()
app.get '/test', controllers.test('Mocha Tests')
app.get '/user', controllers.user('User')
app.get '/practice', controllers.practice('Practice your HTML')



### Default 404 middleware ###
app.use controllers.error('Page not found :(', 404)

module.exports = exports = app
