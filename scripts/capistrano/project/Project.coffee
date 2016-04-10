cjson = require 'cjson'

class Project
  constructor: (@name, @jsonPath, @exists = true) ->
    @users  = []
    @stages = []

    @parseConfig()

    setInterval(
      =>
        @parseConfig()
      1000
    )

  hasUser: (user) ->
    user in @users

  getUsers: ->
    @users.join ', '

  getStages: ->
    @stages.join ', '

  parseConfig: ->
    if @jsonPath
      json = cjson.load @jsonPath
      @users = json.users
      @stages = json.stages

module.exports = Project