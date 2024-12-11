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
import addon_utils
import json
import os


# custom function to load json data path
def get_json_data_path():
    for mod in addon_utils.modules():
        if mod.bl_info['name'] == "FusionProtoerPBR":
            path = mod.__file__.rstrip("__init__.py")
            path = (path + 'data.json')
            return path

class SCENE_OT_fusionProtoer_load_obj_and_textures(bpy.types.Operator):
    """Load Obj Model and its Texture To Create PBR Material"""
    bl_idname = "scene.load_obj_and_texture"
    bl_label = "Load Obj Model and its Texture"
    bl_options = {'UNDO', 'INTERNAL'}

    directory: bpy.props.StringProperty(subtype='DIR_PATH')

    @classmethod
    def poll(cls, context):
        return context.mode == 'OBJECT'

    def invoke(self, context, event):

        # empty channels
        context.scene.textopbr_channels.baseColor = ""
        context.scene.textopbr_channels.metallic = ""
        context.scene.textopbr_channels.roughness = ""
        context.scene.textopbr_channels.normal = ""

        # get json data file
        jsonfile = context.scene.textopbr_settings.json_data_path

        # import extensions from json data file
        with open(jsonfile, "r") as f:
            data = json.load(f)
            extensions = data['extensions']
            baseColor = data['baseColor']
            metallic = data['metallic']
            roughness = data['roughness']
            normal = data['normal']

        obj_loaded = False

        # 手动指定的文件路径
        work_dir = context.preferences.addons["FusionProtoerPBR"].preferences.filepath
        self.directory = work_dir
        os.chdir(work_dir)


        # Iterate through all files in the directory
        obj_files = [f for f in os.listdir(self.directory) if f.lower().endswith('.obj')]
        texture_files = [f for f in os.listdir(self.directory) if any(f.lower().endswith(ext) for ext in extensions)]

        for obj_file in obj_files:
            obj_path = os.path.join(self.directory, obj_file)
            bpy.ops.wm.obj_import(filepath=obj_path)
            obj_name = bpy.path.display_name_from_filepath(obj_path)
            obj = bpy.context.selected_objects[0]
            obj.name = obj_name

            # Create a new material
            mat = bpy.data.materials.new(name=f"{obj_name}_Material")
            mat.use_nodes = True

            
            # references
            nodeTree = mat.node_tree
            nodes = nodeTree.nodes
            links = nodeTree.links

            # mix node
            mixNode = None

            # constants
            x = -800
            y = 500
            marginX = 300
            marginY = 300

            # create texture coordinate for uv mapping
            texCoord = nodes.new(type='ShaderNodeTexCoord')
            texCoord.location = (x - 600, y)

            # create mapping node
            mappingNode = nodes.new(type='ShaderNodeMapping')
            mappingNode.location = (x - 400, y)
            links.new(texCoord.outputs['UV'], mappingNode.inputs['Vector'])

            # current blender version
            version = bpy.app.version_string

            # decide which node to use based on blender version
            oldVersion = False
            if int(version[0]) < 3 or (int(version[2]) < 4 and int(version[0]) <= 3):
                oldVersion = True

            # Assign the material to the object
            if obj.data.materials:
                obj.data.materials[0] = mat
            else:
                obj.data.materials.append(mat)

            # Iterate through texture files and assign them to the material
            for texture_file in texture_files:
                file_name = bpy.path.display_name_from_filepath(texture_file)
                file_parts = file_name.split('_')
                if len(file_parts) > 1 and file_parts[0] == obj_name:
                    texture_path = os.path.join(self.directory, texture_file)
                    stripExt = texture_file.lower().rsplit(".", 1)[0]

                    i = 0
                    # Base Color
                    for suffix in baseColor:
                        if stripExt.endswith(suffix):
                            img = bpy.data.images.load(texture_path)
                            texNode = mat.node_tree.nodes.new('ShaderNodeTexImage')
                            texNode.image = img
                            texNode.location = (x, y - (i * marginY))
                            links.new(mappingNode.outputs['Vector'], texNode.inputs['Vector'])


                            img.colorspace_settings.name = 'sRGB'

                            if oldVersion:
                                mixNode = nodes.new(type='ShaderNodeMixRGB')
                                mixNode.blend_type = 'MULTIPLY'
                                mixNode.location = (x + marginX, y - (i * marginY))
                                mixNode.inputs[0].default_value = 1

                                links.new(mixNode.outputs['Color'], nodes["Principled BSDF"].inputs['Base Color'])
                                links.new(texNode.outputs['Color'], mixNode.inputs['Color1'])

                            else:
                                mixNode = nodes.new(type='ShaderNodeMix')
                                mixNode.data_type = 'RGBA'
                                mixNode.blend_type = 'MULTIPLY'
                                mixNode.location = (x + marginX, y - (i * marginY))
                                mixNode.inputs[0].default_value = 1

                                links.new(mixNode.outputs[2], nodes["Principled BSDF"].inputs['Base Color'])
                                links.new(texNode.outputs['Color'], mixNode.inputs[6])

                            # mat.node_tree.links.new(bsdf.inputs['Base Color'], tex_node.outputs['Color'])
                            break

                    i=i+1
                    # Metallic
                    for suffix in metallic:
                        if stripExt.endswith(suffix):
                            img = bpy.data.images.load(texture_path)
                            texNode = mat.node_tree.nodes.new('ShaderNodeTexImage')
                            texNode.image = img
                            texNode.location = (x, y - (i * marginY))
                            links.new(mappingNode.outputs['Vector'], texNode.inputs['Vector'])


                            img.colorspace_settings.name = 'Non-Color'
                            links.new(texNode.outputs['Color'], nodes['Principled BSDF'].inputs['Metallic'])
                            # mat.node_tree.links.new(bsdf.inputs['Metallic'], tex_node.outputs['Color'])
                            break
                    
                    i=i+1
                    # Roughness
                    for suffix in roughness:
                        if stripExt.endswith(suffix):
                            img = bpy.data.images.load(texture_path)
                            texNode = mat.node_tree.nodes.new('ShaderNodeTexImage')
                            texNode.image = img
                            texNode.location = (x, y - (i * marginY))
                            links.new(mappingNode.outputs['Vector'], texNode.inputs['Vector'])


                            img.colorspace_settings.name = 'Non-Color'
                            links.new(texNode.outputs['Color'], nodes["Principled BSDF"].inputs['Roughness'])

                            # mat.node_tree.links.new(bsdf.inputs['Roughness'], tex_node.outputs['Color'])
                            break
                    
                    i=i+1
                    # Normal
                    for suffix in normal:
                        if stripExt.endswith(suffix):
                            img = bpy.data.images.load(texture_path)
                            texNode = mat.node_tree.nodes.new('ShaderNodeTexImage')
                            texNode.image = img
                            texNode.location = (x, y - (i * marginY))
                            links.new(mappingNode.outputs['Vector'], texNode.inputs['Vector'])


                            img.colorspace_settings.name = 'Non-Color'

                            normalNode = nodes.new(type='ShaderNodeNormalMap')
                            normalNode.location = (x + marginX, y - (i * marginY))
                            links.new(texNode.outputs['Color'], normalNode.inputs['Color'])
                            links.new(normalNode.outputs['Normal'], nodes['Principled BSDF'].inputs['Normal'])


                            # norm_map = mat.node_tree.nodes.new('ShaderNodeNormalMap')
                            # mat.node_tree.links.new(norm_map.inputs['Color'], tex_node.outputs['Color'])
                            # mat.node_tree.links.new(bsdf.inputs['Normal'], norm_map.outputs['Normal'])
                            break

        if obj_loaded:
            self.report({"INFO"}, "OBJ model and textures loaded successfully")
        else:
            self.report({"WARNING"}, "No OBJ model found in the selected files")

        return {'FINISHED'}

class SCENE_OT_textopbr_select_textures(bpy.types.Operator):
    """Select Textures To Create PBR Material"""
    bl_idname = "scene.textopbr_select_textures"
    bl_label = "Select Textures"
    bl_options = {'UNDO', 'INTERNAL'}

    files: bpy.props.CollectionProperty(type=bpy.types.OperatorFileListElement)
    directory: bpy.props.StringProperty()

    @classmethod
    def poll(cls, context):
        obj = context.active_object
        return (obj and obj.type == 'MESH')

    def invoke(self, context, event):
        context.window_manager.fileselect_add(self)
        return {'RUNNING_MODAL'}

    def execute(self, context):

        if len(self.files) > 8:
            self.report({"ERROR"}, "Too Many Files Selected !, You Can Only Choose Up To 8 Textures")
            return {'FINISHED'}

        # empty channels
        context.scene.textopbr_channels.baseColor = ""
        context.scene.textopbr_channels.metallic = ""
        context.scene.textopbr_channels.roughness = ""
        # context.scene.textopbr_channels.emission = ""
        # context.scene.textopbr_channels.alpha = ""
        context.scene.textopbr_channels.normal = ""
        # context.scene.textopbr_channels.height = ""
        # context.scene.textopbr_channels.ambientOcclusion = ""

        # get json data file
        jsonfile = context.scene.textopbr_settings.json_data_path

        # import extensions from json data file
        with open(jsonfile, "r") as f:
            data = json.load(f)
            extensions = data['extensions']
            baseColor = data['baseColor']
            metallic = data['metallic']
            roughness = data['roughness']
            # emission = data['emission']
            # alpha = data['alpha']
            normal = data['normal']
            # height = data['height']
            # ambientOcclusion = data['ambientOcclusion']

        for file in self.files:
            fileNLower = file.name.lower()
            for ext in extensions:
                if fileNLower.endswith(ext):
                    stripExt = fileNLower.rsplit(".")

                    for suffix in baseColor:
                        if stripExt[0].endswith(suffix):
                            context.scene.textopbr_channels.baseColor = self.directory + file.name
                            try:
                                context.scene.textopbr_channels.baseColor = bpy.path.relpath(context.scene.textopbr_channels.baseColor)
                            except Exception:
                                pass
                            break

                    for suffix in metallic:
                        if stripExt[0].endswith(suffix):
                            context.scene.textopbr_channels.metallic = self.directory + file.name
                            try:
                                context.scene.textopbr_channels.metallic = bpy.path.relpath(context.scene.textopbr_channels.metallic)
                            except Exception:
                                pass
                            break

                    for suffix in roughness:
                        if stripExt[0].endswith(suffix):
                            context.scene.textopbr_channels.roughness = self.directory + file.name
                            try:
                                context.scene.textopbr_channels.roughness = bpy.path.relpath(context.scene.textopbr_channels.roughness)
                            except Exception:
                                pass
                            break

                    # for suffix in emission:
                    #     if stripExt[0].endswith(suffix):
                    #         context.scene.textopbr_channels.emission = self.directory + file.name
                    #         try:
                    #             context.scene.textopbr_channels.emission = bpy.path.relpath(context.scene.textopbr_channels.emission)
                    #         except Exception:
                    #             pass
                    #         break

                    # for suffix in alpha:
                    #     if stripExt[0].endswith(suffix):
                    #         context.scene.textopbr_channels.alpha = self.directory + file.name
                    #         try:
                    #             context.scene.textopbr_channels.alpha = bpy.path.relpath(context.scene.textopbr_channels.alpha)
                    #         except Exception:
                    #             pass
                    #         break

                    for suffix in normal:
                        if stripExt[0].endswith(suffix):
                            context.scene.textopbr_channels.normal = self.directory + file.name
                            try:
                                context.scene.textopbr_channels.normal = bpy.path.relpath(context.scene.textopbr_channels.normal)
                            except Exception:
                                pass
                            break

                    # for suffix in height:
                    #     if stripExt[0].endswith(suffix):
                    #         context.scene.textopbr_channels.height = self.directory + file.name
                    #         try:
                    #             context.scene.textopbr_channels.height = bpy.path.relpath(context.scene.textopbr_channels.height)
                    #         except Exception:
                    #             pass
                    #         break

                    # for suffix in ambientOcclusion:
                    #     if stripExt[0].endswith(suffix):
                    #         context.scene.textopbr_channels.ambientOcclusion = self.directory + file.name
                    #         try:
                    #             context.scene.textopbr_channels.ambientOcclusion = bpy.path.relpath(context.scene.textopbr_channels.ambientOcclusion)
                    #         except Exception:
                    #             pass
                    #         break
        return {'FINISHED'}


class SCENE_OT_textopbr_add_suffix(bpy.types.Operator):
    """Add Suffix"""
    bl_idname = "scene.textopbr_add_suffix"
    bl_label = "Add Suffix"
    bl_options = {'UNDO', 'INTERNAL'}

    action: bpy.props.EnumProperty(
        items=[
            ('BASE_COLOR', 'base color', ' base color'),
            ('METALLIC', 'metallic', 'metallic'),
            ('ROUGHNESS', 'roughness', 'roughness'),
            ('EMISSION', 'emission', 'emission'),
            ('ALPHA', 'alpha', 'alpha'),
            ('NORMAL', 'normal', 'normal'),
            ('HEIGHT', 'height', 'height'),
            ('AMBIENT_OCCLUSION', 'ambient occlusion', 'ambient occlusion')
        ], options={'HIDDEN'}
    )
    Suffix: bpy.props.StringProperty()

    def invoke(self, context, event):
        return bpy.context.window_manager.invoke_props_dialog(self)

    def execute(self, context):
        file = context.scene.textopbr_settings.json_data_path
        try:
            self.Suffix = self.Suffix.lower()
            if self.Suffix != '':
                # open json file
                with open(file, "r") as jsonData:
                    data = json.load(jsonData)

                # add extension to json file
                with open(file, "w") as jsonData:
                    tempData = data
                    temp = []

                    if self.action == 'BASE_COLOR':
                        temp = data["baseColor"]
                    elif self.action == 'METALLIC':
                        temp = data["metallic"]
                    elif self.action == 'ROUGHNESS':
                        temp = data["roughness"]
                    elif self.action == 'EMISSION':
                        temp = data["emission"]
                    elif self.action == 'ALPHA':
                        temp = data["alpha"]
                    elif self.action == 'NORMAL':
                        temp = data["normal"]
                    elif self.action == 'HEIGHT':
                        temp = data["height"]
                    elif self.action == 'AMBIENT_OCCLUSION':
                        temp = data["ambientOcclusion"]

                    if self.Suffix not in temp:
                        new = self.Suffix
                        temp.append(new)
                        json.dump(tempData, jsonData, indent=4)
                    else:
                        json.dump(data, jsonData, indent=4)

        except Exception:
            with open(file, "w") as jsonData:
                json.dump(data, jsonData, indent=4)

        return {'FINISHED'}


class SCENE_OT_textopbr_remove_suffix(bpy.types.Operator):
    """Remove Suffix"""
    bl_idname = "scene.textopbr_remove_suffix"
    bl_label = "Remove Suffix"
    bl_options = {'UNDO', 'INTERNAL'}

    action: bpy.props.EnumProperty(
        items=[
            ('BASE_COLOR', 'base color', ' base color'),
            ('METALLIC', 'metallic', 'metallic'),
            ('ROUGHNESS', 'roughness', 'roughness'),
            ('EMISSION', 'emission', 'emission'),
            ('ALPHA', 'alpha', 'alpha'),
            ('NORMAL', 'normal', 'normal'),
            ('HEIGHT', 'height', 'height'),
            ('AMBIENT_OCCLUSION', 'ambient occlusion', 'ambient occlusion')
        ], options={'HIDDEN'}

    )
    Suffix: bpy.props.StringProperty()

    def invoke(self, context, event):
        return bpy.context.window_manager.invoke_props_dialog(self)

    def execute(self, context):
        file = context.scene.textopbr_settings.json_data_path
        try:
            self.Suffix = self.Suffix.lower()
            if self.Suffix != '':
                # open json file
                with open(file, "r") as jsonData:
                    data = json.load(jsonData)

                # add extension to json file
                with open(file, "w") as jsonData:
                    tempData = data
                    temp = []

                    if self.action == 'BASE_COLOR':
                        temp = data["baseColor"]
                    elif self.action == 'METALLIC':
                        temp = data["metallic"]
                    elif self.action == 'ROUGHNESS':
                        temp = data["roughness"]
                    elif self.action == 'EMISSION':
                        temp = data["emission"]
                    elif self.action == 'ALPHA':
                        temp = data["alpha"]
                    elif self.action == 'NORMAL':
                        temp = data["normal"]
                    elif self.action == 'HEIGHT':
                        temp = data["height"]
                    elif self.action == 'AMBIENT_OCCLUSION':
                        temp = data["ambientOcclusion"]

                    if self.Suffix in temp:
                        new = self.Suffix
                        temp.remove(new)
                        json.dump(tempData, jsonData, indent=4)
                    else:
                        json.dump(data, jsonData, indent=4)

        except Exception:
            with open(file, "w") as jsonData:
                json.dump(data, jsonData, indent=4)

        return {'FINISHED'}


class SCENE_OT_textopbr_generate_pbr(bpy.types.Operator):
    """Generate PBR Material From Selected Textures"""
    bl_idname = "scene.textopbr_generate_pbr"
    bl_label = "Generate PBR"
    bl_options = {'UNDO', 'INTERNAL'}

    matName: bpy.props.StringProperty(name="Material Name", default="TEXtoPBR_mat", description="The name of the new PBR generated material that will be attached to the active object")
    override_active_material: bpy.props.BoolProperty(name="Override Active Material", default=False, description="When enabled, the new created material will override the current active material")

    def invoke(self, context, event):
        bpy.context.window_manager.invoke_props_dialog(self)
        return {'RUNNING_MODAL'}

    def execute(self, context):
        TEXtoPBR_channels = context.scene.textopbr_channels
        availableChannels = []

        texturesFound = False
        for path in TEXtoPBR_channels.get_attrs_values():
            try:
                bpy.ops.image.open(filepath=path[1])
                availableChannels.append(path)
                texturesFound = True
            except Exception:
                continue

        if texturesFound:
            ob = bpy.context.active_object
            activeIndex = 0

            if self.override_active_material:
                if ob.active_material:
                    activeIndex = ob.active_material_index
                else:
                    bpy.ops.object.material_slot_add()
                    activeIndex = ob.active_material_index
            else:
                bpy.ops.object.material_slot_add()
                activeIndex = ob.active_material_index

            mat = bpy.data.materials.new(name=self.matName)
            mat.use_nodes = True
            ob.material_slots[activeIndex].material = mat

            # references
            nodeTree = ob.active_material.node_tree
            nodes = nodeTree.nodes
            links = nodeTree.links

            # mix node
            mixNode = None

            # constants
            x = -800
            y = 500
            marginX = 300
            marginY = 300

            # create texture coordinate for uv mapping
            texCoord = nodes.new(type='ShaderNodeTexCoord')
            texCoord.location = (x - 600, y)

            # create mapping node
            mappingNode = nodes.new(type='ShaderNodeMapping')
            mappingNode.location = (x - 400, y)
            links.new(texCoord.outputs['UV'], mappingNode.inputs['Vector'])

            # current blender version
            version = bpy.app.version_string

            # decide which node to use based on blender version
            oldVersion = False
            if int(version[0]) < 3 or (int(version[2]) < 4 and int(version[0]) <= 3):
                oldVersion = True

            # create texture node for each channel
            for i in range(0, len(availableChannels)):
                texNode = nodes.new(type="ShaderNodeTexImage")
                texNode.location = (x, y - (i * marginY))
                links.new(mappingNode.outputs['Vector'], texNode.inputs['Vector'])

                for image in bpy.data.images:
                    if image.filepath == availableChannels[i][1]:
                        texNode.image = image
# =================================================================================================================
                        if availableChannels[i][0] == 'baseColor':
                            image.colorspace_settings.name = 'sRGB'

                            if oldVersion:
                                mixNode = nodes.new(type='ShaderNodeMixRGB')
                                mixNode.blend_type = 'MULTIPLY'
                                mixNode.location = (x + marginX, y - (i * marginY))
                                mixNode.inputs[0].default_value = 1

                                links.new(mixNode.outputs['Color'], nodes["Principled BSDF"].inputs['Base Color'])
                                links.new(texNode.outputs['Color'], mixNode.inputs['Color1'])

                            else:
                                mixNode = nodes.new(type='ShaderNodeMix')
                                mixNode.data_type = 'RGBA'
                                mixNode.blend_type = 'MULTIPLY'
                                mixNode.location = (x + marginX, y - (i * marginY))
                                mixNode.inputs[0].default_value = 1

                                links.new(mixNode.outputs[2], nodes["Principled BSDF"].inputs['Base Color'])
                                links.new(texNode.outputs['Color'], mixNode.inputs[6])
# =================================================================================================================
                        elif availableChannels[i][0] == 'ambientOcclusion':
                            image.colorspace_settings.name = 'Non-Color'

                            if not mixNode:
                                if oldVersion:
                                    mixNode = nodes.new(type='ShaderNodeMixRGB')
                                    mixNode.blend_type = 'MULTIPLY'
                                    mixNode.location = (x + marginX, y - (i * marginY))
                                    mixNode.inputs[0].default_value = 1

                                    links.new(mixNode.outputs['Color'], nodes["Principled BSDF"].inputs['Base Color'])
                                    links.new(texNode.outputs['Color'], mixNode.inputs['Color2'])

                                else:
                                    mixNode = nodes.new(type='ShaderNodeMix')
                                    mixNode.data_type = 'RGBA'
                                    mixNode.blend_type = 'MULTIPLY'
                                    mixNode.location = (x + marginX, y - (i * marginY))
                                    mixNode.inputs[0].default_value = 1
                                    links.new(mixNode.outputs[2], nodes["Principled BSDF"].inputs['Base Color'])

                                    links.new(mixNode.outputs[2], nodes["Principled BSDF"].inputs['Base Color'])
                                    links.new(texNode.outputs['Color'], mixNode.inputs[7])

                            if mixNode:
                                if oldVersion:
                                    links.new(texNode.outputs['Color'], mixNode.inputs['Color2'])
                                else:
                                    links.new(texNode.outputs['Color'], mixNode.inputs[7])
# =================================================================================================================
                        elif availableChannels[i][0] == 'metallic':
                            image.colorspace_settings.name = 'Non-Color'
                            links.new(texNode.outputs['Color'], nodes['Principled BSDF'].inputs['Metallic'])
# =================================================================================================================
                        elif availableChannels[i][0] == 'roughness':
                            image.colorspace_settings.name = 'Non-Color'
                            links.new(texNode.outputs['Color'], nodes["Principled BSDF"].inputs['Roughness'])
# =================================================================================================================
                        elif availableChannels[i][0] == 'emission':
                            image.colorspace_settings.name = 'Non-Color'

                            links.new(texNode.outputs['Color'], nodes["Principled BSDF"].inputs['Emission'])
# =================================================================================================================
                        elif availableChannels[i][0] == 'alpha':
                            image.colorspace_settings.name = 'Non-Color'

                            links.new(texNode.outputs['Color'], nodes["Principled BSDF"].inputs['Alpha'])
                            ob.active_material.blend_method = 'BLEND'
                            ob.active_material.shadow_method = 'HASHED'

# =================================================================================================================
                        elif availableChannels[i][0] == 'normal':
                            image.colorspace_settings.name = 'Non-Color'

                            if TEXtoPBR_channels.bumpMap:
                                normalNode = nodes.new(type='ShaderNodeBump')
                                normalNode.location = (x + marginX, y - (i * marginY))
                                links.new(texNode.outputs['Color'], normalNode.inputs['Height'])
                                links.new(normalNode.outputs['Normal'], nodes['Principled BSDF'].inputs['Normal'])
                            else:
                                normalNode = nodes.new(type='ShaderNodeNormalMap')

                                if TEXtoPBR_channels.normalInvertGreen:
                                    normalNode.location = (x+marginX+300, y - (i * marginY))
                                    RGBCurve = nodes.new(type='ShaderNodeRGBCurve')
                                    Gchannel = RGBCurve.mapping.curves[1]
                                    Gchannel.points[0].location = (1, 0)
                                    Gchannel.points[1].location = (0, 1)
                                    RGBCurve.location = (x + marginX, y - (i * marginY))

                                    links.new(texNode.outputs['Color'], RGBCurve.inputs['Color'])
                                    links.new(RGBCurve.outputs['Color'], normalNode.inputs['Color'])
                                    links.new(normalNode.outputs['Normal'], nodes['Principled BSDF'].inputs['Normal'])
                                else:
                                    normalNode.location = (x + marginX, y - (i * marginY))
                                    links.new(texNode.outputs['Color'], normalNode.inputs['Color'])
                                    links.new(normalNode.outputs['Normal'], nodes['Principled BSDF'].inputs['Normal'])
# =================================================================================================================
                        elif availableChannels[i][0] == 'height':
                            image.colorspace_settings.name = 'Non-Color'

                            bpy.context.scene.render.engine = 'CYCLES'
                            bpy.context.scene.cycles.feature_set = 'EXPERIMENTAL'
                            ob.active_material.cycles.displacement_method = 'BOTH'

                            if not ob.modifiers.get('TEXtoPBR_Height_Subd'):
                                subsurfMod = ob.modifiers.new(name='TEXtoPBR_Height_Subd', type='SUBSURF')
                                subsurfMod.subdivision_type = 'SIMPLE'
                                ob.cycles.use_adaptive_subdivision = True

                            disp = nodes.new(type='ShaderNodeDisplacement')
                            # disp.inputs[2].default_value = 0.1
                            disp.location = (x + marginX, y - (i * marginY))
                            links.new(texNode.outputs['Color'], disp.inputs['Height'])
                            links.new(disp.outputs['Displacement'], nodes['Material Output'].inputs['Displacement'])

# =================================================================================================================
                        break

        return {'FINISHED'}


class SCENE_OT_textopbr_reload_material_textures(bpy.types.Operator):
    """Reload All Textures In Selected Material"""
    bl_idname = "scene.textopbr_reload_material_textures"
    bl_label = "Reload Material Textures"
    bl_options = {'UNDO', 'INTERNAL'}

    def get_object_materials_names(self, context):
        ob = context.active_object
        items = []
        for slot in ob.material_slots:
            if slot.material:
                name = slot.material.name
                items.append((name, name, name))
        return items

    matName: bpy.props.EnumProperty(name="Meterial", items=get_object_materials_names)

    def invoke(self, context, event):
        bpy.context.window_manager.invoke_props_dialog(self)
        return {'RUNNING_MODAL'}

    def execute(self, context):
        textures = []
        if self.matName:
            mat = bpy.data.materials[self.matName]
            if mat.node_tree:
                textures.extend([x for x in mat.node_tree.nodes if x.type == 'TEX_IMAGE'])

            # reload textures
            for texture in textures:
                try:
                    bpy.ops.image.open(filepath=texture.image.filepath)
                except Exception:
                    pass
        return {'FINISHED'}


# ============================================================================================================================================
# property groups

# TEXtoPBR channels
class TEXtoPBR_channels(bpy.types.PropertyGroup):

    def get_attrs_values(self):
        attrs_values = [("baseColor", self.baseColor.rstrip()),
                        # ("ambientOcclusion", self.ambientOcclusion.rstrip()),
                        ("metallic", self.metallic.rstrip()),
                        ("roughness", self.roughness.rstrip()),
                        # ("emission", self.emission.rstrip()),
                        # ("alpha", self.alpha.rstrip()),
                        ("normal", self.normal.rstrip()),
                        # ("height", self.height.rstrip())
                        ]
        return attrs_values

    baseColor: bpy.props.StringProperty(name="Base Color",default="//", subtype='FILE_PATH')
    metallic: bpy.props.StringProperty(name="Metallic",default="//", subtype='FILE_PATH')
    roughness: bpy.props.StringProperty(name="Roughness",default="//", subtype='FILE_PATH')
    # emission: bpy.props.StringProperty(name="Emission",default="//", subtype='FILE_PATH')
    # alpha: bpy.props.StringProperty(name="Alpha",default="//", subtype='FILE_PATH')
    normal: bpy.props.StringProperty(name="Normal",default="//", subtype='FILE_PATH')
    # height: bpy.props.StringProperty(name="Height",default="//", subtype='FILE_PATH')
    # ambientOcclusion: bpy.props.StringProperty(name="Ambient Occlusion",default="//", subtype='FILE_PATH')

    normalInvertGreen: bpy.props.BoolProperty(name="Normal Invert Green Channel", default=False)
    bumpMap: bpy.props.BoolProperty(name="Bump Map", default=False)


# TEXtoPBR settings
class TEXtoPBR_settings(bpy.types.PropertyGroup):

    def get_json_data_file(self):
        if self.json_data_path != '':
            return self.json_data_path

    def load_image_extensions(self):
        with open(self.get_json_data_file(), "r") as f:
            data = json.load(f)
        return str(data["extensions"])

    def load_base_color(self):
        with open(self.get_json_data_file(), "r") as f:
            data = json.load(f)
        return str(data["baseColor"])

    def load_metallic(self):
        with open(self.get_json_data_file(), "r") as f:
            data = json.load(f)
        return str(data["metallic"])

    def load_roughness(self):
        with open(self.get_json_data_file(), "r") as f:
            data = json.load(f)
        return str(data["roughness"])

    # def load_emission(self):
    #     with open(self.get_json_data_file(), "r") as f:
    #         data = json.load(f)
    #     return str(data["emission"])

    # def load_alpha(self):
    #     with open(self.get_json_data_file(), "r") as f:
    #         data = json.load(f)
    #     return str(data["alpha"])

    def load_normal(self):
        with open(self.get_json_data_file(), "r") as f:
            data = json.load(f)
        return str(data["normal"])

    # def load_height(self):
    #     with open(self.get_json_data_file(), "r") as f:
    #         data = json.load(f)
    #     return str(data["height"])

    # def load_ambient_occlusion(self):
    #     with open(self.get_json_data_file(), "r") as f:
    #         data = json.load(f)
    #     return str(data["ambientOcclusion"])

    json_data_path: bpy.props.StringProperty(default=get_json_data_path(), options={'HIDDEN'})

    image_extensions: bpy.props.StringProperty(get=load_image_extensions, options={'HIDDEN'})

    base_color: bpy.props.StringProperty(get=load_base_color, options={'HIDDEN'})
    metallic: bpy.props.StringProperty(get=load_metallic, options={'HIDDEN'})
    roughness: bpy.props.StringProperty(get=load_roughness, options={'HIDDEN'})
    # emission: bpy.props.StringProperty(get=load_emission, options={'HIDDEN'})
    # alpha: bpy.props.StringProperty(get=load_alpha, options={'HIDDEN'})
    normal: bpy.props.StringProperty(get=load_normal, options={'HIDDEN'})
    # height: bpy.props.StringProperty(get=load_height, options={'HIDDEN'})
    # ambient_occlusion: bpy.props.StringProperty(get=load_ambient_occlusion, options={'HIDDEN'})


# ============================================================================================================================================

def register():
    bpy.utils.register_class(SCENE_OT_fusionProtoer_load_obj_and_textures)
    # bpy.utils.register_class(SCENE_OT_textopbr_select_textures)
    bpy.utils.register_class(TEXtoPBR_settings)
    bpy.utils.register_class(SCENE_OT_textopbr_generate_pbr)
    bpy.utils.register_class(SCENE_OT_textopbr_reload_material_textures)
    bpy.utils.register_class(SCENE_OT_textopbr_add_suffix)
    bpy.utils.register_class(SCENE_OT_textopbr_remove_suffix)
    bpy.utils.register_class(TEXtoPBR_channels)

    # PointerProperty 用于将 textopbr_channels 属性链接到 TEXtoPBR_channels 类型的实例
    bpy.types.Scene.textopbr_settings = bpy.props.PointerProperty(type=TEXtoPBR_settings, options={'HIDDEN'})
    bpy.types.Scene.textopbr_channels = bpy.props.PointerProperty(type=TEXtoPBR_channels, options={'HIDDEN'})


def unregister():
    bpy.utils.unregister_class(SCENE_OT_fusionProtoer_load_obj_and_textures)
    # bpy.utils.unregister_class(SCENE_OT_textopbr_select_textures)
    bpy.utils.unregister_class(TEXtoPBR_settings)
    bpy.utils.unregister_class(SCENE_OT_textopbr_generate_pbr)
    bpy.utils.unregister_class(SCENE_OT_textopbr_reload_material_textures)
    bpy.utils.unregister_class(SCENE_OT_textopbr_add_suffix)
    bpy.utils.unregister_class(SCENE_OT_textopbr_remove_suffix)
    bpy.utils.unregister_class(TEXtoPBR_channels)

    del bpy.types.Scene.textopbr_settings
    del bpy.types.Scene.textopbr_channels
