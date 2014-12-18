module.exports =
  blacklist: [
    'id'
    'students'
  ]
  invalid: [
    {
      errorKeys: [
        'class.teacher_id'
        'class.course_id'
      ]
      form:
        class:
          'Hi there': 77
    }
    {
      errorKeys: [
        'class.teacher_id'
      ]
      form:
        class:
          course_id: 'hi'
    }
    {
      errorKeys: [
        'class.course_id'
      ]
      form:
        class:
          teacher_id: '549228e16280ba621824adee'
    }
  ]
  valid: [
    {
      form:
        class:
          teacher_id: '549228e16280ba621824adee'
          course_id: '549228e16280ba621824adea'
      res:
        teacher_id: '549228e16280ba621824adee'
        course_id: '549228e16280ba621824adea'
    }
  ]
