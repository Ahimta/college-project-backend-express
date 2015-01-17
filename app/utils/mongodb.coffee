mongoose = require('mongoose')
config   = require('config')
logger   = require config.get('paths.logger')
_        = require('lodash')
Q        = require('q')

AccessToken = require(config.get('paths.models') + '/access_token')
security    = require('./security')

ACCOUNTS_MODELS =
  supervisor: require(config.get('paths.models') + '/supervisor_account')
  recruiter:  require(config.get('paths.models') + '/recruiter_account')
  student:    require(config.get('paths.models') + '/student_account')
  teacher:    require(config.get('paths.models') + '/teacher_account')
  admin:      require(config.get('paths.models') + '/admin_account')

modelForRole = module.exports.modelForRole = (role) ->
  Q.Promise (resolve, reject, notify) ->
    model = ACCOUNTS_MODELS[role]

    if model then resolve(model)
    else reject new Error('Model not found for role ' + role)


authenticate = (role, username, password) ->

  modelForRole(role)
    .then (model) ->
      model.findOne({username: username.toLowerCase()}).exec()
    .then (account) ->
      if account
        security.comparePasswords(password, account.password)
          .then (__) -> account.toObject()
      else
        throw new Error("user with username: '#{username}' not found")


exports.assertAccessToken = (accessToken, role=null, userId=null) ->
  query           = {access_token: accessToken}
  query.user_role = role   if role
  query.user_id   = userId if userId

  Q(AccessToken.findOne(query).exec()).then (tokenRecord) ->
    throw new Error('Access token not found') unless tokenRecord

    modelForRole(tokenRecord.user_role).then (accountModel) ->
      accountModel.findOne({_id: tokenRecord.user_id}).exec().then (accountRecord) ->
        tokenObject: tokenRecord.toObject()
        account:     accountRecord.toObject()

###*
 * Ensures the user is authorized according to the given credentials
 * @export
 * @param   {Array.<{accountRole: string, accountId: ?string}>} [credentials=[]]
 * @param   {string} accessToken
 * @returns {Promise}
 ###
exports.assertAuthorized = _.curry (credentials=[], accessToken) ->
  query0 = {access_token: accessToken}
  query1 = credentials.map (credential) ->
    user_role: credential.accountRole
    user_id:   credential.accountId
  query = {$and: [query0, {$or: query1}]}

  AccessToken.findOne(query).exec().then (tokenRecord) ->
    if tokenRecord
      accountRole: tokenRecord.user_role
      accoundId:   tokenRecord.user_id
    else
      throw new Error('Access token not found')

exports.login = (role, username, password) ->

  authenticate(role, username, password).then (account) ->
    security.generateSecureToken().then (token) ->
      record =
        access_token: token
        user_role:    role
        user_id:      account._id

      AccessToken.create(record).then (tokenRecord) ->
        accessToken: tokenRecord.access_token
        accountRole: role
        account:     account
