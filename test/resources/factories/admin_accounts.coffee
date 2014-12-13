module.exports =
  blacklist: [
    'id'
    'fullname'
    'email'
    'phone'
  ]
  invalid: [
    {
      errorKeys: [
        'admin_account.username'
        'admin_account.password'
      ]
      form:
        admin_account:
          'Hi there': 77
    }
    {
      errorKeys: [
        'admin_account.username'
      ]
      form:
        admin_account:
          password: '77'
    }
    {
      errorKeys: [
        'admin_account.password'
      ]
      form:
        admin_account:
          username: 'username77'
    }
  ]
  valid: [
    {
      form:
        admin_account:
          username: 'username77'
          password: 'password123'
      res:
        username: 'username77'
        password: 'password123'
    }
  ]
