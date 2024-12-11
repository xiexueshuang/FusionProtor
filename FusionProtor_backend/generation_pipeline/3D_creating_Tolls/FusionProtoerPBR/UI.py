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

import bpy
import os
import bpy.utils.previews


# TEXtoPBR UI
class DATA_PT_TEXtoPBR_UI(bpy.types.Panel):
    bl_label = "FusionProtoerPBR"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = "FusionProtoerPBR"

    def draw(self, context):
        # custom icons
        pcoll = TEXtoPBR_preview_collections["main"]
        reload_textures = pcoll["reload_textures"]
        select_textures = pcoll["select_textures"]
        generate_pbr = pcoll["generate_pbr"]

        ob = context.active_object
        TEXtoPBR_channels = context.scene.textopbr_channels

        layout = self.layout.box()


        column3 = layout.column()
        column3.scale_y = 2
        row3 = column3.row(align=True)
        row3.operator('scene.load_obj_and_texture', text="Load Model and Texture", icon_value=select_textures.icon_id)
        # column3.operator('scene.textopbr_reload_material_textures', text="Reload Material Textures", icon_value=reload_textures.icon_id)

        # if ob and ob.type == 'MESH':
        # column = layout.column()
        # column.label(text=ob.name)

        # column2 = layout.column()
        # column2.scale_y = 2
        # column2.enabled = False

        # # check if channels are empty:
        # for path in context.scene.textopbr_channels.get_attrs_values():
        #     if path[1] != "" and path[1] != "//":
        #         column2.enabled = True
                
        # # scene.textopbr_generate_pbr是按钮函数的bl_idname
        # column2.operator('scene.textopbr_generate_pbr', text="Generate PBR Material", icon_value=generate_pbr.icon_id)

        # # Base Color
        # column_BC = layout.column().box() #创建一个带框的列
        # if TEXtoPBR_channels.baseColor == "":
        #     column_BC.alert = True #将box设置为警报状态
        # column_BC.label(text="Base Color")
        # column_BC.prop(TEXtoPBR_channels, property="baseColor", text="") # 在 column_BC 盒子中添加一个属性控件，用于显示和编辑 TEXtoPBR_channels 对象的 baseColor 属性。

        # # Ambient Occlusion
        # column_AO = layout.column().box()
        # if TEXtoPBR_channels.ambientOcclusion == "":
        #     column_AO.alert = True
        # column_AO.label(text="Ambient Occlusion")
        # column_AO.prop(TEXtoPBR_channels, property="ambientOcclusion", text="")

        # # Metallic
        # column_M = layout.column().box()
        # if TEXtoPBR_channels.metallic == "":
        #     column_M.alert = True
        # column_M.label(text="Metallic")
        # column_M.prop(TEXtoPBR_channels, property="metallic", text="")

        # # Roughness
        # column_R = layout.column().box()
        # if TEXtoPBR_channels.roughness == "":
        #     column_R.alert = True
        # column_R.label(text="Roughness")
        # column_R.prop(TEXtoPBR_channels, property="roughness", text="")

        # # Emission
        # column_E = layout.column().box()
        # if TEXtoPBR_channels.emission == "":
        #     column_E.alert = True
        # column_E.label(text="Emission")
        # column_E.prop(TEXtoPBR_channels, property="emission", text="")

        # # Alpha
        # column_AL = layout.column().box()
        # if TEXtoPBR_channels.alpha == "":
        #     column_AL.alert = True
        # column_AL.label(text="Alpha")
        # column_AL.prop(TEXtoPBR_channels, property="alpha", text="")

        # # Normal
        # column_N = layout.column().box()
        # if TEXtoPBR_channels.normal == "":
        #     column_N.alert = True
        # column_N.label(text="Normal")
        # column_N.prop(TEXtoPBR_channels, property="normal", text="")
        # column_FlipG = column_N.column()
        # if TEXtoPBR_channels.bumpMap:
        #     column_FlipG.enabled = False
        # column_FlipG.prop(TEXtoPBR_channels, property="normalInvertGreen", text="Invert Green Channel")
        # column_Bump = column_N.column()
        # column_Bump.prop(TEXtoPBR_channels, property="bumpMap", text="Bump Map")

        # # Height
        # column_N = layout.column().box()
        # if TEXtoPBR_channels.height == "":
        #     column_N.alert = True
        # column_N.label(text="Height")
        # column_N.prop(TEXtoPBR_channels, property="height", text="")

        # else:
        #     row = layout.row()
        #     row.label(text="Select Mesh Object!")

# 用于被继承的基类
class TEXtoPBR_settings(bpy.types.Panel):
    bl_space_type = 'PROPERTIES' # 面板将显示在“属性”区域中
    bl_region_type = 'WINDOW'
    bl_context = "scene"
    bl_options = {'DEFAULT_CLOSED'}


class SCENE_PT_textopbr(TEXtoPBR_settings):
    bl_label = "FusionProtoerPBR"

    def draw(self, context):
        pass


class SCENE_PT_textopbr_image_extensions(TEXtoPBR_settings):
    bl_label = "Image Extensions"
    bl_parent_id = "SCENE_PT_textopbr"

    def draw(self, context):
        TEXtoPBR_settings = bpy.context.scene.textopbr_settings

        layout = self.layout.box()
        row = layout.row()
        row.label(text="Image Extensions")
        row = layout.row()
        row.prop(TEXtoPBR_settings, property='image_extensions', text="")


class SCENE_PT_textopbr_baseColor(TEXtoPBR_settings):
    bl_label = "Base Color"
    bl_parent_id = "SCENE_PT_textopbr"

    def draw(self, context):
        TEXtoPBR_settings = bpy.context.scene.textopbr_settings

        layout = self.layout.box()
        row = layout.row()
        row.label(text="Base Color")
        row = layout.row()
        row.prop(TEXtoPBR_settings, property='base_color', text="")
        row = layout.row(align=True)
        row.operator('scene.textopbr_add_suffix', text="Add Suffix").action = "BASE_COLOR"
        row.operator('scene.textopbr_remove_suffix', text="Remove Suffix").action = "BASE_COLOR"


# class SCENE_PT_textopbr_ambientOcclusion(TEXtoPBR_settings):
#     bl_label = "Ambient Occlusion"
#     bl_parent_id = "SCENE_PT_textopbr"

#     def draw(self, context):
#         TEXtoPBR_settings = bpy.context.scene.textopbr_settings

#         layout = self.layout.box()
#         row = layout.row()
#         row.label(text="Ambient Occlusion")
#         row = layout.row()
#         row.prop(TEXtoPBR_settings, property='ambient_occlusion', text="")
#         row = layout.row(align=True)
#         row.operator('scene.textopbr_add_suffix', text="Add Suffix").action = "AMBIENT_OCCLUSION"
#         row.operator('scene.textopbr_remove_suffix', text="Remove Suffix").action = "AMBIENT_OCCLUSION"


class SCENE_PT_textopbr_metallic(TEXtoPBR_settings):
    bl_label = "Metallic"
    bl_parent_id = "SCENE_PT_textopbr"

    def draw(self, context):
        TEXtoPBR_settings = bpy.context.scene.textopbr_settings

        layout = self.layout.box()
        row = layout.row()
        row.label(text="Metallic")
        row = layout.row()
        row.prop(TEXtoPBR_settings, property='metallic', text="")
        row = layout.row(align=True)
        row.operator('scene.textopbr_add_suffix', text="Add Suffix").action = "METALLIC"
        row.operator('scene.textopbr_remove_suffix', text="Remove Suffix").action = "METALLIC"


class SCENE_PT_textopbr_roughness(TEXtoPBR_settings):
    bl_label = "Roughness"
    bl_parent_id = "SCENE_PT_textopbr"

    def draw(self, context):
        TEXtoPBR_settings = bpy.context.scene.textopbr_settings

        layout = self.layout.box()
        row = layout.row()
        row.label(text="Roughness")
        row = layout.row()
        row.prop(TEXtoPBR_settings, property='roughness', text="")
        row = layout.row(align=True)
        row.operator('scene.textopbr_add_suffix', text="Add Suffix").action = "ROUGHNESS"
        row.operator('scene.textopbr_remove_suffix', text="Remove Suffix").action = "ROUGHNESS"


# class SCENE_PT_textopbr_emission(TEXtoPBR_settings):
#     bl_label = "Emission"
#     bl_parent_id = "SCENE_PT_textopbr"

#     def draw(self, context):
#         TEXtoPBR_settings = bpy.context.scene.textopbr_settings

#         layout = self.layout.box()
#         row = layout.row()
#         row.label(text="Emission")
#         row = layout.row()
#         row.prop(TEXtoPBR_settings, property='emission', text="")
#         row = layout.row(align=True)
#         row.operator('scene.textopbr_add_suffix', text="Add Suffix").action = "EMISSION"
#         row.operator('scene.textopbr_remove_suffix', text="Remove Suffix").action = "EMISSION"


# class SCENE_PT_textopbr_alpha(TEXtoPBR_settings):
#     bl_label = "Alpha"
#     bl_parent_id = "SCENE_PT_textopbr"

#     def draw(self, context):
#         TEXtoPBR_settings = bpy.context.scene.textopbr_settings

#         layout = self.layout.box()
#         row = layout.row()
#         row.label(text="Alpha")
#         row = layout.row()
#         row.prop(TEXtoPBR_settings, property='alpha', text="")
#         row = layout.row(align=True)
#         row.operator('scene.textopbr_add_suffix', text="Add Suffix").action = "ALPHA"
#         row.operator('scene.textopbr_remove_suffix', text="Remove Suffix").action = "ALPHA"


class SCENE_PT_textopbr_normal(TEXtoPBR_settings):
    bl_label = "Normal"
    bl_parent_id = "SCENE_PT_textopbr"

    def draw(self, context):
        TEXtoPBR_settings = bpy.context.scene.textopbr_settings

        layout = self.layout.box()
        row = layout.row()
        row.label(text="Normal")
        row = layout.row()
        row.prop(TEXtoPBR_settings, property='normal', text="")
        row = layout.row(align=True)
        row.operator('scene.textopbr_add_suffix', text="Add Suffix").action = "NORMAL"
        row.operator('scene.textopbr_remove_suffix', text="Remove Suffix").action = "NORMAL"


class SCENE_PT_textopbr_height(TEXtoPBR_settings):
    bl_label = "Height"
    bl_parent_id = "SCENE_PT_textopbr"

    def draw(self, context):
        TEXtoPBR_settings = bpy.context.scene.textopbr_settings

        layout = self.layout.box()
        row = layout.row()
        row.label(text="Height")
        row = layout.row()
        row.prop(TEXtoPBR_settings, property='height', text="")
        row = layout.row(align=True)
        row.operator('scene.textopbr_add_suffix', text="Add Suffix").action = "HEIGHT"
        row.operator('scene.textopbr_remove_suffix', text="Remove Suffix").action = "HEIGHT"


TEXtoPBR_preview_collections = {}


def register():
    # bpy.utils.previews用于存储和管理自定义图标和图像
    pcoll = bpy.utils.previews.new()

    absolute_path = os.path.dirname(__file__)
    relative_path = "icons"
    path = os.path.join(absolute_path, relative_path)

    pcoll.load("reload_textures", os.path.join(path, "reload_textures.png"), 'IMAGE')
    pcoll.load("select_textures", os.path.join(path, "select_textures.png"), 'IMAGE')
    pcoll.load("generate_pbr", os.path.join(path, "generate_pbr.png"), 'IMAGE')
    TEXtoPBR_preview_collections["main"] = pcoll

    bpy.utils.register_class(DATA_PT_TEXtoPBR_UI)
    bpy.utils.register_class(SCENE_PT_textopbr)
    bpy.utils.register_class(SCENE_PT_textopbr_image_extensions)
    bpy.utils.register_class(SCENE_PT_textopbr_baseColor)
    bpy.utils.register_class(SCENE_PT_textopbr_metallic)
    bpy.utils.register_class(SCENE_PT_textopbr_roughness)
    # bpy.utils.register_class(SCENE_PT_textopbr_emission)
    # bpy.utils.register_class(SCENE_PT_textopbr_alpha)
    bpy.utils.register_class(SCENE_PT_textopbr_normal)
    # bpy.utils.register_class(SCENE_PT_textopbr_height)
    # bpy.utils.register_class(SCENE_PT_textopbr_ambientOcclusion)


def unregister():
    for pcoll in TEXtoPBR_preview_collections.values():
        bpy.utils.previews.remove(pcoll)
    TEXtoPBR_preview_collections.clear()

    bpy.utils.unregister_class(DATA_PT_TEXtoPBR_UI)
    bpy.utils.unregister_class(SCENE_PT_textopbr)
    bpy.utils.unregister_class(SCENE_PT_textopbr_image_extensions)
    bpy.utils.unregister_class(SCENE_PT_textopbr_baseColor)
    bpy.utils.unregister_class(SCENE_PT_textopbr_metallic)
    bpy.utils.unregister_class(SCENE_PT_textopbr_roughness)
    # bpy.utils.unregister_class(SCENE_PT_textopbr_emission)
    # bpy.utils.unregister_class(SCENE_PT_textopbr_alpha)
    bpy.utils.unregister_class(SCENE_PT_textopbr_normal)
    # bpy.utils.unregister_class(SCENE_PT_textopbr_height)
    # bpy.utils.unregister_class(SCENE_PT_textopbr_ambientOcclusion)
