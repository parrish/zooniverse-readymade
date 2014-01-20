Controller = require 'zooniverse/controllers/base-controller'
SubjectViewer = require './subject-viewer'
DecisionTree = require './decision-tree'
User = require 'zooniverse/models/user'
Subject = require 'zooniverse/models/subject'
Classification = require 'zooniverse/models/classification'

class ClassifyPage extends Controller
  className: 'classify-page'
  template: require './templates/classify-page'

  elements:
    '.classification-interface': 'interfaceContainer'
  constructor: (@steps) ->
    super null

    @subjectViewer = new SubjectViewer
    @interfaceContainer.append @subjectViewer.el

    @decisionTree = new DecisionTree @steps
    @interfaceContainer.append @decisionTree.el

    @decisionTree.on 'go-to', (e, step) =>
      @subjectViewer.setTool null

    @decisionTree.on 'answer', (e, key, value) =>
      @classification.set key, value

    @decisionTree.on 'select-tool', (e, tool, options) =>
      @subjectViewer.setTool tool, options

    @decisionTree.on 'finished-all-steps', (e) =>
      @onFinished()

    User.on 'change', (e, user) =>
      @onUserChange user

    Subject.on 'getting-next', (e, subject) =>
      @onSubjectGettingNext()

    Subject.on 'select', (e, subject) =>
      @onSubjectSelect subject

    if +location.port > 1023
      window.classifyPage = @

  onUserChange: (user) ->
    Subject.next()

  onSubjectGettingNext: ->
    @el.addClass 'loading'

  onSubjectSelect: (subject) ->
    @classification = new Classification {subject}
    @decisionTree.goTo @decisionTree.firstStep
    @subjectViewer.loadSubject subject, =>
      @el.removeClass 'loading'

  onFinished: ->
    @classification.set 'marks', @subjectViewer.getMarks()
    console.log JSON.stringify @classification
    Subject.next()

module.exports = ClassifyPage
