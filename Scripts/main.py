from html_utils import convert_html_to_markdown, get_toc, split_html
from translate_pbrt import one_chunk_translate_text
import os
from merge_en_zh import merge_en_zh, convert_md_to_typ
from openai_utils import config_yaml
from typing import List
import argparse
# import transformer_typ 

def read_html_to_list(html_file_path: str) -> List[str]:
    res = []
    with open(html_file_path, encoding="utf-8") as f:
        html_chunk = split_html(f.read(), 32000)
        for html_text in html_chunk:
            res.append(html_text)
    return res


def run_chunk_with_cache(html_text: str, out_dir: str, index: int):
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

    html_path = f"{out_dir}/{index}_html.txt"
    print("  Getting html file: ", html_path)
    if os.path.exists(html_path):
        with open(html_path, "r", encoding="utf-8") as f:
            old_html_text = f.read()
        if old_html_text != html_text:
            print(f"error: old_html != currnet_html, {out_dir}/{index}")
    else:
        with open(html_path, "w", encoding="utf-8") as f:
            f.write(html_text)
        

    md_text = ""
    md_path = f"{out_dir}/{index}_md.txt"
    print("  convert_html_to_markdown file: ", md_path)
    if os.path.exists(md_path):
        with open(md_path, "r", encoding="utf-8") as f:
            md_text = f.read()
    else:
        md_text = convert_html_to_markdown(html_text)
        with open(md_path, "w", encoding="utf-8") as f:
            f.write(md_text)


    t1_text = ""
    t2_text = ""
    t3_text = ""
    t1_path = f"{out_dir}/{index}_t1.txt"
    t2_path = f"{out_dir}/{index}_t2.txt"
    t3_path = f"{out_dir}/{index}_t3.txt"
    print("  one_chunk_translate_text file: ", t1_path, t2_path)
    if os.path.exists(t3_path):
        with open(t1_path, "r", encoding="utf-8") as f:
            t1_text = f.read()
        with open(t2_path, "r", encoding="utf-8") as f:
            t2_text = f.read()
        with open(t3_path, "r", encoding="utf-8") as f:
            t3_text = f.read()
    else:
        t1_text, t2_text, t3_text = one_chunk_translate_text(
            "English", "Chinese", md_text
        )
        with open(t1_path, "w", encoding="utf-8") as f:
            f.write(t1_text)
        with open(t2_path, "w", encoding="utf-8") as f:
            f.write(t2_text)
        with open(t3_path, "w", encoding="utf-8") as f:
            f.write(t3_text)

    all_en_zh = ""
    en_zh_path = f"{out_dir}/{index}_en_zh.typ"
    print("  merge_en_zh file: ", en_zh_path)
    if os.path.exists(en_zh_path):
        with open(en_zh_path, "r", encoding="utf-8") as f:
            all_en_zh = f.read()
    else:
        en_zh = merge_en_zh(md_text, t3_text)
        for ez in en_zh.result:
            en_text = convert_md_to_typ(ez.english)
            zh_text = convert_md_to_typ(ez.chinese)
            all_en_zh += f"#parec[\n{en_text}\n][\n{zh_text}]\n\n"
        with open(en_zh_path, "w", encoding="utf-8") as f:
            f.write(all_en_zh)

    print("Done!")

# [
#   (0, 'Preface.html'), (1, 'Preface/Further_Reading.html'), 
# (2, 'Introduction.html'), (3, 'Introduction/Literate_Programming.html'), 
# (4, 'Introduction/Photorealistic_Rendering_and_the_Ray-Tracing_Algorithm.html'), 
# (5, 'Introduction/pbrt_System_Overview.html'), (6, 'Introduction/How_to_Proceed_through_This_Book.html'), 
# (7, 'Introduction/Using_and_Understanding_the_Code.html'),
#  (8, 'Introduction/A_Brief_History_of_Physically_Based_Rendering.html'), 
# (9, 'Introduction/Further_Reading.html'),
#  (10, 'Introduction/Exercises.html'),
#  (11, 'Monte_Carlo_Integration.html'),
#  (12, 'Monte_Carlo_Integration/Monte_Carlo_Basics.html'),
#  (13, 'Monte_Carlo_Integration/Improving_Efficiency.html'), 
# (14, 'Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html'), 
# (15, 'Monte_Carlo_Integration/Transforming_between_Distributions.html'),
#  (16, 'Monte_Carlo_Integration/Further_Reading.html'), 
# (17, 'Monte_Carlo_Integration/Exercises.html'), 
# (18, 'Geometry_and_Transformations.html'), 
# (19, 'Geometry_and_Transformations/Coordinate_Systems.html'), 
# (20, 'Geometry_and_Transformations/n-Tuple_Base_Classes.html'), 
# (21, 'Geometry_and_Transformations/Vectors.html'), 
# (22, 'Geometry_and_Transformations/Points.html'), 
# (23, 'Geometry_and_Transformations/Normals.html'), 
# (24, 'Geometry_and_Transformations/Rays.html'), 
# (25, 'Geometry_and_Transformations/Bounding_Boxes.html'), 
# (26, 'Geometry_and_Transformations/Spherical_Geometry.html'), 
# (27, 'Geometry_and_Transformations/Transformations.html'), 
# (28, 'Geometry_and_Transformations/Applying_Transformations.html'), 
# (29, 'Geometry_and_Transformations/Interactions.html'), (30, 'Geometry_and_Transformations/Further_Reading.html'), 
# (31, 'Geometry_and_Transformations/Exercises.html'), (32, 'Radiometry,_Spectra,_and_Color.html'), 
# (33, 'Radiometry,_Spectra,_and_Color/Radiometry.html'), 
# (34, 'Radiometry,_Spectra,_and_Color/Working_with_Radiometric_Integrals.html'), 
# (35, 'Radiometry,_Spectra,_and_Color/Surface_Reflection.html'), 
# (36, 'Radiometry,_Spectra,_and_Color/Light_Emission.html'), 
# (37, 'Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html'), 
# (38, 'Radiometry,_Spectra,_and_Color/Color.html'), 
# (39, 'Radiometry,_Spectra,_and_Color/Further_Reading.html'), 
# (40, 'Radiometry,_Spectra,_and_Color/Exercises.html'), 
# (41, 'Cameras_and_Film.html'), (42, 'Cameras_and_Film/Camera_Interface.html'), 
# (43, 'Cameras_and_Film/Projective_Camera_Models.html'), 
# (44, 'Cameras_and_Film/Spherical_Camera.html'), 
# (45, 'Cameras_and_Film/Film_and_Imaging.html'), (46, 'Cameras_and_Film/Further_Reading.html'), 
# (47, 'Cameras_and_Film/Exercises.html'), (48, 'Shapes.html'), (49, 'Shapes/Basic_Shape_Interface.html'), 
# (50, 'Shapes/Spheres.html'), (51, 'Shapes/Cylinders.html'), (52, 'Shapes/Disks.html'), 
# (53, 'Shapes/Triangle_Meshes.html'), (54, 'Shapes/Bilinear_Patches.html'), 
# (55, 'Shapes/Curves.html'), (56, 'Shapes/Managing_Rounding_Error.html'), 
# (57, 'Shapes/Further_Reading.html'), (58, 'Shapes/Exercises.html'), 
# (59, 'Primitives_and_Intersection_Acceleration.html'), 
# (60, 'Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html'), 
# (61, 'Primitives_and_Intersection_Acceleration/Aggregates.html'), 
# (62, 'Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html'), 
# (63, 'Primitives_and_Intersection_Acceleration/Further_Reading.html'), 
# (64, 'Primitives_and_Intersection_Acceleration/Exercises.html'), (65, 'Sampling_and_Reconstruction.html'), 
# (66, 'Sampling_and_Reconstruction/Sampling_Theory.html'), (67, 'Sampling_and_Reconstruction/Sampling_and_Integration.html'), 
# (68, 'Sampling_and_Reconstruction/Sampling_Interface.html'), 
# (69, 'Sampling_and_Reconstruction/Independent_Sampler.html'), 
# (70, 'Sampling_and_Reconstruction/Stratified_Sampler.html'), (71, 'Sampling_and_Reconstruction/Halton_Sampler.html'), 
# (72, 'Sampling_and_Reconstruction/Sobol_Samplers.html'), (73, 'Sampling_and_Reconstruction/Image_Reconstruction.html'), 
# (74, 'Sampling_and_Reconstruction/Further_Reading.html'), (75, 'Sampling_and_Reconstruction/Exercises.html'), 
# (76, 'Reflection_Models.html'), (77, 'Reflection_Models/BSDF_Representation.html'), 
# (78, 'Reflection_Models/Diffuse_Reflection.html'), 
# (79, 'Reflection_Models/Specular_Reflection_and_Transmission.html'), 
# (80, 'Reflection_Models/Conductor_BRDF.html'), (81, 'Reflection_Models/Dielectric_BSDF.html'), 
# (82, 'Reflection_Models/Roughness_Using_Microfacet_Theory.html'), (83, 'Reflection_Models/Rough_Dielectric_BSDF.html'), 
# (84, 'Reflection_Models/Measured_BSDFs.html'), (85, 'Reflection_Models/Scattering_from_Hair.html'), 
# (86, 'Reflection_Models/Further_Reading.html'), (87, 'Reflection_Models/Exercises.html'), 
# (88, 'Textures_and_Materials.html'), (89, 'Textures_and_Materials/Texture_Sampling_and_Antialiasing.html'), 
# (90, 'Textures_and_Materials/Texture_Coordinate_Generation.html'), 
# (91, 'Textures_and_Materials/Texture_Interface_and_Basic_Textures.html'), (92, 'Textures_and_Materials/Image_Texture.html'), (93, 'Textures_and_Materials/Material_Interface_and_Implementations.html'), (94, 'Textures_and_Materials/Further_Reading.html'), (95, 'Textures_and_Materials/Exercises.html'), (96, 'Volume_Scattering.html'), (97, 'Volume_Scattering/Volume_Scattering_Processes.html'), (98, 'Volume_Scattering/Transmittance.html'), (99, 'Volume_Scattering/Phase_Functions.html'), (100, 'Volume_Scattering/Media.html'), (101, 'Volume_Scattering/Further_Reading.html'), (102, 'Volume_Scattering/Exercises.html'), (103, 'Light_Sources.html'), (104, 'Light_Sources/Light_Interface.html'), (105, 'Light_Sources/Point_Lights.html'), (106, 'Light_Sources/Distant_Lights.html'), (107, 'Light_Sources/Area_Lights.html'), (108, 'Light_Sources/Infinite_Area_Lights.html'), (109, 'Light_Sources/Light_Sampling.html'), (110, 'Light_Sources/Further_Reading.html'), (111, 'Light_Sources/Exercises.html'), (112, 'Light_Transport_I_Surface_Reflection.html'), (113, 'Light_Transport_I_Surface_Reflection/The_Light_Transport_Equation.html'), (114, 'Light_Transport_I_Surface_Reflection/Path_Tracing.html'), (115, 'Light_Transport_I_Surface_Reflection/A_Simple_Path_Tracer.html'), (116, 'Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html'), (117, 'Light_Transport_I_Surface_Reflection/Further_Reading.html'), (118, 'Light_Transport_I_Surface_Reflection/Exercises.html'), (119, 'Light_Transport_II_Volume_Rendering.html'), (120, 'Light_Transport_II_Volume_Rendering/The_Equation_of_Transfer.html'), (121, 'Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html'), (122, 'Light_Transport_II_Volume_Rendering/Scattering_from_Layered_Materials.html'), (123, 'Light_Transport_II_Volume_Rendering/Further_Reading.html'),
#  (124, 'Light_Transport_II_Volume_Rendering/Exercises.html'), 
# (125, 'Wavefront_Rendering_on_GPUs.html'), (126, 'Wavefront_Rendering_on_GPUs/Mapping_Path_Tracing_to_the_GPU.html'), 
# (127, 'Wavefront_Rendering_on_GPUs/Implementation_Foundations.html'), 
# (128, 'Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html'), (129, 'Wavefront_Rendering_on_GPUs/Further_Reading.html'), (130, 'Wavefront_Rendering_on_GPUs/Exercises.html'), (131, 'Retrospective_and_the_Future.html'), (132, 'Retrospective_and_the_Future/pbrt_over_the_Years.html'), (133, 'Retrospective_and_the_Future/Design_Alternatives.html'), (134, 'Retrospective_and_the_Future/Emerging_Topics.html'), (135, 'Retrospective_and_the_Future/The_Future.html'), (136, 'Retrospective_and_the_Future/Conclusion.html'), (137, 'Retrospective_and_the_Future/Further_Reading.html'), (138, 'Sampling_Algorithms.html'), (139, 'Sampling_Algorithms/The_Alias_Method.html'), (140, 'Sampling_Algorithms/Reservoir_Sampling.html'), (141, 'Sampling_Algorithms/The_Rejection_Method.html'), (142, 'Sampling_Algorithms/Sampling_1D_Functions.html'), (143, 'Sampling_Algorithms/Sampling_Multidimensional_Functions.html'), (144, 'Sampling_Algorithms/Further_Reading.html'), (145, 'Sampling_Algorithms/Exercises.html'), (146, 'Utilities.html'), (147, 'Utilities/System_Startup,_Cleanup,_and_Options.html'), (148, 'Utilities/Mathematical_Infrastructure.html'), (149, 'Utilities/User_Interaction.html'), (150, 'Utilities/Containers_and_Memory_Management.html'), (151, 'Utilities/Images.html'), (152, 'Utilities/Parallelism.html'), (153, 'Utilities/Statistics.html'), (154, 'Utilities/Further_Reading.html'), (155, 'Utilities/Exercises.html'), (156, 'Processing_the_Scene_Description.html'), (157, 'Processing_the_Scene_Description/Tokenizing_and_Parsing.html'), (158, 'Processing_the_Scene_Description/Managing_the_Scene_Description.html'), (159, 'Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html'), (160, 'Processing_the_Scene_Description/Adding_New_Object_Implementations.html'), (161, 'Processing_the_Scene_Description/Further_Reading.html'), (162, 'Processing_the_Scene_Description/Exercises.html'), (163, 'References.html'), (164, 'Index_of_Fragments.html'), (165, 'Index_of_Identifiers.html')]
# if __name__ == "__main__":
    # # 创建 ArgumentParser 对象
    # parser = argparse.ArgumentParser(description='命令行参数解析示例')
    # parser.add_argument('--config', type=argparse.FileType('r'))  # 以读模式打开文件
    # # 解析命令行参数
    # args = parser.parse_args()

    # if args.config:

def translate():
    hrefs = get_toc(config_yaml["pbr_book"] + "/contents.html")
    # print(list(enumerate(hrefs)))
    # exit(0)
    for h in hrefs[150:151]:
        print(f"translating {h}")
        html_file_path = config_yaml["pbr_book"] + "/" + h
        html_texts = read_html_to_list(html_file_path)
        out_dir = os.path.splitext(config_yaml["cache_dir"] + "/" + h)[0]
        all_en_zh_text = ""
        for i, html_text in enumerate(html_texts):
            print(f"sub: {i}")
            run_chunk_with_cache(html_text, out_dir, i)
            with open(f"{out_dir}/{i}_en_zh.typ", "r", encoding="utf-8") as f:
                all_en_zh_text += f.read() + "\n"

        with open(f"{out_dir}/all_en_zh.typ", "w", encoding="utf-8") as f:
            all_en_zh_text = all_en_zh_text.replace("#parec[\n  #horizontalrule\n\n][\n  #horizontalrule]", "")
            f.write(f'#import "../template.typ": parec\n\n{all_en_zh_text}')
        

if __name__ == "__main__":
    translate()
    # source_typ = r"C:\Users\15258\work\pbrt\pbrt-v4-zh\chapter-1-Introduction\chapter-1.6-A_Brief_History_of_Physically_Based_Rendering.typ"
    # all_parec = transformer_typ.get_all_parec(source_typ)
    # # for a,b in all_parec:
    # #     print(a,b)


    # # 设置要遍历的根目录
    # root_dir = r"C:\Users\15258\work\pbrt\pbrt-v4-zh\chapter-16-Retrospective_and_the_Future"

    # # 遍历目录
    # for dirpath, dirnames, filenames in os.walk(root_dir):
    #     for filename in filenames:
    #         # 检查文件名是否包含 "metal" 且以 ".png" 结尾
    #         if filename.endswith(".typ"):
    #             file_path = os.path.join(dirpath, filename) 
    #             formatted_typ = transformer_typ.get_format_typ(file_path)
    #             formatted_typ = formatted_typ.replace("\r\n", "\n")
    #             with open(file_path, mode="w", encoding="utf-8") as f:
    #                 f.write(formatted_typ)
