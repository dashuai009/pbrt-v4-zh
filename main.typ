
#import "template.typ": pbrt

#show: pbrt
#include "about_the_authors.typ"
#pagebreak()
#include "about_me.typ"
// #figure(
//   image("pbr-book-website/landing.jpg"),
// )
//

#outline(
  title: [PBR Contents],
  indent: auto,
)

#pagebreak()


#include "chapter-0-Preface/chapter-0.0-Preface.typ"
#include "chapter-0-Preface/chapter-0.1-Further_Reading.typ"

#counter(heading).update(0)

#include "chapter-1-Introduction/chapter-1.0-Introduction.typ"
#include "chapter-1-Introduction/chapter-1.1-Literate_Programming.typ"
#include "chapter-1-Introduction/chapter-1.2-Photorealistic_Rendering_and_the_Ray-Tracing_Algorithm.typ"
#include "chapter-1-Introduction/chapter-1.3-pbrt_System_Overview.typ"
#include "chapter-1-Introduction/chapter-1.4-How_to_Proceed_through_This_Book.typ"
#include "chapter-1-Introduction/chapter-1.5-Using_and_Understanding_the_Code.typ"
#include "chapter-1-Introduction/chapter-1.6-A_Brief_History_of_Physically_Based_Rendering.typ"
#include "chapter-1-Introduction/chapter-1.7-Further_Reading.typ"
#include "chapter-1-Introduction/chapter-1.8-Exercises.typ"


#include "chapter-2-Monte_Carlo_Integration/chapter-2.0-Monte_Carlo_Integration.typ"
#include "chapter-2-Monte_Carlo_Integration/chapter-2.1-Monte_Carlo_Basics.typ"
#include "chapter-2-Monte_Carlo_Integration/chapter-2.2-Improving_Efficiency.typ"
#include "chapter-2-Monte_Carlo_Integration/chapter-2.3-Sampling_Using_the_Inversion_Method.typ"
#include "chapter-2-Monte_Carlo_Integration/chapter-2.4-Transforming_between_Distributions.typ"
#include "chapter-2-Monte_Carlo_Integration/chapter-2.5-Further_Reading.typ"
#include "chapter-2-Monte_Carlo_Integration/chapter-2.6-Exercises.typ"


#include "chapter-3-Geometry_and_Transformations/chapter-3.0-Geometry_and_Transformations.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.1-Coordinate_Systems.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.2-n-Tuple_Base_Classes.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.3-Vectors.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.4-Points.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.5-Normals.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.6-Rays.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.7-Bounding_Boxes.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.8-Spherical_Geometry.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.9-Transformations.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.10-Applying_Transformations.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.11-Interactions.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.12-Further_Reading.typ"
#include "chapter-3-Geometry_and_Transformations/chapter-3.13-Exercises.typ"


#include "chapter-4-Radiometry,_Spectra,_and_Color/chapter-4.0-Radiometry,_Spectra,_and_Color.typ"
#include "chapter-4-Radiometry,_Spectra,_and_Color/chapter-4.1-Radiometry.typ"
#include "chapter-4-Radiometry,_Spectra,_and_Color/chapter-4.2-Working_with_Radiometric_Integrals.typ"
#include "chapter-4-Radiometry,_Spectra,_and_Color/chapter-4.3-Surface_Reflection.typ"
#include "chapter-4-Radiometry,_Spectra,_and_Color/chapter-4.4-Light_Emission.typ"
#include "chapter-4-Radiometry,_Spectra,_and_Color/chapter-4.5-Representing_Spectral_Distributions.typ"
#include "chapter-4-Radiometry,_Spectra,_and_Color/chapter-4.6-Color.typ"
#include "chapter-4-Radiometry,_Spectra,_and_Color/chapter-4.7-Further_Reading.typ"
#include "chapter-4-Radiometry,_Spectra,_and_Color/chapter-4.8-Exercises.typ"


#include "chapter-5-Cameras_and_Film/chapter-5.0-Cameras_and_Film.typ"
#include "chapter-5-Cameras_and_Film/chapter-5.1-Camera_Interface.typ"
#include "chapter-5-Cameras_and_Film/chapter-5.2-Projective_Camera_Models.typ"
#include "chapter-5-Cameras_and_Film/chapter-5.3-Spherical_Camera.typ"
#include "chapter-5-Cameras_and_Film/chapter-5.4-Film_and_Imaging.typ"
#include "chapter-5-Cameras_and_Film/chapter-5.5-Further_Reading.typ"
#include "chapter-5-Cameras_and_Film/chapter-5.6-Exercises.typ"


#include "chapter-6-Shapes/chapter-6.0-Shapes.typ"
#include "chapter-6-Shapes/chapter-6.1-Basic_Shape_Interface.typ"
#include "chapter-6-Shapes/chapter-6.2-Spheres.typ"
#include "chapter-6-Shapes/chapter-6.3-Cylinders.typ"
#include "chapter-6-Shapes/chapter-6.4-Disks.typ"
#include "chapter-6-Shapes/chapter-6.5-Triangle_Meshes.typ"
#include "chapter-6-Shapes/chapter-6.6-Bilinear_Patches.typ"
#include "chapter-6-Shapes/chapter-6.7-Curves.typ"
#include "chapter-6-Shapes/chapter-6.8-Managing_Rounding_Error.typ"
#include "chapter-6-Shapes/chapter-6.9-Further_Reading.typ"
#include "chapter-6-Shapes/chapter-6.10-Exercises.typ"


#include "chapter-7-Primitives_and_Intersection_Acceleration/chapter-7.0-Primitives_and_Intersection_Acceleration.typ"
#include "chapter-7-Primitives_and_Intersection_Acceleration/chapter-7.1-Primitive_Interface_and_Geometric_Primitives.typ"
#include "chapter-7-Primitives_and_Intersection_Acceleration/chapter-7.2-Aggregates.typ"
#include "chapter-7-Primitives_and_Intersection_Acceleration/chapter-7.3-Bounding_Volume_Hierarchies.typ"
#include "chapter-7-Primitives_and_Intersection_Acceleration/chapter-7.4-Further_Reading.typ"
#include "chapter-7-Primitives_and_Intersection_Acceleration/chapter-7.5-Exercises.typ"


#include "chapter-8-Sampling_and_Reconstruction/chapter-8.0-Sampling_and_Reconstruction.typ"
#include "chapter-8-Sampling_and_Reconstruction/chapter-8.1-Sampling_Theory.typ"
#include "chapter-8-Sampling_and_Reconstruction/chapter-8.2-Sampling_and_Integration.typ"
#include "chapter-8-Sampling_and_Reconstruction/chapter-8.3-Sampling_Interface.typ"
#include "chapter-8-Sampling_and_Reconstruction/chapter-8.4-Independent_Sampler.typ"
#include "chapter-8-Sampling_and_Reconstruction/chapter-8.5-Stratified_Sampler.typ"
#include "chapter-8-Sampling_and_Reconstruction/chapter-8.6-Halton_Sampler.typ"
#include "chapter-8-Sampling_and_Reconstruction/chapter-8.7-Sobol_Samplers.typ"
#include "chapter-8-Sampling_and_Reconstruction/chapter-8.8-Image_Reconstruction.typ"
#include "chapter-8-Sampling_and_Reconstruction/chapter-8.9-Further_Reading.typ"
#include "chapter-8-Sampling_and_Reconstruction/chapter-8.10-Exercises.typ"


#include "chapter-9-Reflection_Models/chapter-9.0-Reflection_Models.typ"
#include "chapter-9-Reflection_Models/chapter-9.1-BSDF_Representation.typ"
#include "chapter-9-Reflection_Models/chapter-9.2-Diffuse_Reflection.typ"
#include "chapter-9-Reflection_Models/chapter-9.3-Specular_Reflection_and_Transmission.typ"
#include "chapter-9-Reflection_Models/chapter-9.4-Conductor_BRDF.typ"
#include "chapter-9-Reflection_Models/chapter-9.5-Dielectric_BSDF.typ"
#include "chapter-9-Reflection_Models/chapter-9.6-Roughness_Using_Microfacet_Theory.typ"
#include "chapter-9-Reflection_Models/chapter-9.7-Rough_Dielectric_BSDF.typ"
#include "chapter-9-Reflection_Models/chapter-9.8-Measured_BSDFs.typ"
#include "chapter-9-Reflection_Models/chapter-9.9-Scattering_from_Hair.typ"
#include "chapter-9-Reflection_Models/chapter-9.10-Further_Reading.typ"
#include "chapter-9-Reflection_Models/chapter-9.11-Exercises.typ"


#include "chapter-10-Textures_and_Materials/chapter-10.0-Textures_and_Materials.typ"
#include "chapter-10-Textures_and_Materials/chapter-10.1-Texture_Sampling_and_Antialiasing.typ"
#include "chapter-10-Textures_and_Materials/chapter-10.2-Texture_Coordinate_Generation.typ"
#include "chapter-10-Textures_and_Materials/chapter-10.3-Texture_Interface_and_Basic_Textures.typ"
#include "chapter-10-Textures_and_Materials/chapter-10.4-Image_Texture.typ"
#include "chapter-10-Textures_and_Materials/chapter-10.5-Material_Interface_and_Implementations.typ"
#include "chapter-10-Textures_and_Materials/chapter-10.6-Further_Reading.typ"
#include "chapter-10-Textures_and_Materials/chapter-10.7-Exercises.typ"


#include "chapter-11-Volume_Scattering/chapter-11.0-Volume_Scattering.typ"
#include "chapter-11-Volume_Scattering/chapter-11.1-Volume_Scattering_Processes.typ"
#include "chapter-11-Volume_Scattering/chapter-11.2-Transmittance.typ"
#include "chapter-11-Volume_Scattering/chapter-11.3-Phase_Functions.typ"
#include "chapter-11-Volume_Scattering/chapter-11.4-Media.typ"
#include "chapter-11-Volume_Scattering/chapter-11.5-Further_Reading.typ"
#include "chapter-11-Volume_Scattering/chapter-11.6-Exercises.typ"


#include "chapter-12-Light_Sources/chapter-12.0-Light_Sources.typ"
#include "chapter-12-Light_Sources/chapter-12.1-Light_Interface.typ"
#include "chapter-12-Light_Sources/chapter-12.2-Point_Lights.typ"
#include "chapter-12-Light_Sources/chapter-12.3-Distant_Lights.typ"
#include "chapter-12-Light_Sources/chapter-12.4-Area_Lights.typ"
#include "chapter-12-Light_Sources/chapter-12.5-Infinite_Area_Lights.typ"
#include "chapter-12-Light_Sources/chapter-12.6-Light_Sampling.typ"
#include "chapter-12-Light_Sources/chapter-12.7-Further_Reading.typ"
#include "chapter-12-Light_Sources/chapter-12.8-Exercises.typ"


#include "chapter-13-Light_Transport_I_Surface_Reflection/chapter-13.0-Light_Transport_I_Surface_Reflection.typ"
#include "chapter-13-Light_Transport_I_Surface_Reflection/chapter-13.1-The_Light_Transport_Equation.typ"
#include "chapter-13-Light_Transport_I_Surface_Reflection/chapter-13.2-Path_Tracing.typ"
#include "chapter-13-Light_Transport_I_Surface_Reflection/chapter-13.3-A_Simple_Path_Tracer.typ"
#include "chapter-13-Light_Transport_I_Surface_Reflection/chapter-13.4-A_Better_Path_Tracer.typ"
#include "chapter-13-Light_Transport_I_Surface_Reflection/chapter-13.5-Further_Reading.typ"
#include "chapter-13-Light_Transport_I_Surface_Reflection/chapter-13.6-Exercises.typ"


#include "chapter-14-Light_Transport_II_Volume_Rendering/chapter-14.0-Light_Transport_II_Volume_Rendering.typ"
#include "chapter-14-Light_Transport_II_Volume_Rendering/chapter-14.1-The_Equation_of_Transfer.typ"
#include "chapter-14-Light_Transport_II_Volume_Rendering/chapter-14.2-Volume_Scattering_Integrators.typ"
#include "chapter-14-Light_Transport_II_Volume_Rendering/chapter-14.3-Scattering_from_Layered_Materials.typ"
#include "chapter-14-Light_Transport_II_Volume_Rendering/chapter-14.4-Further_Reading.typ"
#include "chapter-14-Light_Transport_II_Volume_Rendering/chapter-14.5-Exercises.typ"


#include "chapter-15-Wavefront_Rendering_on_GPUs/chapter-15.0-Wavefront_Rendering_on_GPUs.typ"
#include "chapter-15-Wavefront_Rendering_on_GPUs/chapter-15.1-Mapping_Path_Tracing_to_the_GPU.typ"
#include "chapter-15-Wavefront_Rendering_on_GPUs/chapter-15.2-Implementation_Foundations.typ"
#include "chapter-15-Wavefront_Rendering_on_GPUs/chapter-15.3-Path_Tracer_Implementation.typ"
#include "chapter-15-Wavefront_Rendering_on_GPUs/chapter-15.4-Further_Reading.typ"
#include "chapter-15-Wavefront_Rendering_on_GPUs/chapter-15.5-Exercises.typ"


#include "chapter-16-Retrospective_and_the_Future/chapter-16.0-Retrospective_and_the_Future.typ"
#include "chapter-16-Retrospective_and_the_Future/chapter-16.1-pbrt_over_the_Years.typ"
#include "chapter-16-Retrospective_and_the_Future/chapter-16.2-Design_Alternatives.typ"
#include "chapter-16-Retrospective_and_the_Future/chapter-16.3-Emerging_Topics.typ"
#include "chapter-16-Retrospective_and_the_Future/chapter-16.4-The_Future.typ"
#include "chapter-16-Retrospective_and_the_Future/chapter-16.5-Conclusion.typ"
#include "chapter-16-Retrospective_and_the_Future/chapter-16.6-Further_Reading.typ"

#counter(heading).update(0)
#set heading(numbering: "A.", supplement: [Appendix])
#include "Appendix-A-Sampling_Algorithms/A.0-Sampling_Algorithms.typ"
#include "Appendix-A-Sampling_Algorithms/A.1-The_Alias_Method.typ"
#include "Appendix-A-Sampling_Algorithms/A.2-Reservoir_Sampling.typ"
#include "Appendix-A-Sampling_Algorithms/A.3-The_Rejection_Method.typ"
#include "Appendix-A-Sampling_Algorithms/A.4-Sampling_1D_Functions.typ"
#include "Appendix-A-Sampling_Algorithms/A.5-Sampling_Multidimensional_Functions.typ"
#include "Appendix-A-Sampling_Algorithms/A.6-Further_Reading.typ"
#include "Appendix-A-Sampling_Algorithms/A.7-Exercises.typ"


#include "Appendix-B-Utilities/B.0-Utilities.typ"
#include "Appendix-B-Utilities/B.1-System_Startup,_Cleanup,_and_Options.typ"
#include "Appendix-B-Utilities/B.2-Mathematical_Infrastructure.typ"
#include "Appendix-B-Utilities/B.3-User_Interaction.typ"
#include "Appendix-B-Utilities/B.4-Containers_and_Memory_Management.typ"
#include "Appendix-B-Utilities/B.5-Images.typ"
#include "Appendix-B-Utilities/B.6-Parallelism.typ"
#include "Appendix-B-Utilities/B.7-Statistics.typ"
#include "Appendix-B-Utilities/B.8-Further_Reading.typ"
#include "Appendix-B-Utilities/B.9-Exercises.typ"


#include "Appendix-C-Processing_the_Scene_Description/C.0-Processing_the_Scene_Description.typ"
#include "Appendix-C-Processing_the_Scene_Description/C.1-Tokenizing_and_Parsing.typ"
#include "Appendix-C-Processing_the_Scene_Description/C.2-Managing_the_Scene_Description.typ"
#include "Appendix-C-Processing_the_Scene_Description/C.3-BasicScene_and_Final_Object_Creation.typ"
#include "Appendix-C-Processing_the_Scene_Description/C.4-Adding_New_Object_Implementations.typ"
#include "Appendix-C-Processing_the_Scene_Description/C.5-Further_Reading.typ"
#include "Appendix-C-Processing_the_Scene_Description/C.6-Exercises.typ"


// #include "chapter-20-References/chapter-20.0-References.typ"


// #include "chapter-21-Index_of_Fragments/chapter-21.0-Index_of_Fragments.typ"


// #include "chapter-22-Index_of_Identifiers/chapter-22.0-Index_of_Identifiers.typ"


// #bibliography("references.yaml")
#bibliography("bibliography.bib")