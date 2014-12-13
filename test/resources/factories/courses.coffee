module.exports =
  blacklist: [
    'id'
  ]
  invalid: [
    {
      errorKeys: [
        'course.code'
        'course.name'
      ]
      form:
        course:
          'Hi there': 77
    }
    {
      errorKeys: [
        'course.code'
      ]
      form:
        course:
          name: 'hi'
    }
    {
      errorKeys: [
        'course.name'
      ]
      form:
        course:
          'code': 'CS50x'
    }
  ]
  valid: [
    {
      form:
        course:
          code: 'CS50x'
          name: 'Introduction to Computer Science I'
      res:
        code: 'CS50x'
        name: 'Introduction to Computer Science I'
    }
  ]
