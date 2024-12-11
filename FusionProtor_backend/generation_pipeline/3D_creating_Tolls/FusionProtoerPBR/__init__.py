# ##### BEGIN GPL LICENSE BLOCK #####
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software Foundation,
#  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# ##### END GPL LICENSE BLOCK #####

bl_info = {
    "name": "FusionProtoerPBR",
    "author": "Refinity",
    "version": (1, 0),
    "blender": (3, 4, 0),
    "location": "View3D > Sidebar > FusionProtoerPBR",
    "description": "Textures To PBR Material in 1 Click",
    "category": "FusionProtoerPBR",
}

import bpy
import sys
import importlib
from bpy.props import StringProperty

modulesNames = ["UI", "FusionProtoerPBR"]

modulesFullNames = {}

# 构建完整模块名称并存储在字典中, e.g.:
# modulesFullNames = {
#     "UI": "FusionProtoerPBR.UI",
#     "FusionProtoerPBR": "FusionProtoerPBR.FusionProtoerPBR"
# }

for moduleName in modulesNames:
    modulesFullNames[moduleName] = ('{}.{}'.format(__name__, moduleName))

# 遍历 modulesFullNames 字典的值（完整模块名称）。
# 如果模块已在 sys.modules 中加载，则重新加载模块。
# 如果模块未加载，则导入模块并将其添加到全局命名空间。
# 将 modulesNames 字典作为属性添加到导入的模块中。e.g. FusionProtoerPBR.UI.modulesNames = modulesFullNames
for currentModuleFullName in modulesFullNames.values():
    if currentModuleFullName in sys.modules:
        importlib.reload(sys.modules[currentModuleFullName])
    else:
        globals()[currentModuleFullName] = importlib.import_module(currentModuleFullName)
        setattr(globals()[currentModuleFullName], 'modulesNames', modulesFullNames)

# 插件的首选项类
class FusionProtoerPBR_Preferences(bpy.types.AddonPreferences):
    bl_idname = __package__  # bl_idname 是一个特殊的属性，用于唯一标识 Blender 操作符、面板、菜单等。它通常用于注册和取消注册 Blender 插件中的类。 将 bl_idname 设置为包名 FusionProtoerPBR

    filepath: StringProperty(
        name="文件路径",
        subtype='FILE_PATH',
        default="/Users/jiangzhaoqu/Desktop/FusionProtoerPBR/example/"
    )

    def draw(self, context):
        layout = self.layout
        row = layout.row()
        row.prop(self, 'filepath')
        row = layout.row()
        row.operator('wm.url_open', text="Contact Us", icon='QUESTION').url = "mailto:zhaoqujiang@zju.edu.cn"



def register():
    for currentModuleName in modulesFullNames.values():
        if currentModuleName in sys.modules:
            if hasattr(sys.modules[currentModuleName], 'register'):
                sys.modules[currentModuleName].register()

    bpy.utils.register_class(FusionProtoerPBR_Preferences)


def unregister():
    for currentModuleName in modulesFullNames.values():
        if currentModuleName in sys.modules:
            if hasattr(sys.modules[currentModuleName], 'unregister'):
                sys.modules[currentModuleName].unregister()

    bpy.utils.unregister_class(FusionProtoerPBR_Preferences)


if __name__ == "__main__":
    register()
