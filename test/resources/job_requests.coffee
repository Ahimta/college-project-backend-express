module.exports = {
  "invalid": [
    {
      "errorKeys": [
        "job_request.specialization",
        "job_request.fullname",
        "job_request.address",
        "job_request.degree",
        "job_request.email",
        "job_request.phone"
      ],
      "job_request": {
        "Hi there": 77
      }
    },
    {
      "errorKeys": [
        "job_request.email"
      ],
      "job_request": {
        "specialization": "s",
        "fullname":       "f",
        "address":        "a",
        "degree":         "d",
        "email":          "e",
        "phone":          "p"
      }
    },
    {
      "errorKeys": [
        "job_request.specialization"
      ],
      "job_request": {
        "specialization": "",
        "fullname":       "f",
        "address":        "a",
        "degree":         "d",
        "email":          "aa@bb.cc",
        "phone":          "p"
      }
    }
  ],
  "valid": [
    {
      "job_request": {
        "specialization": "s",
        "fullname":       "f",
        "address":        "a",
        "degree":         "d",
        "email":          "aa@bb.cc",
        "phone":          "p"
      }
    }
  ]
}
