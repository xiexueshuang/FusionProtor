import maya.cmds as cmds
import os

def create_material_with_textures(base_path, base_name):
    """
    创建材质并加载 Diffuse、Normal、Metallic 和 Roughness 贴图。
    """
    # 创建一个新的 aiStandardSurface 材质
    material_name = f"{base_name}_Material"
    material = cmds.shadingNode('aiStandardSurface', asShader=True, name=material_name)
    shader_group = cmds.sets(renderable=True, noSurfaceShader=True, empty=True, name=f"{material_name}SG")
    cmds.connectAttr(f"{material}.outColor", f"{shader_group}.surfaceShader")

    # 定义贴图路径
    diffuse_map = os.path.join(base_path, f"{base_name}_diffuse.jpg")
    normal_map = os.path.join(base_path, f"{base_name}_normal.jpg")
    metallic_map = os.path.join(base_path, f"{base_name}_metallic.jpg")
    roughness_map = os.path.join(base_path, f"{base_name}_roughness.jpg")

    # 加载 Diffuse 贴图
    if os.path.exists(diffuse_map):
        diffuse_file = cmds.shadingNode('file', asTexture=True, isColorManaged=True, name=f"{base_name}_Diffuse")
        cmds.setAttr(f"{diffuse_file}.fileTextureName", diffuse_map, type="string")
        cmds.connectAttr(f"{diffuse_file}.outColor", f"{material}.baseColor")

    # 加载 Normal 贴图
    if os.path.exists(normal_map):
        normal_file = cmds.shadingNode('file', asTexture=True, isColorManaged=False, name=f"{base_name}_Normal")
        bump_node = cmds.shadingNode('bump2d', asUtility=True, name=f"{base_name}_Bump")
        cmds.setAttr(f"{normal_file}.fileTextureName", normal_map, type="string")
        cmds.setAttr(f"{bump_node}.bumpInterp", 1)  # 设置为 Tangent Space Normals
        cmds.connectAttr(f"{normal_file}.outAlpha", f"{bump_node}.bumpValue")
        cmds.connectAttr(f"{bump_node}.outNormal", f"{material}.normalCamera")

    # 加载 Metallic 贴图
    if os.path.exists(metallic_map):
        metallic_file = cmds.shadingNode('file', asTexture=True, isColorManaged=False, name=f"{base_name}_Metallic")
        cmds.setAttr(f"{metallic_file}.fileTextureName", metallic_map, type="string")
        cmds.connectAttr(f"{metallic_file}.outAlpha", f"{material}.metalness")

    # 加载 Roughness 贴图
    if os.path.exists(roughness_map):
        roughness_file = cmds.shadingNode('file', asTexture=True, isColorManaged=False, name=f"{base_name}_Roughness")
        cmds.setAttr(f"{roughness_file}.fileTextureName", roughness_map, type="string")
        cmds.connectAttr(f"{roughness_file}.outAlpha", f"{material}.specularRoughness")

    return shader_group


def import_model_and_apply_material(model_path):
    """
    导入模型文件并应用材质。
    """
    # 获取模型文件的目录和文件名
    base_path = os.path.dirname(model_path)
    base_name, ext = os.path.splitext(os.path.basename(model_path))

    # 检查文件格式
    if ext.lower() == ".obj":
        cmds.file(model_path, i=True, type="OBJ", options="mo=1", ignoreVersion=True)
    elif ext.lower() == ".usdz":
        cmds.error("USDZ format is not natively supported. Convert it to USD or OBJ first.")
        return
    else:
        cmds.error("Unsupported file format! Please use OBJ or USD.")
        return

    # 创建材质并加载贴图
    shader_group = create_material_with_textures(base_path, base_name)

    # 获取导入的对象并分配材质
    imported_objects = cmds.ls(selection=True)
    if not imported_objects:
        cmds.error("No objects were imported.")
        return

    for obj in imported_objects:
        cmds.sets(obj, edit=True, forceElement=shader_group)

    print("Model and materials imported successfully!")


def main():
    """
    插件主入口。
    """
    # 打开文件选择器
    model_path = cmds.fileDialog2(fileFilter="Model Files (*.obj *.usdz)", dialogStyle=2, fileMode=1)
    if not model_path:
        return

    # 导入模型并应用材质
    import_model_and_apply_material(model_path[0])


# 运行插件
if __name__ == "__main__":
    main()
