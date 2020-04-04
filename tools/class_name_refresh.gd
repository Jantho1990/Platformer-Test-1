extends Node

const READ = 1
const READ_WRITE = 3

func _process(_delta):
    # pass
    update_project_scripts()

func update_project_scripts():
    update_directory('res://')

func update_directory(path):
    var directory = Directory.new()
    var error = directory.open(path)

    if error == OK:
        var dirPath = directory.get_current_dir()
        directory.list_dir_begin()
        var fileName = directory.get_next()
        while fileName != '':
            if directory.current_is_dir():
                update_directory(dirPath)
            elif fileName.ends_with('.gd'):
                update_script(fileName, dirPath)
            fileName = directory.get_next()

func update_script(fileName, filePath):
    var fullFilePath = filePath + '/' + fileName
    var file = File.new()
    var error = file.open(fullFilePath, READ)

    if error == OK:
        var line = file.get_next()
        var shouldContinue = file.eof_reached()
        var baseName = line.replace('extends ', '')

        while shouldContinue:
            if line.begins_with('class_name'):
                shouldContinue = false
                var className = line.replace('class_name', '')
                update_project_file(baseName, className, fullFilePath)
            line = file.get_next()
            shouldContinue = file.eof_reached()
        
    file.close()
    # get_global_class_name(fileName, filePath)

func update_project_file(baseName, className, filePath):
    var customClass = {
        "base": baseName,
        "class": className,
        "language": "GDScript",
        "path": filePath
    }
    var globalScriptClasses = get_global_script_classes()
    globalScriptClasses.push(customClass)

func get_global_script_classes():
    var projectFile = File.new()
    var error = projectFile.open('res://project.test.godot', READ)

    if error == OK:
        var line = projectFile.get_next()
        var shouldContinue = projectFile.eof_reached()
        var jsonString = ''
        var captureFileString = false

        while shouldContinue:
            if captureFileString:
                jsonString += line
                if line == '} ]':
                    captureFileString = false
                    shouldContinue = false
            elif line.begins_with('_global_script_classes='):
                captureFileString = true
                jsonString += line.replace('_global_script_classes=', '')
            line = projectFile.get_next()
            shouldContinue = projectFile.eof_reached()
        projectFile.close()
        return JSON.parse(jsonString)
    else:
        projectFile.close()

func set_global_script_classes(updatedData):
    var projectFile = File.new()
    var error = projectFile.open('res://project.test.godot', READ_WRITE)

    if error == OK:
        var fileLineArray = create_file_line_array(updatedData)
        var line = projectFile.get_next()
        var eof = projectFile.eof_reached()
        var shouldContinue = !eof
        var storeFileData = false

        while shouldContinue:
            if storeFileData:
                var nextLine = fileLineArray.pop_front()
                if !eof:
                    fileLineArray.push(line)
                projectFile.store_line(nextLine)
                if fileLineArray.count() == 0:
                    storeFileData = false
            elif line.begins_with('_global_script_classes='):
                storeFileData = true
            
            eof = projectFile.eof_reached()
            shouldContinue = !eof || storeFileData
    else:
        projectFile.close()

func create_file_line_array(arr : Array):
    var ret = []
    for item in arr:
        var itemProps = item.get_property_list()
        for prop in itemProps:
            var line = '"' + prop.name + '": "' + item[prop.name] + '"'
            ret.push(line)
    return ret