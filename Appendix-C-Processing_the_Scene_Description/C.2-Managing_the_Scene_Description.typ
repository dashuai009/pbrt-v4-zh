#import "../template.typ": parec

#parec[
  C.2 Managing the Scene Description

][
  C.2 场景描述的管理
]

#parec[
  `pbrt`’s scene description files allow the user to specify various
  properties that then apply to the definition of subsequent objects in
  the scene. One example is a current material. Once the current material
  is set, all subsequent shapes are assigned that material until it is
  changed. In addition to the material, the current transformation matrix,
  RGB color space, an area light specification, and the current media are
  similarly maintained. We will call this collective information the
  #emph[graphics state];. Tracking graphics state provides the advantage
  that it is not necessary to specify a material with every shape in the
  scene description, but it imposes the requirement that the scene
  processing code keep track of the current graphics state while the scene
  description is being parsed.

][
  `pbrt`
  的场景描述文件允许用户指定各种属性，这些属性随后应用于场景中后续对象的定义。其一例便是当前材质。一旦设置了当前材质，所有后续的形状都会被赋予该材质，直到重新更改为止。除了材质外，当前变换矩阵、RGB
  颜色空间、区域光照设定，以及当前介质也以类似方式维护。我们将这些集合信息称为图形状态（graphics
  state）。跟踪图形状态的优点在于在场景描述中无需对每个形状都指定材质，但它要求场景处理代码在解析场景描述时持续跟踪当前的图形状态。
]

#parec[
  Managing this graphics state is the primary task of the
  `BasicSceneBuilder`, which implements the interface defined by
  #link("../Processing_the_Scene_Description/Tokenizing_and_Parsing.html#ParserTarget")[ParserTarget];.
  Its implementation is in the files `scene.h` and `scene.cpp`. An initial
  `BasicSceneBuilder` is allocated at the start of parsing the scene
  description. Typically, it handles graphics state management for the
  provided scene description files. However, `pbrt`’s scene description
  format supports an `Import` directive that indicates that a file can be
  parsed in parallel with the file that contains it. (`Import` effectively
  discards any changes to the graphics state at the end of an imported
  file, which allows parsing of the current file to continue concurrently
  without needing to wait for the imported file.) A new
  `BasicSceneBuilder` is allocated for each imported file; it makes a copy
  of the current graphics state before parsing begins.

][
  管理这一图形状态是 `BasicSceneBuilder` 的主要任务，它实现了
  #link("../Processing_the_Scene_Description/Tokenizing_and_Parsing.html#ParserTarget")[ParserTarget]
  定义的接口。其实现位于 `scene.h` 和 `scene.cpp`
  文件中。在解析场景描述开始时会分配一个初始的
  `BasicSceneBuilder`。通常，它负责提供的场景描述文件的图形状态管理。然而，`pbrt`
  的场景描述格式支持一个 `Import`
  指令，表示一个文件可以与其中包含它的文件并行解析。（`Import`
  实质上会在导入文件结束时丢弃对图形状态的任何修改，这允许当前文件的解析在不需要等待导入文件的情况下并发继续。）每个导入的文件都会分配一个新的
  `BasicSceneBuilder`；它在解析开始前会复制当前的图形状态。
]

```
class BasicSceneBuilder : public ParserTarget {
  public:
    <<BasicSceneBuilder Public Methods>>
  private:
    <<BasicSceneBuilder::GraphicsState Definition>>
    <<BasicSceneBuilder Private Methods>>
    <<BasicSceneBuilder Private Members>>
};
```
#parec[
  As the entities in the scene are fully specified, they are passed along
  to an instance of the `BasicScene` class, which will be described in the
  next section. When parsing is being performed in parallel with multiple
  `BasicSceneBuilder`s, all share a single `BasicScene`.

][
  当场景中的实体被完全指定后，它们将被传递给 `BasicScene`
  类的一个实例，该类将在下一节中描述。当以多个 `BasicSceneBuilder`
  并行进行解析时，所有它们共享一个单独的 `BasicScene`。
]

```
BasicScene *scene;
```
#parec[
  In addition to storing a pointer to a `BasicScene`, the
  `BasicSceneBuilder` constructor sets a few default values so that if,
  for example, no camera is specified in the scene description, a basic 90
  degree perspective camera is used. The fragment that sets these values
  is not included here.

][
  除了存储对 `BasicScene` 的指针外，`BasicSceneBuilder`
  构造函数还设置了一些默认值，以便例如在场景描述中未指定相机时使用一个基本的
  90 度透视相机。设置这些值的代码片段未在此处包含。
]

```
BasicSceneBuilder::BasicSceneBuilder(BasicScene *scene)
    : scene(scene) {
    <<Set scene defaults>>
}
```
#parec[
  `pbrt` scene descriptions are split into sections by the `WorldBegin`
  statement. Before `WorldBegin` is encountered, it is legal to specify
  global rendering options including the camera, film, sampler, and
  integrator, but shapes, lights, textures, and materials cannot yet be
  specified. After `WorldBegin`, all of that flips: things like the camera
  specification are fixed, and the rest of the scene can be specified.
  Some scene description statements, like those that modify the current
  transformation or specify participating media, are allowed in both
  contexts.

][
  `pbrt` 的场景描述通过 WorldBegin 语句来分段。在遇到 WorldBegin
  之前，可以指定全局渲染选项（如相机、胶片（film）、采样器和积分器），但在此阶段不能指定形状、灯光、纹理和材质。WorldBegin
  之后，这些选项将被固定；而形状、灯光、纹理和材质等在这两种情境下仍然允许指定。某些场景描述语句，例如修改当前变换或指定参与介质的语句，在这两种情境下都是允许的。
]

#parec[
  This separation of information can help simplify the implementation of
  the renderer. For example, consider a spline patch shape that
  tessellates itself into triangles. This shape might compute the size of
  its triangles based on the area of the screen that it covers. If the
  camera’s position and the image resolution are fixed when the shape is
  created, then the shape can tessellate itself immediately at creation
  time.

][
  这信息的分离有助于简化渲染器的实现。例如，考虑一个自我将自身细分成三角形的样条补丁形状。该形状可能根据它覆盖的屏幕区域来计算其三角形的大小。如果在创建形状时相机的位置和图像分辨率已固定，则该形状可以在创建时就将自身细分为三角形。
]

#parec[
  An enumeration records which part of the scene description is currently
  being specified. Two macros that are not included here,
  `VERIFY_OPTIONS()` and `VERIFY_WORLD()`, check the current block against
  the one that is expected and issue an error if there is a mismatch.

][
  一个枚举记录当前正在指定场景描述的哪一部分。两个未在此处给出的宏
  `VERIFY_OPTIONS()` 和 `VERIFY_WORLD()`
  用于将当前块与预期块对照，如不匹配则报告错误。
]

```
enum class BlockState { OptionsBlock, WorldBlock };
BlockState currentBlock = BlockState::OptionsBlock;
```
=== Scene Entities
<c.2.1-scene-entities>


#parec[
  Before further describing the `BasicSceneBuilder`’s operation, we will
  start by describing the form of its output, which is a high-level
  representation of the parsed scene. In this representation, all the
  objects in the scene are represented by various #emph[Entity] classes.

][
  在进一步描述 `BasicSceneBuilder`
  的运作之前，我们先描述其输出的形式，即对已解析场景的高级表示。在这一表示中，场景中的所有对象都由各种
  #emph[Entity] 类表示。
]

#parec[
  `SceneEntity` is the simplest of them; it records the name of the entity
  (e.g., "rgb" or "gbuffer" for the film), the file location of the
  associated statement in the scene description, and any user-provided
  parameters. It is used for the film, sampler, integrator, pixel filter,
  and accelerator, and is also used as a base class for some of the other
  scene entity types.

][
  `SceneEntity` 是其中最简单的；它记录实体的名称（例如，用于胶片（film）或
  gb uffer
  的名称），在场景描述中相关语句的文件位置，以及用户提供的参数。它用于胶片、采样器、积分器、像素滤镜和加速器，并且也是其他一些场景实体类型的基类。
]

```
struct SceneEntity {
    <<SceneEntity Public Methods>>
    <<SceneEntity Public Members>>
};
```
#parec[
  All the scene entity objects use `InternedString`s for any string member
  variables to save memory when strings are repeated. (Often many are,
  including frequently used shape names like "trianglemesh" and the names
  of object instances that are used repeatedly.)

][
  所有场景实体对象的字符串成员均使用
  InternedString（字符串驻留，常译为字符串池化）以在重复出现字符串时节省内存。（通常有很多字符串重复出现，包括经常使用的形状名称如“trianglemesh”以及反复使用的对象实例名称。）
]

```
InternedString name;
FileLoc loc;
ParameterDictionary parameters;
```
#parec[
  A single `InternCache<std::string>` defined as a public static member in
  `SceneEntity` is used for all string interning in this part of the
  system.

][
  SceneEntity 的一个公有静态成员，类型为
  InternCache，用于本系统这一部分所有字符串的内部化（interning）。
]

```
static InternCache<std::string> internedStrings;
```
#parec[
  Other entity types include the `CameraSceneEntity`, `LightSceneEntity`,
  `TextureSceneEntity`, `MediumSceneEntity`, `ShapeSceneEntity`, and
  `AnimatedShapeSceneEntity`. All have the obvious roles. There is
  furthermore an `InstanceDefinitionSceneEntity`, which represents an
  instance definition, and `InstanceSceneEntity`, which represents the use
  of an instance definition. We will not include the definitions of these
  classes in the text as they are all easily understood from their
  definitions in the source code.

][
  其他实体类型包括
  `CameraSceneEntity`、`LightSceneEntity`、`TextureSceneEntity`、`MediumSceneEntity`、`ShapeSceneEntity`
  和 `AnimatedShapeSceneEntity`。它们都具有明显的作用。此外还有一个
  `InstanceDefinitionSceneEntity`，表示一个实例定义，以及
  `InstanceSceneEntity`，表示对实例定义的使用。此外还包括一个
  InstanceDefinitionSceneEntity 表示一个实例定义，以及 InstanceSceneEntity
  表示对实例定义的使用。我们不会在文中重复给出这些类的定义，因为在源代码中它们的定义很容易理解。
]

=== Parameter Dictionaries
<c.2.2-parameter-dictionaries>

#parec[
  Most of the scene entity objects store lists of associated parameters
  from the scene description file. While the `ParsedParameter` is a
  convenient representation for the parser to generate, it does not
  provide capabilities for checking the validity of parameters or for
  easily extracting parameter values. To that end, `ParameterDictionary`
  adds both semantics and convenience to vectors of `ParsedParameter`s.
  Thus, it is the class that is used for `SceneEntity::parameters`.

][
  大多数场景实体对象存储的是来自场景描述文件的相关参数列表。尽管
  ParsedParameter
  对解析器来说是一个方便的表示，但它并不提供检查参数有效性或轻松提取参数值的能力。为此，ParameterDictionary
  为 ParsedParameter 向量增加了语义性和便捷性。因此，它是用于
  SceneEntity::parameters 的类。
]

```
class ParameterDictionary {
  public:
    <<ParameterDictionary Public Methods>>
  private:
    <<ParameterDictionary Private Methods>>
    <<ParameterDictionary Private Members>>
};
```
#parec[
  Its constructor takes both a `ParsedParameterVector` and an
  RGBColorSpace that defines the color space of any RGB-valued parameters.

][
  其构造函数同时接收一个 `ParsedParameterVector` 和一个定义 RGB
  值参数颜色空间的 RGBColorSpace。
]

```
ParameterDictionary(ParsedParameterVector params,
                    const RGBColorSpace *colorSpace);
```
#parec[
  It directly stores the provided `ParsedParameterVector`; no
  preprocessing of it is performed in the constructor—for example, to sort
  the parameters by name or to validate that the parameters are valid. An
  implication of this is that the following methods that look up parameter
  values have upper O(n) time complexity in the total number of
  parameters. For the small numbers of parameters that are provided in
  practice, this inefficiency is not a concern.

][
  它直接保存所提供的
  `ParsedParameterVector`，在构造时不做预处理（如按名称排序或验证参数有效性），因此查找参数值的时间复杂度上限为
  O(n)。在实际使用中，参数数量通常较少，因此这点低效并不构成问题。
]


```
ParsedParameterVector params;
const RGBColorSpace *colorSpace = nullptr;

```
#parec[
  A ParameterDictionary can hold eleven types of parameters: Booleans,
  integers, floating-point values, points (2D and 3D), vectors (2D and
  3D), normals, spectra, strings, and the names of Textures that are used
  as parameters for Materials and other Textures.

][
  ParameterDictionary 可以包含十一类参数：布尔值、整数、浮点值、点（2D 和
  3D）、向量（2D 和
  3D）、法向量、光谱、字符串，以及用作材料和其他纹理参数的纹理名称（Texture）。
]

```
enum class ParameterType {
    Boolean,  Float,    Integer,  Point2f, Vector2f, Point3f,
    Vector3f, Normal3f, Spectrum, String,  Texture
};

```
#parec[
  For each parameter type, there is a method for looking up parameters
  that have a single data value. Here are the declarations of a few:

][
  对于每种参数类型，存在一个用于查找只有单个数据值的参数的方法。下面给出其中的一些声明：
]

```
Float GetOneFloat(const std::string &name, Float def) const;
int GetOneInt(const std::string &name, int def) const;
bool GetOneBool(const std::string &name, bool def) const;
std::string GetOneString(const std::string &name,
                         const std::string &def) const;

```
#parec[
  These methods all take the name of the parameter and a default value. If
  the parameter is not found, the default value is returned. This makes it
  easy to write initialization code like:

][
  这些方法都以参数名和默认值作为输入。如果未找到该参数，将返回默认值。这使得编写初始化代码变得容易，例如：
]

```
    Point3f center = params.GetOnePoint3f("center", Point3f(0, 0, 0));

```
#parec[
  The single value lookup methods for the other types follow the same form
  and so their declarations are not included here.

][
  其他类型的单值查找方法遵循相同的形式，因此这里不包含它们的声明。
]

#parec[
  In contrast, if calling code wants to detect a missing parameter and
  issue an error, it should instead use the corresponding parameter array
  lookup method, which returns an empty vector if the parameter is not
  present. (Those methods will be described in a few pages.)

][
  相反地，如果调用代码需要检测缺失的参数并报告错误，则应改用相应的参数数组查找方法；如果参数不存在，该方法返回一个空向量。（这些方法将在后面的几页中描述。）
]

#parec[
  For parameters that represent spectral distributions, it is necessary to
  specify if the spectrum represents an illuminant, a reflectance that is
  bounded between 0 and 1, or is an arbitrary spectral distribution (e.g.,
  a scattering coefficient). In turn, if a parameter has been specified
  using RGB color, the appropriate one of RGBIlluminantSpectrum,
  RGBAlbedoSpectrum, or RGBUnboundedSpectrum is used for the returned
  Spectrum.

][
  对于表示光谱分布的参数，有必要指明该光谱所代表的意义：光源光谱（Illuminant，Illuminant）、在
  0～1
  之间有界的反照率（Albedo，Albedo）还是任意光谱分布（Unbounded，Unbounded）。如果参数以
  RGB 颜色指定，则返回的 Spectrum 将对应使用
  RGBIlluminantSpectrum、RGBAlbedoSpectrum 或 RGBUnboundedSpectrum 之一。
]

```
Spectrum GetOneSpectrum(const std::string &name,
    Spectrum def, SpectrumType spectrumType, Allocator alloc) const;

```

```
enum class SpectrumType { Illuminant, Albedo, Unbounded };

```
#parec[
  The parameter lookup methods make use of C++ type traits, which make it
  possible to associate additional information with specific types that
  can then be accessed at compile time via templates. This approach allows
  succinct implementations of the lookup methods. Here we will discuss the
  corresponding implementation for Point3f-valued parameters; the other
  types are analogous.

][
  参数查找方法使用了 C++ 的类型特征（type
  traits），这使得能够将附加信息与特定类型相关联，并可在编译时通过模板访问。这样的方法实现更加简洁。下面我们将讨论针对
  Point3f 值参数的实现；其他类型类似。
]

#parec[
  The implementation of GetOnePoint3f() requires a single line of code to
  forward the request on to the lookupSingle() method.

][
  GetOnePoint3f() 的实现只需要一行代码即可将请求转发到 lookupSingle()
  方法。
]

```
Point3f ParameterDictionary::GetOnePoint3f(const std::string &name,
                                           Point3f def) const {
    return lookupSingle<ParameterType::Point3f>(name, def);
}

```
#parec[
  The following signature of the lookupSingle() method alone has brought
  us into the realm of template-based type information. lookupSingle() is
  itself a template method, parameterized by an instance of the
  ParameterType enumeration. In turn, we can see that another template
  class, ParameterTypeTraits, not yet defined, is expected to provide the
  type ReturnType, which is used for both lookupSingle’s return type and
  the provided default value.

][
  以下仅包含 lookupSingle()
  方法签名本身，它将我们带入了基于模板的类型信息领域。lookupSingle()
  本身是一个模板方法，以 ParameterType
  枚举的一个实例参数化。反过来，我们可以看到另一个模板类
  ParameterTypeTraits（尚未定义）需要提供 ReturnType 类型，该类型用于
  lookupSingle 的返回类型以及提供的默认值。
]

```
template <ParameterType PT>
typename ParameterTypeTraits<PT>::ReturnType
ParameterDictionary::lookupSingle(const std::string &name,
        typename ParameterTypeTraits<PT>::ReturnType defaultValue) const {
    <<Search params for parameter name>>
    return defaultValue;
}

```
#parec[
  Each of the parameter types in the ParameterType enumeration has a
  ParameterTypeTraits template specialization. Here is the one for
  Point3f:

][
  ParameterType 枚举中的每种参数类型都具有一个类型特征模板特化。下面给出
  Point3f 的一个示例：
]

```
template <>
struct ParameterTypeTraits<ParameterType::Point3f> {
    <<ParameterType::Point3f Type Traits>>;
};

```
#parec[
  All the specializations provide a type definition for ReturnType.
  Naturally, the ParameterType::Point3f specialization uses Point3f for
  ReturnType.

][
  所有特化都提供 ReturnType 的类型定义。自然地，ParameterType::Point3f
  的特化使用 Point3f 作为 ReturnType。
]

```
using ReturnType = Point3f;

```
#parec[
  Type traits also provide the string name for each type.

][
  类型特征还提供每种类型的字符串名称。
]

```
static constexpr char typeName[] = "point3";

```
#parec[
  In turn, the search for a parameter checks not only for the specified
  parameter name but also for a matching type string.

][
  反过来，对参数的搜索不仅会检查指定的参数名，还会检查匹配的类型字符串。
]

```
using traits = ParameterTypeTraits<PT>;
for (const ParsedParameter *p : params) {
    if (p->name != name || p->type != traits::typeName)
        continue;
    <<Extract parameter values from p>>
    <<Issue error if an incorrect number of parameter values were provided>>
    <<Return parameter values as ReturnType>>
}

```
#parec[
  A static GetValues() method in each type traits template specialization
  returns a reference to one of the floats, ints, strings, or bools
  ParsedParameter member variables. Note that using auto for the
  declaration of values makes it possible for this code in lookupSingle()
  to work with any of those.

][
  在每种类型特征模板特化中，静态 GetValues() 方法返回对 ParsedParameter
  成员变量中浮点数、整数、字符串或布尔值之一的引用。请注意，在 GetValues()
  的声明中使用 auto，使得 lookupSingle()
  中的这段代码能够与上述任意类型一起工作（其中之一）。
]

```
const auto &values = traits::GetValues(*p);

```
#parec[
  For Point3f parameters, the parameter values are floating-point.

][
  对于 Point3f 参数，参数值由三个浮点数表示。
]

```
static const auto &GetValues(const ParsedParameter &param) {
    return param.floats;
}

```
#parec[
  Another trait, nPerItem, provides the number of individual values
  associated with each parameter. In addition to making it possible to
  check that the right number of values were provided in the GetOne\*()
  methods, this value is also used when parsing arrays of parameter
  values.

][
  另一个特征 nPerItem 提供与每个参数相关联的值的数量。除了使在 GetOne\*()
  方法中能够检查提供的值数量是否正确之外，该值在解析参数值的数组时也会被使用。
]

```
static constexpr int nPerItem = 3;

```
#parec[
  For each Point3f, three values are expected.

][
  对于每个 Point3f，都应包含 3 个值。
]


```
static constexpr int nPerItem = 3;

```
#parec[
  Finally, a static Convert() method in the type traits specialization
  takes care of converting from the raw values to the returned parameter
  type. At this point, the fact that the parameter was in fact used is
  also recorded.

][
  同时会记录该参数已实际被使用的事实。
]

```
p->lookedUp = true;
return traits::Convert(values.data(), &p->loc);

```
#parec[
  The Convert() method converts the parameter values, starting at a given
  location, to the return type. When arrays of values are returned, this
  method is called once per returned array element, with the pointer
  incremented after each one by the type traits nPerItem value. The
  current FileLoc is passed along to this method in case any errors need
  to be reported.

][
  Convert()
  方法将参数值从给定的位置开始转换为返回类型。当返回的是数组时，该方法会对数组中的每个元素调用一次，并在每次调用后按
  nPerItem 的步长递增指针（当前 FileLoc
  将传递给该方法以便在需要报告错误时使用）。
]


```
static Point3f Convert(const Float *f, const FileLoc *loc) {
    return Point3f(f[0], f[1], f[2]);
}

```
#parec[
  Implementing the parameter lookup methods via type traits is more
  complex than implementing each one directly would be. However, this
  approach has the advantage that each additional parameter type
  effectively only requires defining an appropriate ParameterTypeTraits
  specialization, which is just a few lines of code. Further, that
  additional code is mostly declarative, which in turn is easier to verify
  as correct than multiple independent implementations of parameter
  processing logic.

][
  通过类型特征实现参数查找方法比直接逐个实现要复杂。然而，这种方法的优点在于每增加一个参数类型基本只需定义一个合适的
  ParameterTypeTraits 特化，且这只是几行代码。
  更进一步的是，额外的代码大多是声明性的，因此比多份独立实现的参数处理逻辑更易于验证正确。
]

#parec[
  The second set of parameter lookup functions returns an array of values.
  An empty vector is returned if the parameter is not found, so no default
  value need be provided by the caller. Here are the declarations of a few
  of them. The rest are equivalent, though GetSpectrumArray() also takes a
  SpectrumType and an Allocator to use for allocating any returned
  Spectrum values.

][
  第二组参数查找函数返回一个值的数组。如果未找到参数，则返回一个空向量，因此调用方无需提供默认值。下面给出其中一些的声明。其余的声明等价，尽管
  GetSpectrumArray() 还需要一个 SpectrumType 和一个用于为返回的 Spectrum
  值分配内存的 Allocator。
]


```
std::vector<Float> GetFloatArray(const std::string &name) const;
std::vector<int> GetIntArray(const std::string &name) const;
std::vector<uint8_t> GetBoolArray(const std::string &name) const;

```
#parec[
  We will not include the implementations of any of the array lookup
  methods or the type traits for the other parameter types here. We also
  note that the methods corresponding to Spectrum parameters are more
  complex than the other ones, since spectral distributions may be
  specified in a number of different ways, including as RGB colors,
  blackbody emission temperatures, and spectral distributions stored in
  files; see the source code for details.

][
  我们不会在此包含任何数组查找方法的实现，或其他参数类型的类型特征。我们还注意到，与
  Spectrum
  参数对应的方法比其他参数更复杂，因为光谱分布可能以多种不同方式指定，包括作为
  RGB 颜色、黑体发射温度，以及存储在文件中的光谱分布；具体请查看源代码。
]

#parec[
  Finally, because the user may misspell parameter names in the scene
  description file, the ParameterDictionary also provides a ReportUnused()
  function that issues an error if any of the parameters present were
  never looked up; the assumption is that in that case the user has
  provided an incorrect parameter. (This check is based on the values of
  the ParsedParameter::lookedUp member variables.)

][
  最后，由于用户在场景描述文件中可能拼写错参数名，ParameterDictionary
  还提供一个 ReportUnused()
  函数，当存在的某些参数从未被查找时会发出错误；假设在这种情况下用户提供了错误的参数。
  （此检查基于 ParsedParameter::lookedUp 成员变量的值。）
]


```
void ReportUnused() const;

```


=== Tracking Graphics State
<c.2.3-tracking-graphics-state>


#parec[
  All the graphics state managed by the BasicSceneBuilder is stored in an
  instance of the GraphicsState class.

][
  由 BasicSceneBuilder 管理的所有图形状态存储在 GraphicsState
  类的一个实例中。
]

```
struct GraphicsState {
    <<GraphicsState Public Methods>>
    <<GraphicsState Public Members>>
};

```
#parec[
  A GraphicsState instance is maintained in a member variable.

][
  一个 GraphicsState 的实例保存在一个成员变量中。
]


```
GraphicsState graphicsState;

```
#parec[
  There is usually not much to do when a statement that modifies the
  graphics state is encountered in a scene description file. Here, for
  example, is the implementation of the method that is called when the
  ReverseOrientation statement is parsed. This statement is only valid in
  the world block, so that state is checked before the graphics state’s
  corresponding variable is updated.

][
  在场景描述文件中遇到修改图形状态的语句时通常不需要做太多工作。这里，例如，展示了在解析
  ReverseOrientation 语句时所调用的方法的实现。此语句仅在 world
  块中有效，因此在更新图形状态的相应变量之前会进行状态检查。
]

```
void BasicSceneBuilder::ReverseOrientation(FileLoc loc) {
    VERIFY_WORLD("ReverseOrientation");
    graphicsState.reverseOrientation = !graphicsState.reverseOrientation;
}

```


```
bool reverseOrientation = false;

```
#parec[
  The current RGB color space can be specified in both the world and
  options blocks, so there is no need to check the value of currentBlock
  in the corresponding method.

][
  当前的 RGB 颜色空间可以在 world 块和 options
  块中指定，因此在相应的方法中无需检查 currentBlock 的值。
]

```
void BasicSceneBuilder::ColorSpace(const std::string &name, FileLoc loc) {
    if (const RGBColorSpace *cs = RGBColorSpace::GetNamed(name))
        graphicsState.colorSpace = cs;
    else
        Error(&loc, "%s: color space unknown", name);
}

```


```
const RGBColorSpace *colorSpace = RGBColorSpace::sRGB;

```
#parec[
  Many of the other method implementations related to graphics state
  management are similarly simple, so we will only include a few of the
  interesting ones in the following.

][
  许多与图形状态管理相关的其他方法实现也同样简单，因此在下文中我们仅包含一些有趣的实现。
]

==== Managing Transformations
<managing-transformations>


#parec[
  The current transformation matrix (CTM) is a widely used part of the
  graphics state. Initially the identity matrix, the CTM is modified by
  statements like Translate and Scale in scene description files. When
  objects like shapes and lights are defined, the CTM gives the
  transformation between their object coordinate system and world space.

][
  当前变换矩阵（CTM）是图形状态中广泛使用的部分。最初为单位矩阵，CTM
  通过场景描述文件中的 Translate 和 Scale
  等语句进行修改。当定义形状和光源等对象时，CTM
  给出它们的对象坐标系统与世界坐标之间的变换。
]

#parec[
  The current transformation matrix is actually a pair of transformation
  matrices, each one specifying a transformation at a specific time. If
  the transformations are different, then they describe an animated
  transformation. A number of methods are available to modify one or both
  of the CTMs as well as to specify the time associated with each one.

][
  当前的变换矩阵实际上是一对变换矩阵，每一个在特定时间点描述一个变换。如果这两者的变换不同，则描述一个动画变换。提供了多种方法来修改其中一个或两个
  CTM，并为每个 CTM 指定相关时间。
]

#parec[
  GraphicsState stores these two CTMs in a ctm member variable. They are
  represented by a TransformSet, which is a simple utility class that
  stores an array of transformations and provides some routines for
  managing them. Its methods include an operator\[\] for indexing into the
  Transforms, an Inverse() method that returns a TransformSet that is the
  inverse, and IsAnimated(), which indicates whether the two Transforms
  differ from each other.

][
  GraphicsState 将这两个 CTM 存储在一个 ctm 成员变量中。它们由一个
  TransformSet,
  这是一个简单的工具类，用于存储一组变换并提供用于管理它们的一些例程。它的方法包括一个
  operator\[\] 用于对 Transform 进行索引、一个返回其逆的 Inverse()
  方法，以及 IsAnimated(), 用于指示这两个 Transform 是否彼此不同。
]

#parec[
  The activeTransformBits member variable is a bit-vector indicating which
  of the CTMs are active; the active Transforms are updated when the
  transformation-related API calls are made, while the others are
  unchanged. This mechanism allows the user to selectively modify the CTMs
  in order to define animated transformations.

][
  activeTransformBits 成员变量是一个位向量，用于指示哪些 CTM
  是活动的；在进行与变换相关的 API 调用时，活动的 Transform
  会被更新，而其他的保持不变。 这一机制允许用户有选择地修改
  CTM，以定义动画变换。
]

```
TransformSet ctm;
uint32_t activeTransformBits = AllTransformsBits;

```



#parec[
  static constexpr int StartTransformBits = 1 \<\< 0; static constexpr int
  EndTransformBits = 1 \<\< 1; static constexpr int AllTransformsBits = (1
  \<\< MaxTransforms) - 1;

][
  当前仅支持两种变换。 本附录末尾的一个练习基于放宽这一约束。
]

```
constexpr int MaxTransforms = 2;
```
#parec[
  The methods that are called when a change to the current transformation
  is specified in the scene description are all simple. Because the CTM is
  used for both the rendering options and the scene description sections,
  there is no need to check the value of `currentBlock` in them. Here is
  the method called for the `Identity` statement, which sets the CTM to
  the identity transform.

][
  在场景描述中指定对当前 CTM 的更改时被调用的方法都是简单的。 由于 CTM
  同时用于渲染选项和世界坐标系的场景描述部分，因此在它们中无需检查
  `currentBlock` 的值。 下面是为 `Identity` 语句调用的方法，该语句将 CTM
  设置为单位变换。
]

```
void BasicSceneBuilder::Identity(FileLoc loc) {
    graphicsState.ForActiveTransforms(
        [](auto t) { return pbrt::Transform(); });
}
```
#parec[
  ForActiveTransforms() is a convenience method that encapsulates the
  logic for determining which of the CTMs is active and for passing their
  current value to a provided function that returns the updated
  transformation.

][
  ForActiveTransforms() 是一个便捷的方法，封装了判断哪些 CTM
  处于活动状态的逻辑，并将它们当前的变换值传递给一个回调函数，以获得更新后的变换。
]

```
template <typename F>
void ForActiveTransforms(F func) {
    for (int i = 0; i < MaxTransforms; ++i)
        if (activeTransformBits & (1 << i)) ctm[i] = func(ctm[i]);
}
```
#parec[
  Translate() postmultiplies the active CTMs with specified translation
  transformation.

][
  Translate() 将活动 CTM 与指定的平移变换做后乘运算。
]

```
void BasicSceneBuilder::Translate(Float dx, Float dy, Float dz,
                                  FileLoc loc) {
    graphicsState.ForActiveTransforms(
        [=](auto t) { return t * pbrt::Translate(Vector3f(dx, dy, dz)); });
}
```
#parec[
  The rest of the transformation methods are similarly defined, so we will
  not show their definitions here.

][
  其余变换方法的定义与此相同，因此此处不再赘述。
]

#parec[
  RenderFromObject() is a convenience method that returns the
  rendering-from-object transformation for the specified transformation
  index. It is called, for example, when a shape is specified. In the
  world specification block, the CTM specifies the world-from-object
  transformation, but because `pbrt` performs rendering computation in a
  separately defined rendering coordinate system (recall Section 5.1.1),
  the rendering-from-world transformation must be included to get the full
  transformation.

][
  RenderFromObject()
  是一个便捷的方法，返回指定变换索引的从对象到渲染坐标系的变换。
  例如在指定形状时会被调用。 在世界坐标系的规范块中，CTM
  指定了从对象到世界的变换，但由于 pbrt
  在一个单独定义的渲染坐标系中执行渲染计算（回顾 第 5.1.1
  节），因此必须包含从世界到渲染坐标系的变换以得到完整的变换。
]

```
class Transform RenderFromObject(int index) const {
    return pbrt::Transform((renderFromWorld *
                            graphicsState.ctm[index]).GetMatrix());
}
```
#parec[
  The camera-from-world transformation is given by the CTM when the camera
  is specified in the scene description. `renderFromWorld` is therefore
  set in the `BasicSceneBuilder::Camera()` method (not included here), via
  a call to the `CameraTransform::RenderFromWorld()` method with the
  `CameraTransform` for the camera.

][
  相机到世界的变换由 CTM 在场景描述中指定的相机提供。
  因此，renderFromWorld 通过 BasicSceneBuilder::Camera()
  方法设置（此处未给出），并通过对相机的 CameraTransform 使用
  CameraTransform::RenderFromWorld() 方法来完成设置。
]

```
class Transform renderFromWorld;

```
#parec[
  AnimatedTransform RenderFromObject() const { return
  {RenderFromObject(0), graphicsState.transformStartTime,
  RenderFromObject(1), graphicsState.transformEndTime}; }

][
  AnimatedTransform RenderFromObject() const { return
  {RenderFromObject(0), graphicsState.transformStartTime,
  RenderFromObject(1), graphicsState.transformEndTime}; }
]

```
AnimatedTransform RenderFromObject() const {
    return {RenderFromObject(0), graphicsState.transformStartTime,
            RenderFromObject(1), graphicsState.transformEndTime};
}
```
#parec[
  Float transformStartTime = 0, transformEndTime = 1;

][
  Float transformStartTime = 0, transformEndTime = 1;
]

```
Float transformStartTime = 0, transformEndTime = 1;
```
#parec[
  A final issue related to Transforms is minimizing their storage costs.
  In the usual case of using 32-bit floats for `pbrt`’s Float type, each
  Transform class instance uses 128 bytes of memory. Because the same
  transformation may be applied to many objects in the scene, it is
  worthwhile to reuse the same Transform for all of them when possible.
  The InternCache helps with this task, allocating and storing a single
  Transform for each unique transformation that is passed to its
  `Lookup()` method. In turn, classes like Shape implementations are able
  to save memory by storing just a const Transform \* rather than a full
  Transform.

][
  与 Transform 相关的最后一个问题是尽量降低它们的存储成本。 在通常使用 32
  位浮点数作为 `pbrt` 的 Float 类型的情况下，每个 Transform 类实例占用 128
  字节内存。
  由于同一变换可能被应用到场景中的许多对象，因此在可能的情况下重复使用相同的
  Transform 是值得的。 InternCache 有助于完成这项任务，为传递给其
  `Lookup()` 方法的每一个唯一变换分配并存储一个 Transform。 反过来，像
  Shape 实现这样的类可以通过仅存储一个 const Transform \* 而不是完整的
  Transform 来节省内存。
]

```
InternCache<class Transform> transformCache;
```
==== Hierarchical Graphics State
<hierarchical-graphics-state>

#parec[
  When specifying the scene, it is useful to be able to make a set of
  changes to the graphics state, instantiate some scene objects, and then
  roll back to an earlier graphics state. For example, one might want to
  specify a base transformation to position a car model in a scene and
  then to use additional transformations relative to the initial one to
  place the wheels, the seats, and so forth. A convenient way to do this
  is via a stack of saved GraphicsState objects: the user can specify that
  the current graphics state should be copied and pushed on the stack and
  then later specify that the current state should be replaced with the
  state on the top of the stack.

][
  当指定场景时，能够对图形状态进行一组修改、实例化一些场景对象，然后回滚到较早的图形状态，是很有用的。
  例如，可能希望指定一个基变换来在场景中定位一辆汽车模型，然后使用相对于初始变换的附加变换来放置车轮、座椅等。
  一种方便的做法是通过保存的 GraphicsState
  对象栈：用户可以指定当前图形状态应当被复制并推入栈中，随后再指定应将当前状态替换为栈顶状态。
]

#parec[
  This stack is managed by the `AttributeBegin` and `AttributeEnd`
  statements in `pbrt`’s scene description files. The former saves the
  current graphics state and the latter restores the most recent saved
  state.

][
  该栈由 `pbrt` 的场景描述文件中的 `AttributeBegin` 和 `AttributeEnd`
  语句管理。 前者保存当前图形状态，后者还原最近保存的状态。
]

#parec[
  Thus, a scene description file might contain the following:

][
  因此，场景描述文件可能包含以下内容：
]

```
Material "diffuse"
AttributeBegin
  Material "dielectric"
  Translate 5 0 0
  Shape "sphere" "float radius" [ 1 ]
AttributeEnd
Shape "sphere" "float radius" [ 1 ]
```
#parec[
  The first sphere is affected by the translation and is bound to the
  dielectric material, while the second sphere is diffuse and is not
  translated.

][
  第一个球体受平移影响并绑定到介电材料，而第二个球体是漫射的，未被平移。
]

```
void BasicSceneBuilder::AttributeBegin(FileLoc loc) {
    VERIFY_WORLD("AttributeBegin");
    pushedGraphicsStates.push_back(graphicsState);
}
```
```
std::vector<GraphicsState> pushedGraphicsStates;
```
```
void BasicSceneBuilder::AttributeEnd(FileLoc loc) {
    VERIFY_WORLD("AttributeEnd");
    <<Issue error on unmatched AttributeEnd>>
    graphicsState = std::move(pushedGraphicsStates.back());
    pushedGraphicsStates.pop_back();
}
```

=== Creating Scene Elements
<creating-scene-elements>


#parec[
  As soon as an entity in the scene is fully specified,
  `BasicSceneBuilder` passes its specification on to the `BasicScene` in
  the processing pipeline. It is thus possible to immediately begin
  construction of the associated object that is used for rendering even as
  parsing the rest of the scene description continues. For brevity, in
  this section and in Section 5 we will only discuss how this process
  works for Samplers and for the Medium objects that represent
  participating media. (Those two are representative of how the rest of
  the scene objects are handled.)

][
  一旦场景中的某个实体被完全指定，`BasicSceneBuilder`
  就会将其规范传递给处理管线中的 `BasicScene`。
  因此，在继续解析其余场景描述的同时，也可以立即开始构建用于渲染的相关对象。
  为简要起见，在本节及第 5
  节中，我们将只讨论该过程如何作用于采样器（Samplers）以及表示参与介质的
  Medium 对象。这两者代表了其余场景对象的处理方式。
]


#parec[
  When a `Sampler` statement is parsed in the scene description, the
  following `Sampler()` method is called by the parser. All that needs to
  be done is to record the sampler’s name and parameters; because the
  sampler may be changed by a subsequent `Sampler` statement in the scene
  description, it should not immediately be passed along to the
  #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[BasicScene];.

][
  当场景描述中出现 `Sampler` 语句时，解析器将调用下面的 `Sampler()`
  方法。所需要做的只是记录采样器的名称和参数；因为在场景描述中随后的
  `Sampler` 语句可能会改变采样器，因此不应立即将其传递给
  #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[BasicScene];。
]


```
void BasicSceneBuilder::Sampler(const std::string &name,
        ParsedParameterVector params, FileLoc loc) {
    ParameterDictionary dict(std::move(params), graphicsState.colorSpace);
    VERIFY_OPTIONS("Sampler");
    sampler = SceneEntity(name, std::move(dict), loc);
}
```
#parec[
  BasicSceneBuilder holds on to a `SceneEntity` for the sampler in a
  member variable until its value is known to be final.

][
  BasicSceneBuilder 将用于采样器的 `SceneEntity`
  保存在一个成员变量中，直到其值被确认为最终值。
]



```
SceneEntity sampler;
```
#parec[
  Once the WorldBegin statement is parsed, the sampler, camera, film,
  pixel filter, accelerator, and integrator are all set; they cannot be
  subsequently changed. Thus, when the parser calls the WorldBegin()
  method of `BasicSceneBuilder`, each corresponding `SceneEntity` can be
  passed along to the
  #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[BasicScene];.
  (This method also does some maintenance of the graphics state, resetting
  the CTM to the identity transformation and handling other details; that
  code is not included here.)

][
  一旦 WorldBegin
  语句被解析，采样器、相机、胶片、像素滤镜、加速器和积分器就会被设置好；之后它们将不能再被修改。因此，当解析器调用
  `BasicSceneBuilder` 的 WorldBegin() 方法时，对应的每个 `SceneEntity`
  就可以传递给
  #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[BasicScene];。
  (该方法也对图形状态进行一些维护，将 CTM
  重置为单位变换并处理其他细节；这里不包含这些代码。）
]


```
void BasicSceneBuilder::WorldBegin(FileLoc loc) {
    VERIFY_OPTIONS("WorldBegin");
    <<Reset graphics state for WorldBegin>>
    <<Pass pre-WorldBegin entities to scene>>
}
```

```
scene->SetOptions(filter, film, camera, sampler, integrator, accelerator);
```
#parec[
  There is not much more to do for media. `MakeNamedMedium()` begins with
  a check to make sure that a medium with the given name has not already
  been specified.

][
  对于介质几乎没有更多要做的工作。`MakeNamedMedium()`
  的开头是检查是否已经为给定名称指定了介质。
]

```
void BasicSceneBuilder::MakeNamedMedium(const std::string &name,
        ParsedParameterVector params, FileLoc loc) {
    <<Issue error if medium name is multiply defined>>
    <<Create ParameterDictionary for medium and call AddMedium()>>
}
```
#parec[
  Assuming the medium is not multiply defined, all that is to be done is
  to pass along a `MediumSceneEntity` to the
  #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[BasicScene];.
  This can be done immediately in this case, as there is no way for it to
  be subsequently changed during parsing.

][
  假设介质名称未重复定义，所要做的只是将一个 `MediumSceneEntity` 传递给
  #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[BasicScene];。在这种情况下可以立即完成，因为在解析过程中不存在后续更改的方式。
]

```
ParameterDictionary dict(std::move(params), graphicsState.mediumAttributes,
                         graphicsState.colorSpace);
scene->AddMedium(MediumSceneEntity(name, std::move(dict), loc,
                                   RenderFromObject()));
```
#parec[
  The other object specification methods follow the same general form,
  though the `BasicSceneBuilder::Shape()` method is more complex than the
  others. Not only does it need to check to see if an `AreaLight`
  specification is active and call `BasicScene::AddAreaLight()` if so, but
  it also needs to distinguish between shapes with animated
  transformations and those without, creating an
  `AnimatedShapeSceneEntity` or a `ShapeSceneEntity` as appropriate.

][
  其他对象的规范方法大体遵循相同的通用格式，尽管
  `BasicSceneBuilder::Shape()` 方法比其他方法更为复杂。不仅要检查是否存在
  `AreaLight` 规范并在需要时调用
  `BasicScene::AddAreaLight()`，还需要区分具有动画变换的形状和没有动画变换的形状，并据此创建一个
  AnimatedShapeSceneEntity 或 ShapeSceneEntity。
]


