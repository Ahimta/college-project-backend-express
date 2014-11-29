module.exports =
  blacklist: ['id']
  invalid: [
    {
      errorKeys: [
        'supervisor_account.username'
        'supervisor_account.password'
      ]
      form:
        supervisor_account:
          'Hi there': 77
    }
    {
      errorKeys: [
        'supervisor_account.username'
      ]
      form:
        supervisor_account:
          password: '77'
    }
    {
      errorKeys: [
        'supervisor_account.password'
      ]
      form:
        supervisor_account:
          username: 'username77'
    }
  ]
  valid: [
    {
      form:
        supervisor_account:
          username: 'username77'
          password: 'password123'
      res:
        username: 'username77'
        password: 'password123'
    }
  ]
