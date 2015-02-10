module.exports =
  blacklist: [
    'id'
    'is_guide'

    'fullname'
    'email'
    'phone'
  ]
  invalid: [
    {
      errorKeys: [
        'teacher_account.username'
      ]
      form:
        teacher_account:
          'Hi there': 77
    }
    {
      errorKeys: [
        'teacher_account.username'
      ]
      form:
        teacher_account:
          password: '77'
    }
  ]
  valid: [
    {
      form:
        teacher_account:
          specialization: 's'
          username:       'username77'
          password:       'password123'
      res:
        specialization: 's'
        username:       'username77'
        password:       'password123'
    }
  ]
