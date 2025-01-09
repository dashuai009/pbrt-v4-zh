#text(size: 14pt)[#upper[*about me*]]

#{
  if ("LANG_OUT" not in sys.inputs) or sys.inputs.LANG_OUT == "zh" {
    text(size: 18pt)[#upper[*译者序*]]
    par[
      本书（也就是仓库#link("https://www.github.com/dashuai009/pbrt-v4-zh")[pbrt-v4-zh]）由gpt翻译而来。
    ]
    par[
      本书使用 #link("https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh-hans")[知识共享署名—非商业性使用—相同方式共享4.0国际公共许可协议]
      进行许可。
    ]
    par[
      由 #link("https://github.com/Remyuu")[Remo] 修改格式并且润色译文。
    ]
    text(size: 18pt)[#upper[*翻译进度*]]
    par(spacing: 0.5em)[

      - Preface

        -- Audience // ✅ - 2025.1.9

        -- Overview and Goals

        -- Changes Between Editions

        -- Acknowledgments

        -- Production

        -- The Online Edition

        -- Scenes, Models, and Data

        -- About the Cover

        -- Further Reading

      - Introduction

        -- Literate Programming

        -- Photorealistic Rendering and the Ray-Tracing Algorithm

        -- pbrt: System Overview

        -- How to Proceed through This Book

        -- Using and Understanding the Code

        -- A Brief History of Physically Based Rendering

        -- Further Reading

        -- Exercises

      - Monte Carlo Integration

        -- Monte Carlo: Basics

        -- Improving Efficiency

        -- Sampling Using the Inversion Method

        -- Transforming between Distributions

        -- Further Reading

      - Geometry and Transformations

        -- Coordinate Systems

        -- n-Tuple Base Classes

        -- Vectors

        -- Points

        -- Normals

        -- Rays

        -- Bounding Boxes

        -- Spherical Geometry

        -- Transformations

        -- Applying Transformations

        -- Interactions

        -- Further Reading

        -- Exercises

      - Radiometry, Spectra, and Color

        -- Radiometry

        -- Working with Radiometric Integrals

        -- Surface Reflection

        -- Light Emission

        -- Representing Spectral Distributions

        -- Color

        -- Further Reading

        -- Exercises

      - Cameras and Film

        -- Camera Interface

        -- Projective Camera Models

        -- Spherical Camera

        -- Film and Imaging

        -- Further Reading

        -- Exercises

      - Shapes

        -- Basic Shape Interface

        -- Spheres

        -- Cylinders

        -- Disks

        -- Triangle Meshes

        -- Bilinear Patches

        -- Curves

        -- Managing Rounding Error

        -- Further Reading

        -- Exercises

      - Primitives and Intersection Acceleration

        -- Primitive Interface and Geometric Primitives

        -- Aggregates

        -- Bounding Volume Hierarchies

        -- Further Reading

        -- Exercises

      - Sampling and Reconstruction

        -- Sampling Theory

        -- Sampling and Integration

        -- Sampling Interface

        -- Independent Sampler

        -- Stratified Sampler

        -- Halton Sampler

        -- Sobol’ Samplers

        -- Image Reconstruction

        -- Further Reading

        -- Exercises

      - Reflection Models

        -- BSDF Representation

        -- Diffuse Reflection

        -- Specular Reflection and Transmission

        -- Conductor BRDF

        -- Dielectric BSDF

        -- Roughness Using Microfacet Theory

        -- Rough Dielectric BSDF

        -- Measured BSDF

        -- Scattering from Hair

        -- Further Reading

        -- Exercises

      - Textures and Materials

        -- Texture Sampling and Antialiasing

        -- Texture Coordinate Generation

        -- Texture Interface and Basic Textures

        -- Image Texture

        -- Material Interface and Implementations

        -- Further Reading

        -- Exercises

      - Volume Scattering

        -- Volume Scattering Processes

        -- Transmittance

        -- Phase Functions

        -- Media

        -- Further Reading

        -- Exercises

      - Light Sources

        -- Light Interface

        -- Point Lights

        -- Distant Lights

        -- Area Lights

        -- Infinite Area Lights

        -- Light Sampling

        -- Further Reading

        -- Exercises

      - Light Transport I: Surface Reflection

        -- The Light Transport Equation

        -- Path Tracing

        -- A Simple Path Tracer

        -- A Better Path Tracer

        -- Further Reading

        -- Exercises

      - Light Transport II: Volume Rendering

        -- The Equation of Transfer

        -- Volume Scattering Integrators

        -- Scattering from Layered Materials

        -- Further Reading

        -- Exercises

      - Wavefront Rendering on GPUs

        -- Mapping Path Tracing to the GPU

        -- Implementation Foundations

        -- Path Tracer Implementation

        -- Further Reading

        -- Exercises

      - Retrospective and the Future

        -- pbrt over the Years

        -- Design Alternatives

        -- Emerging Topics

    ]
  }
}
