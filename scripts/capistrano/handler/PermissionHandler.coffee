ProjectContainer = require '../project/ProjectContainer'

class PermissionHandler
  constructor: (@FolderReader) ->
    @projects = new ProjectContainer

  hasPermission: (user, project) ->
    filePath = @FolderReader.getPath()

    if project != "global"
      filePath += project

    @searchProject filePath, project

    @projects.get(project).hasUser user

  searchProject: (path, project) ->
    if (@projects.get(project).exists)
      return true

    @createProject(path, project)

  getUsers: (project) ->
    @projects.get(project).getUsers(project)

  createProject: (path, project) ->
    jsonPath = "#{path}/project.json"

    @projects.newProject(project, jsonPath)

module.exports = PermissionHandler