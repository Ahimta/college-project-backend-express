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
        'class.hours'
        'class.type'
        'class.name'
        'class.day'
      ]
      form:
        class:
          'Hi there': 77
    }
    {
      errorKeys: [
        'class.teacher_id'
        'class.hours'
        'class.type'
        'class.name'
        'class.day'
      ]
      form:
        class:
          course_id: 'hi'
    }
    {
      errorKeys: [
        'class.course_id'
        'class.hours'
        'class.type'
        'class.name'
        'class.day'
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
          course_id:  '549228e16280ba621824adea'
          hours:      2
          type:       'x'
          name:       'Class X'
          day:        'y'
      res:
        teacher_id: '549228e16280ba621824adee'
        course_id:  '549228e16280ba621824adea'
        hours:      2
        type:       'x'
        name:       'Class X'
        day:        'y'
    }
  ]
