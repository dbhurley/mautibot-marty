ProjectContainer = require '../project/ProjectContainer'

class PermissionHandler
  constructor: (@FolderReader) ->
    @projects = new ProjectContainer

  hasPermission: (user, project) ->
    filePath = @FolderReader.getPath()

    if project != "global"
      filePath += project + "/project.json"
    else
      filePath += "projects.json"

    @searchProject filePath, project

    @projects.get(project).hasUser user

  searchProject: (path, project) ->
    if (@projects.get(project).exists)
      return true

    @createProject(path, project)

  getUsers: (project) ->
    @projects.get(project).getUsers(project)

  getStages: (project) ->
    @projects.get(project).getStages(project)

  createProject: (jsonPath, project) ->
    @projects.newProject(project, jsonPath)

module.exports = PermissionHandler