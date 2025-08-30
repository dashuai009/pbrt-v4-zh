#import "../template.typ": parec, translator

== Adding New Object Implementations
<sec:adding-plugins>

#parec[
  To sum up various details that have been spread across multiple
  chapters, three main steps are required in order to add a new
  implementation of one of `pbrt`’s interface types:
][
  为了总结分散在多个章节中的各项细节，以下为为 `pbrt`
  的某个接口类型添加新实现所需的三个步骤：
]

#parec[
  + The source files containing its implementation need to be added to the
    appropriate places in `pbrt`’s top-level CMakeLists.txt file, or they
    should be added to an appropriate preexisting source file so that they
    are compiled into the `pbrt` binary.
][

  + 将实现所需的源文件加入 `pbrt` 顶层 CMakeLists.txt
    的合适位置，或合并到现有源文件中，以便将它们编译进 `pbrt` 二进制文件。

]

#parec[
  + The name of the type should be added to the list of types provided to
    the
    #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`]
    that the corresponding interface type inherits from; this can be done
    by editing the appropriate header file in the base/ directory.
][

  + 应将该类型的名称加入到该接口类型所继承的
    #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`]
    所提供的类型列表中（带标签指针，TaggedPointer）；可通过编辑 base/
    目录下的相应头文件来实现。

]

#parec[
  + The interface type’s `Create()` method should be modified to create an
    instance of the new type when it has been specified in the scene
    description.
][

  + 当在场景描述中指定了新类型时，应修改接口类型的 `Create()`
    方法以创建该新类型的实例。

]

#parec[
  It is probably a good idea to implement a static `Create()` method in
  the new type that takes a
  #link(
    "../Processing_the_Scene_Description/Managing_the_Scene_Description.html#ParameterDictionary",
  )[ParameterDictionary]
  and such, to specify the object’s parameters in the same way that the
  existing classes do, but doing so is not a requirement. \#\#
][
  也许一个更好的做法是在新类型中实现一个接收
  ParameterDictionary（参数字典，ParameterDictionary）的静态 `Create()`
  方法，以便按现有类的参数设置对象；当然，这并非强制要求。
]
