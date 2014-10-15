mongoose = require('mongoose')

Schema   = mongoose.Schema

JobRequestSchema = new Schema(
  specialization: {type: String, required: true},
  fullname:       {type: String, required: true},
  address:        {type: String, required: true},
  degree:         {type: String, required: true},
  email:          {type: String, required: true},
  phone:          {type: String, required: true}
)

mongoose.model('JobRequest', JobRequestSchema)
