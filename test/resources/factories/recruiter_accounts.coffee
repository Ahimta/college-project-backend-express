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
        'recruiter_account.username'
      ]
      form:
        recruiter_account:
          'Hi there': 77
    }
    {
      errorKeys: [
        'recruiter_account.username'
      ]
      form:
        recruiter_account:
          password: '77'
    }
  ]
  valid: [
    {
      form:
        recruiter_account:
          username: 'username77'
          password: 'password123'
      res:
        username: 'username77'
        password: 'password123'
    }
  ]