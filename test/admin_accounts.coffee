process.env.NODE_ENV = 'test'

restricted_crud = require('./shared_specs/restricted_crud')
app             = require('../app')


describe '/api/v0/admin_accounts', ->

  restricted_crud(app, '/api/v0/admin_accounts')
    .destroy()
    .create()
    .update()
    .index()
    .show()
