module.exports =
  blacklist: ['id', 'token', 'files']
  invalid: [
    {
      errorKeys: [
        'job_request.specialization'
        'job_request.fullname'
        'job_request.address'
        'job_request.degree'
        'job_request.email'
        'job_request.phone'
      ]
      form:
        job_request:
          'Hi there': 77
    }
    {
      errorKeys: [
        'job_request.email'
      ]
      form:
        job_request:
          specialization: 's'
          fullname:       'f'
          address:        'a'
          degree:         'd'
          email:          'e'
          phone:          'p'
    }
    {
      errorKeys: [
        'job_request.specialization'
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
          specialization: 's'
          fullname:       'f'
          address:        'a'
          degree:         'd'
          email:          'aa@bb.cc'
          phone:          'p'
      res:
        specialization: 's'
        fullname:       'f'
        address:        'a'
        degree:         'd'
        email:          'aa@bb.cc'
        phone:          'p'
        status: 'pending'
    }
  ]
