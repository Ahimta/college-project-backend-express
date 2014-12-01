module.exports =
  blacklist: ['id', 'courses_ids', 'students_ids', 'is_guide']
  invalid: [
    {
      errorKeys: [
        'teacher_account.username'
        'teacher_account.password'
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
    {
      errorKeys: [
        'teacher_account.password'
      ]
      form:
        teacher_account:
          username: 'username77'
    }
  ]
  valid: [
    {
      form:
        teacher_account:
          username: 'username77'
          password: 'password123'
      res:
        username: 'username77'
        password: 'password123'
    }
  ]
