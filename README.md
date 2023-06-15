# Godot Memory

[中文](./README_ZhCN.md)

[Tutorial](https://www.youtube.com/watch?v=445NqnxvLi0)

## Preface

This is a learning project for leaping from Godot3 to Godot4, and also to solve the inconvenience in the process of switching between versions 3 and 4. Due to my limited level, there may be some poor design or bugs at present, please understand. If you have any questions, leave a message in the comment area, thank you.

## engine

- add engine
     - After **engine path** is input or selected through the file dialog box, the **version** will be automatically identified by scanning the -version command result
     - Automatically identify **terminal execution file**, enter the engine in the terminal directory, and can be started through the terminal on the list page
     - The engine can be set to **default**, set a default engine for both Godot3 and Godot4, which can be automatically filled in subsequent scan function to import projects
     - If the engine has a compiled encryption key, you can enter the encryption key, and there is a button on the list page to **one-click copy key**
     - Labeling system:
         - All the labeling systems below are implemented in the same way. Currently, the deletion of labels is not supported. **Once a label is added, the sqlite database will have a corresponding entry**. If you want to delete it, you need to delete it with the help of Sqlite management software
         - If you set a quick tag in the **Settings** column, it will be displayed in the **Quick Tab Bar**
         - For tags that have already been entered, there will be **auto-completion** after waiting for 3 seconds during the input process
         - The added label will set a **default random color**, click the color picker to **reset the color**
         - Hover the mouse over the selected tag, **show delete button**, click to **delete the tag for the engine** (the tag is still in the library, it will be queried in the auto-completion)
- Browsing engine
     - Enter the content in the **Search** box and press Enter to search according to: **version, name, desc** fuzzy search, the use of tag search is similar to that of adding an engine
     - The numbers on the far right of the search bar represent the current **number of entries under the search criteria** and the **total number of entries in the library**
     - Switching tabs will not clear the current tab status, and all content will be refreshed when the search criteria change
     - The **delete engine** function will only logically delete, **data will still remain in the database**, but it is filtered out during query (the same below)

## project

- New items
     - After the project directory is entered or selected through the directory dialog box, **automatically read the content of the godot.project** file, and identify the **project name, version, icon**
     - **Select Engine** will filter out the appropriate engine list according to the main version, and then select according to the project requirements
     - Preview image selection (the same below):
         - Support **scan** import preview, or import by **file dragging**
         - The scanning path is **all pictures in the same level directory of project.godot** and **screenshot path, and all pictures with the date of the day**
         - Select the picture by clicking with the mouse, click to confirm the selection, press and hold the left mouse button and slide the mouse to quickly select multiple pictures
         - When the mouse hovers over the picture, you can preview the picture as the original picture, and click the mouse to close the enlarged preview
         - Click the **yellow picture button** to reselect the selected picture
     - When you click **OK** to save the new project, the tool will automatically copy the selected picture to the **data/cache/img** directory at the same level as GodotMemroy, and use this as the subsequent image directory, so the original picture will be deleted will not affect the use
- browse items
     - Scan items
         - Recursively read all project.godot files under the target path, use the **default** Godot engine as the startup engine, and will not automatically set **labels or preview images**
         - In view of the fact that some early projects may have modified the project.godot file format or missing it, etc., which may cause scanning errors, **scanning may be interrupted abnormally, and the program will crash**. You can view the error content through the terminal. Currently, there are known The project does not set the project icon, the program has made a special judgment, and will use the default godot version icon as the project icon
         - The scan will **repeat the judgment based on the directory address**, and finally will use a bubble to prompt how many items have been scanned, how many duplicate items, and how many unsupported items (the default engine of godot3 godot4 is not set, and the corresponding item will not be found to be used when scanning) engine), because I don’t know how to read the version of the godot3 project, so **all godot3 projects will be judged as godot 3.5**
     - browse items
         - You can use **Switch Display** to switch between **Preview Picture** and **Project Information**. The preview picture can be enlarged and previewed by hovering the mouse, and the preview will be eliminated by clicking the same
         - The project may change, such as project name, icon, version, etc., you can click **Refresh** to re-identify (not tested yet, there may be bugs)
         - **Favorite** item, you can make the item top, and it will be sorted in the order of addition by default

## assets

- Add assets
     - There is a **link** entry in the asset, which is convenient for quickly finding the source of the asset
     - **Copyright Information** You can enter copyright content, which is convenient for collecting Credit and other purposes in the project
     - The rest of the content is the same as above
- browse assets
     - **Quick copy** copyright information in asset content

## tool

- Added tools
     - After selecting the executable file, it will automatically **scan the icon icon** under the same level directory as the tool icon, case insensitive
     - If it is not scanned, you can click the icon icon to select the corresponding icon file**
     - If the tool has no icon, the default icon will be used
- browse tools
     - bypass

## set up

- language selection
     - Currently supports switching between Chinese and English, it is best to **restart the tool** after switching
- Default startup column
     - You can set the startup column according to your own habits: engine, project, asset, tool, setting
- Set the quick label of each module according to your own needs, the usage rules are the same as above

## question

At present, a large number of input checks are missing, so don't test, **regularly back up the data folder**

If data is broken, you can fix it through sqlite tools like **SqliteStudio** or replace the backup data folder

All cached images have been verified by **md5 deduplication**. Files with the same name and same content will not be duplicated. Files with the same name and different content will be added to the cache folder in the form of the original name + uuid

## source code

You can modify it for your own use, the amount of code is relatively small, and the database table structure is relatively simple.

Hope you enojoy it like I do.
