module.exports =
  blacklist: ['id', 'token', 'files']
  invalid: [
    {
      errorKeys: [
        'job_request.highschool_location'
        'job_request.current_location'
        'job_request.highschool_name'
        'job_request.specialization'
        'job_request.university'
        'job_request.fullname'
        'job_request.address'
        'job_request.degree'
        'job_request.id_num'
        'job_request.email'
        'job_request.phone'
        'job_request.job'
      ]
      form:
        job_request:
          'Hi there': 77
    }
    {
      errorKeys: [
        'job_request.highschool_location'
        'job_request.highschool_name'
        'job_request.current_location'
        'job_request.university'
        'job_request.id_num'
        'job_request.email'
        'job_request.job'
      ]
      form:
        job_request:
          specialization: 's'
          fullname:       'f'
          address:        'a'
          degree:         'd'
          phone:          'p'
    }
    {
      errorKeys: [
        'job_request.specialization'
        'job_request.highschool_location'
        'job_request.highschool_name'
        'job_request.current_location'
        'job_request.university'
        'job_request.id_num'
        'job_request.job'
      ]
      form:
        job_request:
          specialization: ''
          fullname:       'f'
          address:        'a'
          degree:         'd'
          email:          'aa@bb.cc'
          phone:          'p'
    }
  ]
  valid: [
    {
      form:
        job_request:
          highschool_location: 'hl'
          current_location:    'cl'
          highschool_name:     'hn'
          specialization:      's'
          university:          'u'
          fullname:            'f'
          address:             'a'
          degree:              'd'
          id_num:              'in'
          email:               'aa@bb.cc'
          phone:               'p'
          job:                 'j'
      res:
          highschool_location: 'hl'
          current_location:    'cl'
          highschool_name:     'hn'
          specialization:      's'
          university:          'u'
          fullname:            'f'
          address:             'a'
          degree:              'd'
          id_num:              'in'
          email:               'aa@bb.cc'
          phone:               'p'
          job:                 'j'

          status: 'pending'
    }
  ]
