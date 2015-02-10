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
  ]
  valid: [
    {
      form:
        student_account:
          collegial_number: 123
          specialization:   's'
          username:         'username77'
          password:         'password123'
          level:            6
      res:
        collegial_number: 123
        specialization:   's'
        username:         'username77'
        password:         'password123'
        level:            6
    }
  ]
