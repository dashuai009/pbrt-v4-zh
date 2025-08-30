#import "../template.typ": parec


== Tokenizing and Parsing
<c.1-tokenizing-and-parsing>

#parec[
  Two functions expose pbrt’s scene-parsing capabilities, one taking one
  or more names of files to process in sequence, and the other taking a
  string that holds a scene description. All of pbrt’s parsing code is in
  the files
  #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.h")[parser.h]
  and
  #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.cpp")[parser.cpp];.
][
  有两个函数暴露了 pbrt
  的场景解析能力，一个接受一个或多个文件名按顺序处理，另一个接受包含场景描述的字符串。pbrt
  的所有解析代码都位于文件
  #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.h")[parser.h]
  和
  #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.cpp")[parser.cpp];。

]
```cpp
void ParseFiles(ParserTarget *target,
                pstd::span<const std::string> filenames);
void ParseString(ParserTarget *target, std::string str);
```

#parec[
  Rather than directly returning an object that represents the parsed
  scene, the parsing functions call methods of the provided
  #link("<ParserTarget>")[ParserTarget] to convey what they have found.
  ParserTarget is an abstract interface class that defines nearly 40 pure
  virtual functions, each one corresponding to a statement in a pbrt scene
  description file.
][

  解析函数并不直接返回表示已解析场景的对象，而是调用所提供的
  #link("<ParserTarget>")[ParserTarget]
  的方法来传达它们所发现的内容。ParserTarget
  是一个抽象接口类，定义了将近40个纯虚成员函数，每一个都对应 pbrt
  场景描述文件中的一个语句。
]

```cpp
<<ParserTarget Definition>>=
class ParserTarget {
  public:
    <<ParserTarget Interface>>
  protected:
    <<ParserTarget Protected Methods>>
};
```
#parec[
  For example, given the statement

  `Scale 2 2 4`

  in a scene description file, the parsing code will call its
  `ParserTarget`’s Scale() method.
][
  例如，给定一个场景描述文件中的语句

  `Scale 2 2 4`

  解析代码将调用其 `ParserTarget` 的 `Scale()` 方法。


]


```cpp
virtual void Scale(Float sx, Float sy, Float sz, FileLoc loc) = 0;
```

#parec[
  The provided FileLoc records the location of the corresponding statement
  in a file. If it is passed to the Warning(), Error(), and ErrorExit()
  functions, the resulting message includes this information so that it is
  easier for users to fix errors in their scene files.
][
  提供的 FileLoc 记录了对应语句在文件中的位置。如果将其传递给
  Warning()、Error() 和 ErrorExit()
  函数，生成的消息将包含此信息，便于用户更容易地修正场景文件中的错误。
]


```cpp
struct FileLoc {
    std::string_view filename;
    int line = 1, column = 0;
};
```

#parec[
  Specifying ParserTarget as an abstract base class makes it easy to do a
  variety of things while parsing pbrt scene descriptions. For example,
  there is a FormattingParserTarget implementation of the ParserTarget
  interface that pretty-prints scene files and can upgrade scene files
  from the previous version of pbrt to conform to the current
  implementation’s syntax. (FormattingParserTarget is not described any
  further in the book.) Section C.2 will describe the BasicSceneBuilder
  class, which also inherits from ParserTarget and builds an in-memory
  representation of the parsed scene.
][
  将 ParserTarget 指定为抽象基类使在解析 pbrt
  场景描述时可以方便地执行各种任务。例如，FormattingParserTarget 是
  ParserTarget
  的一个实现，用于美化输出场景文件，并能够将场景文件从旧版本升级以符合当前实现的语法。该实现未在书中作进一步描述。第
  C.2 节将描述 BasicSceneBuilder 类，该类也从 ParserTarget
  继承并构建已解析场景的内存表示。


]

#parec[
  pbrt’s scene description is easy to convert into tokens. Its salient
  properties are:
  - Individual tokens are separated by whitespace.
  - Strings are delimited using double quotes.
  - One-dimensional arrays of values can be specified using square brackets: \[ \]
  - Comments start
  with a hash character, \#, and continue to the end of the current line.
][
  pbrt 的场景描述很容易被分解为标记序列（token 序列）。其显著特性如下：
  - 个别标记由空白字符分隔。
  - 字符串使用双引号界定。
  - 一维数值数组可以使用方括号指定：\[ \]
  - 注释以哈希字符 \# 开头，直到当前行结束。
]


#parec[
  We have not included pbrt’s straightforward tokenizer in the book text.
  (See the Tokenizer class in
  #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.h")[parser.h]
  and
  #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.cpp")[parser.cpp]
  for its implementation.)
][
  我们在书中尚未给出 pbrt 的直接分词器实现。（请参阅
  #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.h")[parser.h]
  和
  #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.cpp")[parser.cpp]
  中的 Tokenizer 类及其实现。）

]

#parec[
  Given a stream of tokens, the next task is parsing them. Some scene file
  statements have a fixed format (e.g., Scale, which expects three numeric
  values to follow). For each of those, the parser has fixed logic that
  looks for the expected number of values and checks that they have the
  correct types, issuing an error message if they are deficient. Other
  statements take lists of named parameters and values:
][
  给定一个标记序列，接下来的任务是对它们进行解析。一些场景文件语句具有固定格式（例如
  Shape，后面跟随三个数值）。对于这些语句，解析器具有固定的逻辑，寻找期望数量的值并检查它们的类型是否正确，如有不足会发出错误信息。其他语句则需要带名称的参数和值的列表：
]


```cpp
Shape "sphere" "float radius" 10 "float zmin" 0
```

#parec[
  Such named parameter lists are encoded by the parser in instances of the
  `ParsedParameterVector`
  class that are passed to the ParserTarget interface methods. For
  example, the signature for the Shape() interface method is:

][
  此类命名参数列表由解析器在实例化的
  `ParsedParameterVector`
  类中编码，并传递给 ParserTarget 接口方法。例如 Shape()
  接口方法的签名是：
]


```cpp
virtual void Shape(const std::string &name,
                   ParsedParameterVector params, FileLoc loc) = 0;
```


#parec[
  One might ask: why tokenize and parse the files using a custom
  implementation and not use lexer and parser generators like flex, bison,
  or antlr? In fact, previous versions of pbrt did use flex and bison.
  However, when investigating pbrt’s performance in loading multi-gigabyte
  scene description files when rendering Disney’s Moana Island scene, we
  found that a substantial fraction of execution time was spent in the
  mechanics of parsing. Replacing that part of the system with a custom
  implementation substantially improved parsing performance. A secondary
  advantage of not using those tools is that doing so makes it easier to
  build pbrt on a variety of systems by eliminating the requirement of
  ensuring that they are installed.
][
  有人可能会问：为什么要使用自定义实现来对文件进行标记化和解析，而不使用像
  flex、bison 或 ANTLR 这样的词法分析器和解析器生成器？ 实际上，pbrt
  的早期版本确实使用过 flex 和 bison。然而，在研究 pbrt 在加载多 GB
  场景描述文件（如迪士尼的 Moana Island
  场景）时的性能时，我们发现解析机制在执行时间中的比重大。用自定义实现替换该部分系统後，解析性能显著提升。另一个优点是避免了依赖安装这些工具，从而更容易在各种系统上构建
  pbrt。

]

#parec[
  ParsedParameterVector uses InlinedVector to store a vector of parameters, avoiding the performance cost of dynamic allocation that comes with std::vector in the common case of a handful of parameters.
][
  ParsedParameterVector 使用 InlinedVector
  来存储参数向量，避免在常见情况下 std::vector 的动态分配成本。
]


```cpp
using ParsedParameterVector = InlinedVector<ParsedParameter *, 8>;
```

```cpp
class ParsedParameter {
  public:
    ParsedParameter(FileLoc loc) : loc(loc) {}

    void AddFloat(Float v);
    void AddInt(int i);
    void AddString(std::string_view str);
    void AddBool(bool v);

    std::string ToString() const;

    std::string type, name;
    FileLoc loc;
    pstd::vector<Float> floats;
    pstd::vector<int> ints;
    pstd::vector<std::string> strings;
    pstd::vector<uint8_t> bools;
    mutable bool lookedUp = false;
};
```

#parec[
  ParsedParameter provides the parameter type and name as strings as well
  as the location of the parameter in the scene description file. For the
  first parameter in the sphere example above, type would store "float"
  and name would store "radius." Note that the parser makes no effort to
  ensure that the type is valid or that the parameter name is used by the
  corresponding statement; those checks are handled subsequently.
][

  ParsedParameter
  提供参数类型和名称（以字符串形式）以及参数在场景描述文件中的位置。对于上面球体示例中的第一个参数，type
  将存储 "float"，name 将存储
  "radius"。请注意，解析器并不努力确保类型有效或参数名被相应的语句使用；这些检查随后再处理。


]
```cpp
std::string type, name;
FileLoc loc;
```

#parec[
  Parameter values are provided in one of four formats, corresponding to
  the basic types used for parameter values in scene description files.
  (Values for higher-level parameter types like point3 are subsequently
  constructed from the corresponding basic type.) Exactly one of the
  following vectors will be non-empty in each provided ParsedParameter.
][
  参数值以四种格式之一提供，分别对应场景描述文件中使用的基本参数类型。（如
  point3 等更高层次参数类型的值，随后由相应的基本类型构造。）在给定的
  ParsedParameter 中，恰好只有下列向量之一非空。

]

#parec[
  As before, the parser makes no effort to validate these—for example, if
  the user has provided string values for a parameter with "float" type,
  those values will be provided in strings with no complaint (yet).
][
  与前面一样，解析器不会对这些进行验证——例如，如果用户为一个“float”类型的参数提供字符串值，那么这些值将以字符串形式提供，目前不会提出异议。

]
```cpp
pstd::vector<Float> floats;
pstd::vector<int> ints;
pstd::vector<std::string> strings;
pstd::vector<uint8_t> bools;
```

#parec[
  The lookedUp member variable is provided for the code related to
  extracting parameter values. It makes it easy to issue an error message
  if any provided parameters were not actually used by pbrt, which
  generally indicates a misspelling or other user error.
][
  lookedUp
  成员用于跟踪参数是否已被使用，以便在未使用时发出错误信息，这通常表示拼写错误或其他用户错误。

]
```cpp
mutable bool lookedUp = false;
```

#parec[
  We will not discuss the remainder of the methods in the ParserTarget
  interface here, though we will see more of them in the BasicSceneBuilder
  methods that implement them in Sections C.2.3 and C.2.4.
][
  我们在此不再讨论 ParserTarget 接口的其他方法，尽管在第 C.2.3 与 C.2.4
  节中的 BasicSceneBuilder 实现方法中，我们将看到更多内容。


]
