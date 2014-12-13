module.exports =
  blacklist: [
    'id'
    'courses_ids'
    'collegial_number'
    'specialization'
    'fullname'
    'email'
    'phone'
  ]
  invalid: [
    {
      errorKeys: [
        'student_account.username'
        'student_account.password'
      ]
      form:
        student_account:
          'Hi there': 77
    }
    {
      errorKeys: [
        'student_account.username'
      ]
      form:
        student_account:
          password: '77'
    }
    {
      errorKeys: [
        'student_account.password'
      ]
      form:
        student_account:
          username: 'username77'
    }
  ]
  valid: [
    {
      form:
        student_account:
          username: 'username77'
          password: 'password123'
      res:
        username: 'username77'
        password: 'password123'
    }
  ]
