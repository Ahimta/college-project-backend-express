config = require('config')
router = require('express').Router()

controllersUtils = require(config.get('paths.utils') + '/controllers')
assertAdmin      = require('./concerns/middleware/authentication').assertAdmin
validator        = require('./concerns/middleware/validators').adminAccount


AdminAccount = require("#{config.get('paths.models')}/admin_account")
constructor  = require(config.get('paths.constructors')).adminAccount
serializer   = require(config.get('paths.serializers')).adminAccount

module.exports = (app) ->
  app.use('/api/v0/admin_accounts', router)

router
  .get '/', assertAdmin, (req, res, next) ->

    AdminAccount.find().exec()

      .then (accounts) ->

        res.send({admin_accounts: accounts.map(serializer)})

      .then null, controllersUtils.mongooseErr(res, next)

  .post '/', assertAdmin, validator, (req, res, next) ->

    constructor(req.form.admin_account)

      .then (persistableAccount) ->

        AdminAccount.create(persistableAccount)

      .then (account) ->

        res.status(201).send({admin_account: account})

      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id', assertAdmin, (req, res, next) ->

    AdminAccount.findById(req.params.id).exec()

      .then (account) ->

        if account
          res.send({admin_account: serializer(account)})
        else
          controllersUtils.notFound(res)

      .then null, controllersUtils.mongooseErr(res, next)

  .put '/:id', assertAdmin, validator, (req, res, next) ->

    constructor(req.form.admin_account)

      .then (persistableAccount) ->

        AdminAccount.findByIdAndUpdate(req.params.id, persistableAccount).exec()

      .then (account) ->

        if account
          res.send({admin_account: serializer(account)})
        else
          controllersUtils.notFound(res)

      .then null, controllersUtils.mongooseErr(res, next)

  .delete '/:id', assertAdmin, (req, res, next) ->

    AdminAccount.findByIdAndRemove(req.params.id).exec()

      .then (account) ->

        if account
          res.send({admin_account: account})
        else
          controllersUtils.notFound(res)

      .then null, controllersUtils.mongooseErr(res, next)


# simpleCrud(router, AdminAccount, 'admin_accounts', serializer, constructor)
#   .destroy(assertAdmin)
#   .create([assertAdmin, validator])
#   .update([assertAdmin, validator])
#   .index(assertAdmin)
#   .show(assertAdmin)
