from pymxs import runtime as rt

def import_model_and_apply_textures(model_path):
    # 获取模型文件路径
    base_path = rt.getFilenamePath(model_path)
    base_name = rt.getFilenameFile(model_path)
    
    # 定义贴图文件路径
    diffuse_map = f"{base_path}{base_name}_diffuse.jpg"
    normal_map = f"{base_path}{base_name}_normal.jpg"
    metallic_map = f"{base_path}{base_name}_metallic.jpg"
    roughness_map = f"{base_path}{base_name}_roughness.jpg"

    # 导入模型
    rt.importFile(model_path, rt.name("noPrompt"))

    # 创建 PBR 材质
    pbr_material = rt.PhysicalMaterial()

    # 加载 Diffuse 贴图
    if rt.doesFileExist(diffuse_map):
        diffuse_bitmap = rt.Bitmaptexture(filename=diffuse_map)
        pbr_material.base_color_map = diffuse_bitmap
        print(f"Loaded diffuse map: {diffuse_map}")
    else:
        print("Diffuse map not found.")

    # 加载 Normal 贴图
    if rt.doesFileExist(normal_map):
        normal_bitmap = rt.Normal_Bump()
        normal_bitmap.normal_map = rt.Bitmaptexture(filename=normal_map)
        pbr_material.bump_map = normal_bitmap
        print(f"Loaded normal map: {normal_map}")
    else:
        print("Normal map not found.")

    # 加载 Metallic 贴图
    if rt.doesFileExist(metallic_map):
        metallic_bitmap = rt.Bitmaptexture(filename=metallic_map)
        pbr_material.metalness_map = metallic_bitmap
        print(f"Loaded metallic map: {metallic_map}")
    else:
        print("Metallic map not found.")

    # 加载 Roughness 贴图
    if rt.doesFileExist(roughness_map):
        roughness_bitmap = rt.Bitmaptexture(filename=roughness_map)
        pbr_material.roughness_map = roughness_bitmap
        print(f"Loaded roughness map: {roughness_map}")
    else:
        print("Roughness map not found.")

    # 将材质应用到场景中所有对象
    for obj in rt.selection:
        obj.material = pbr_material
        print(f"Material applied to object: {obj.name}")

    print("Model and textures imported successfully!")

# 示例：指定模型路径
model_path = "C:/path/to/your/model.fbx"

# 调用函数
import_model_and_apply_textures(model_path)
