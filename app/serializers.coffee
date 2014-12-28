_ = require('lodash')

baseSerializer = (mongoRecord) ->
  object = if mongoRecord.toObject then mongoRecord.toObject() else mongoRecord
  serialzedRecord    = _.omit(_.clone(object), '_id', '__v')
  serialzedRecord.id = mongoRecord._id.toString() if mongoRecord._id
  serialzedRecord

accountSerializer = (account) ->
  _.omit(baseSerializer(account), 'password')

supervisorAccount = accountSerializer
recruiterAccount  = accountSerializer
studentAccount    = accountSerializer
teacherAccount    = accountSerializer
adminAccount      = accountSerializer
jobRequest        = baseSerializer
account           = accountSerializer
course            = baseSerializer
klass             = (klass) ->
  _.merge baseSerializer(klass),
    teacher_id: klass.teacher_id.toString()
    course_id:  klass.course_id.toString()

classExpanded = (c) ->
  _.merge klass(c),
    teacher: teacherAccount(c.teacher_id)
    course: course(c.course_id)
    students: c.students.map (student) ->
      studentAccount(student._id)

module.exports =
  supervisorAccount: supervisorAccount
  recruiterAccount: recruiterAccount
  studentAccount: studentAccount
  teacherAccount: teacherAccount
  adminAccount: adminAccount
  jobRequest: jobRequest
  account: accountSerializer
  course: course
  class: klass
  classExpanded: classExpanded
