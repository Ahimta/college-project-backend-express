_ = require('lodash')

baseSerializer = (mongoRecord) ->
  object = if mongoRecord.toObject then mongoRecord.toObject() else mongoRecord
  serialzedRecord    = _.omit(_.clone(object), '_id', '__v')
  serialzedRecord.id = mongoRecord._id.toString() if mongoRecord._id
  serialzedRecord

accountSerializer = (account) ->
  _.omit(baseSerializer(account), 'password')

getId = (objectOrId) ->
  if typeof objectOrId == 'string' then objectOrId
  else objectOrId?._id?.toString() || objectOrId.toString()

supervisorAccount = accountSerializer
recruiterAccount  = accountSerializer
studentAccount    = (student) ->
  if student.guide_id
    _.merge accountSerializer(student),
      guide_id: getId(student.guide_id)
  else
    accountSerializer(student)

teacherAccount    = accountSerializer
adminAccount      = accountSerializer
jobRequest        = baseSerializer
account           = accountSerializer
course            = baseSerializer
klass             = (klass) ->
  _.merge _.omit(baseSerializer(klass), 'students'),
    teacher_id: getId(klass.teacher_id) if klass.teacher_id
    course_id:  getId(klass.course_id)  if klass.course_id

classStudent = (student) ->
  studentData = studentAccount(student._id)
  studentInfo = _.pick(student, 'attendance', 'grades')
  _.merge(studentData, studentInfo)


classExpanded = (c) ->
  _.merge klass(c),
    students: c.students.map(classStudent)
    teacher:  teacherAccount(c.teacher_id) if c.teacher_id
    course:   course(c.course_id)          if c.course_id

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
  classStudent: classStudent
