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
        'class.code'
      ]
      form:
        class:
          'Hi there': 77
    }
    {
      errorKeys: [
        'class.teacher_id'
        'class.code'
      ]
      form:
        class:
          course_id: 'hi'
    }
    {
      errorKeys: [
        'class.course_id'
        'class.code'
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
          code:       93

          hours: 2
          room:  1
          type:  'x'
          name:  'Class X'
          day:   0

          schedule:
            from: 8
            to:   10
          semester:
            order: 1
            year:  '1436/1437'
      res:
        teacher_id: '549228e16280ba621824adee'
        course_id:  '549228e16280ba621824adea'
        code:       93

        hours: 2
        room:  1
        type:  'x'
        name:  'Class X'
        day:   0

        schedule:
          from: 8
          to:   10
        semester:
          order: 1
          year:  '1436/1437'
    }
  ]
