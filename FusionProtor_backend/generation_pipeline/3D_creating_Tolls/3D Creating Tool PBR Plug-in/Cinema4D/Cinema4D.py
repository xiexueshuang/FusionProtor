import c4d
import os

def create_material_with_textures(base_path, base_name):
    """
    创建材质并加载 Diffuse、Normal、Metallic 和 Roughness 贴图。
    """
    # 创建一个新的标准材质
    material = c4d.BaseMaterial(c4d.Mmaterial)
    material.SetName(f"{base_name}_Material")

    # 定义贴图路径
    diffuse_map = os.path.join(base_path, f"{base_name}_diffuse.jpg")
    normal_map = os.path.join(base_path, f"{base_name}_normal.jpg")
    metallic_map = os.path.join(base_path, f"{base_name}_metallic.jpg")
    roughness_map = os.path.join(base_path, f"{base_name}_roughness.jpg")

    # 加载 Diffuse 贴图
    if os.path.exists(diffuse_map):
        shader = c4d.BaseShader(c4d.Xbitmap)
        shader[c4d.BITMAPSHADER_FILENAME] = diffuse_map
        material[c4d.MATERIAL_COLOR_SHADER] = shader
        material[c4d.MATERIAL_USE_COLOR] = True
        material.InsertShader(shader)

    # 加载 Normal 贴图
    if os.path.exists(normal_map):
        normal_shader = c4d.BaseShader(c4d.Xbitmap)
        normal_shader[c4d.BITMAPSHADER_FILENAME] = normal_map
        material[c4d.MATERIAL_NORMAL_SHADER] = normal_shader
        material[c4d.MATERIAL_USE_NORMAL] = True
        material.InsertShader(normal_shader)

    # 加载 Metallic 贴图
    if os.path.exists(metallic_map):
        metallic_shader = c4d.BaseShader(c4d.Xbitmap)
        metallic_shader[c4d.BITMAPSHADER_FILENAME] = metallic_map
        material[c4d.MATERIAL_REFLECTION_LAYER_FRESNEL] = metallic_shader
        material.InsertShader(metallic_shader)

    # 加载 Roughness 贴图
    if os.path.exists(roughness_map):
        roughness_shader = c4d.BaseShader(c4d.Xbitmap)
        roughness_shader[c4d.BITMAPSHADER_FILENAME] = roughness_map
        material[c4d.MATERIAL_ROUGHNESS_SHADER] = roughness_shader
        material.InsertShader(roughness_shader)

    # 更新材质
    material.Update(True, True)
    return material


def import_model_and_apply_material(doc, model_path):
    """
    导入模型文件并应用材质。
    """
    # 获取模型文件的目录和文件名
    base_path = os.path.dirname(model_path)
    base_name, ext = os.path.splitext(os.path.basename(model_path))

    # 检查文件格式
    if ext.lower() not in ['.obj', '.usdz']:
        c4d.gui.MessageDialog("Unsupported file format! Please use OBJ or USDZ.")
        return

    # 导入模型
    if not c4d.documents.MergeDocument(doc, model_path, c4d.SCENEFILTER_OBJECTS):
        c4d.gui.MessageDialog("Failed to import the model.")
        return

    # 创建材质并加载贴图
    material = create_material_with_textures(base_path, base_name)
    if material:
        doc.InsertMaterial(material)

    # 获取场景中的最后一个导入的对象
    imported_objects = doc.GetActiveObjects(c4d.GETACTIVEOBJECTFLAGS_CHILDREN)
    if not imported_objects:
        c4d.gui.MessageDialog("No objects were imported.")
        return

    # 将材质应用到导入的对象
    for obj in imported_objects:
        if obj.CheckType(c4d.Opolygon):
            tag = c4d.TextureTag()
            tag.SetMaterial(material)
            obj.InsertTag(tag)

    c4d.EventAdd()
    c4d.gui.MessageDialog("Model and materials imported successfully!")


def main():
    """
    插件主入口。
    """
    # 打开文件选择器
    model_path = c4d.storage.LoadDialog(title="Select Model File", type=c4d.FILESELECTTYPE_ANYTHING)
    if not model_path:
        return

    # 获取当前文档
    doc = c4d.documents.GetActiveDocument()

    # 导入模型并应用材质
    import_model_and_apply_material(doc, model_path)


if __name__ == "__main__":
    main()
