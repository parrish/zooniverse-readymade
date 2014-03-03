Api = require 'zooniverse/lib/api'
TopBar = require 'zooniverse/controllers/top-bar'
SiteHeader = require './site-header'
StackOfPages = require 'stack-of-pages'
homePageTemplate = require './templates/home-page'
ClassifyPage = require './classify-page'
teamPageTemplate = require './templates/team-page'
User = require 'zooniverse/models/user'

class Project
  parent: document.body
  id: ''

  producer: ''
  title: ''
  summary: ''
  description: ''

  tasks: null
  firstTask: ''

  organizations: null
  scientists: null
  developers: null

  constructor: (configuration = {}) ->
    for property, value of configuration
      @[property] = value

    if @id
      @connect @id

    @header = new SiteHeader
      template: SiteHeader::template @

    @stack = new StackOfPages
    @stack.el.className += ' readymade-main-stack'

    if @summary or @description
      @addPage '#/', 'Home', homePageTemplate @

    if @tasks?
      @addPage '#/classify', 'Classify', new ClassifyPage
        stepSpecs: @tasks
        firstStep: @firstTask

    if @organizations or @scientists or @developers
      @addPage '#/team', 'Team', teamPageTemplate @

    @header.el.appendTo @parent if @parent?
    @parent?.appendChild @stack.el

    @stack.onHashChange()

    if +location.port > 1023
      window.zooniverseReadymadeProject = @

    User.fetch()

  connect: (project) ->
    @api = new Api {project}
    @topBar = new TopBar
    @topBar.el.appendTo document.body

  addPage: (href, label, content) ->
    @stack.add href, content
    @header.addNavLink href, label

module.exports = Project
