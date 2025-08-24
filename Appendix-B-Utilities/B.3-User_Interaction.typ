#import "../template.typ": parec, translator

== User Interaction


#parec[
  A number of functions and classes are useful to mediate
  communicating information to the user. In addition to consolidating
  functionality like printing progress bars, hiding user communication
  behind a small API like the one here also permits easy modification of
  the communication mechanisms. For example, if `pbrt` were embedded in an
  application that had a graphical user interface, errors might be
  reported via a dialog box or a routine provided by the parent
  application. If `printf()` calls were strewn throughout the system, it
  would be more difficult to make the two systems work together
  well.
][
  有许多函数和类可用于向用户传递信息。除了整合诸如打印进度条之类的功能外，将用户交互隐藏在这样的小型
  API 背后还可以更方便地修改交互机制。例如，如果 `pbrt`
  被嵌入到一个具有图形界面的应用程序中，那么错误可能会通过对话框或父应用程序提供的例程来报告。如果在整个系统中随处散布
  `printf()` 调用，那么要让这两个系统良好地协作就会变得更加困难。
]



=== B.3.1 Working with Files
<b.3.1-working-with-files>
#parec[
  A few utility routines make it easy to read and write files
  from disk. `ReadFileContents()` returns the contents of a file as a
  string and `ReadDecompressedFileContents()` does the same for files that
  are compressed using the gzip algorithm, decompressing them before
  returning their contents. `WriteFileContents()` writes the contents of a
  string to a file. Note that the use of `std::string` does not impose the
  requirement that the file contents be text: binary data, including null
  characters, can be stored in a
  `std::string`.
][
  一些实用函数可以方便地从磁盘读写文件。`ReadFileContents()`
  将文件内容作为字符串返回，`ReadDecompressedFileContents()` 则对使用 gzip
  算法压缩的文件执行同样的操作，并在返回内容之前对其解压缩。`WriteFileContents()`
  用于将字符串的内容写入文件。需要注意的是，使用 `std::string`
  并不要求文件内容必须是文本：二进制数据（包括空字符）同样可以存储在
  `std::string` 中。
]

```cpp
std::string ReadFileContents(std::string filename);
std::string ReadDecompressedFileContents(std::string filename);
bool WriteFileContents(std::string filename, const std::string &contents);
```

#parec[
  A number of parts of `pbrt` need to read text files that store
  floating-point values. Examples include the code that reads measured
  spectral distributions. The `ReadFloatFile()` function is available for
  such uses; it parses text files of white space-separated numbers,
  returning the values found in a `vector`. The parsing code ignores all
  text after a hash mark (\#) to the end of its line to allow
  comments.
][
  `pbrt`
  的许多部分需要读取存储浮点值的文本文件。例如读取实测光谱分布的代码。为此提供了
  `ReadFloatFile()`
  函数；它会解析由空白分隔的数字文本文件，并将得到的值返回在一个 `vector`
  中。解析代码会忽略井号（\#）之后直到行尾的所有文本，从而允许文件中包含注释。
]

```cpp
std::vector<Float> ReadFloatFile(std::string filename);
```

#parec[
  `pbrt` provides two functions that convert both ways between
  the UTF-8 and UTF-16 encodings, where strings of 16-bit values,
  `std::u16string`, are used for UTF-16. These are both thin wrappers
  around functionality provided by the C++ standard library.
][
  `pbrt`
  提供了两个函数，用于在 UTF-8 与 UTF-16 编码之间相互转换，其中 UTF-16
  使用 `std::u16string`（16 位值的字符串）。这两个函数都是对 C++
  标准库功能的简单封装。
]

```cpp
std::string UTF8FromUTF16(std::u16string str);
std::u16string UTF16FromUTF8(std::string str);
```

#parec[
  Filenames also require attention. On Linux, filenames can be
  any string of bytes, other than the forward slash "/", which separates
  path components, and U+0000, which is the end of string marker in C.
  Thus, UTF-8 encoded filenames (slash notwithstanding) are supported with
  no further effort, though filenames that are not valid UTF-8 strings are
  also allowed. Both OS X and Windows use Unicode for filenames, with the
  UTF-8 and UTF-16 encodings, respectively.
][
  文件名也需要注意。在 Linux
  上，文件名可以是任意字节串，除了用来分隔路径组件的斜杠 "/"
  和表示字符串结尾的 U+0000。因此，UTF-8
  编码的文件名（不含斜杠）无需额外处理即可支持，甚至不合法的 UTF-8
  字符串也被允许。OS X 和 Windows 则分别使用 UTF-8 与 UTF-16
  编码来表示文件名。
]

#parec[
  Both the ReadFileContents() and WriteFileContents() functions
  introduced earlier therefore handle converting filenames to UTF-16 on
  Windows, allowing callers to directly pass UTF-8 encoded strings to
  them. `pbrt` further provides `FOpenRead()` and `FOpenWrite()` functions
  that wrap the functionality of `fopen()`. On Windows, they perform the
  UTF-16 filename conversion and then call `_wfopen()` in place of
  `fopen()`.
][
  因此，前面介绍的 `ReadFileContents()` 和
  `WriteFileContents()` 函数在 Windows 上会自动将文件名转换为
  UTF-16，使调用者可以直接传递 UTF-8 编码的字符串。`pbrt` 还提供了
  `FOpenRead()` 和 `FOpenWrite()` 函数来封装 `fopen()` 的功能。在 Windows
  上，它们会执行 UTF-16 文件名转换，并调用 `_wfopen()` 来代替
  `fopen()`。
]

#parec[
  Few further changes were needed for Unicode support in `pbrt`
  thanks to a key component of the UTF-8 design: not only are the ASCII
  characters represented in UTF-8 with a single byte and with the same
  value, but it is also guaranteed that no byte used to encode a non-ASCII
  code point will be equal to an ASCII value. (Effectively, this means
  that because the high bit of 8-bit ASCII values is unset, the high bit
  of any byte used for a non-ASCII Unicode character in UTF-8 is always
  set.)
][
  由于 UTF-8 设计中的一个关键特性，`pbrt` 在支持 Unicode
  时几乎无需额外改动：ASCII 字符在 UTF-8
  中始终以单字节并保持相同数值表示；同时保证用于编码非 ASCII
  码点的字节绝不会与某个 ASCII 值相等。（实际上，这意味着 8 位 ASCII
  值的最高位始终为 0，而 UTF-8 中非 ASCII 字符的字节最高位始终为 1。）
]

#parec[
  To see the value of this part of the design of UTF-8, consider
  parsing the scene description in `pbrt`. If for example the parser has
  encountered an opening double quotation mark `"` , it then copies all
  subsequent bytes until the closing quote into a `std::string` and issues
  an error if a newline is encountered before the closing quote. In UTF-8,
  the quotation mark U+0022 is encoded as $22\_{16}$ and newline U+000A
  as $0A\_{16}$. Because the byte values $22\_{16}$ and $0A\_{16}$
  are not used to encode any other code points, the parser can be
  oblivious to Unicode, copying bytes into a string just as it did before
  until it encounters a $22\_{16}$ byte. It makes no difference to the
  parsing code whether the byte values in the string represent plain ASCII
  or characters from other scripts.
][
  要理解 UTF-8
  这一设计的价值，可以考虑 `pbrt`
  在解析场景描述时的情况。如果解析器遇到一个开引号
  `"`，它会将随后的所有字节复制到
  `std::string`，直到遇到闭引号为止；如果在闭引号前遇到换行符则报错。在
  UTF-8 中，双引号 U+0022 编码为 $22\_{16}$，换行符 U+000A 编码为
  $0A\_{16}$。由于 $22\_{16}$ 和 $0A\_{16}$
  不会被用来编码其他任何码点，因此解析器完全不必关心
  Unicode，可以像以前一样逐字节复制，直到遇到 $22\_{16}$
  为止。无论字符串中的字节代表的是纯 ASCII
  还是其他文字的字符，对解析代码都没有区别。
]

#parec[
  More generally, because `pbrt` does not use any non-ASCII
  characters in the definition of its scene description format, the parser
  can continue to operate one byte at a time, without being concerned
  whether each one is part of a multi-byte UTF-8
  character.
][
  更一般地，由于 `pbrt` 在场景描述格式定义中并未使用任何非
  ASCII 字符，因此解析器依然可以逐字节处理，而无需关心某个字节是否属于
  UTF-8 的多字节字符的一部分。
]

=== B.3.2 Character Encoding and Unicode
<b.3.2-character-encoding-and-unicode>
#parec[
  As a rendering system, `pbrt` is relatively unconcerned with
  text processing. Yet the scene description is provided as text and the
  user can configure the system by specifying text command-line arguments,
  including those that specify scene description files to be parsed and
  the filename for the final rendered image. Previous versions of `pbrt`
  have implicitly assumed that all text is encoded in ASCII, where each
  character is represented using a single byte. There are 95 printable
  ASCII characters. In hexadecimal, their values range from $20\_{16}$,
  a blank space, to $7E\_{16}$, a tilde, as shown
  above.
][
  作为一个渲染系统，`pbrt`
  与文本处理关系不大。然而，场景描述是以文本形式提供的，用户还可以通过指定文本形式的命令行参数来配置系统，其中包括要解析的场景描述文件和最终渲染图像的文件名。以前的版本隐含地假设所有文本都是以
  ASCII 编码的，其中每个字符用一个字节表示。ASCII 中有 95
  个可打印字符。用十六进制表示，它们的取值范围从 $20\_{16}$（空格）到
  $7E\_{16}$（波浪号），如上所示。
]

#parec[
  Adopting ASCII implied that the only letters that can be used
  in this text are the Latin letters from A to Z. No accented letters were
  allowed, nor was text written in Chinese, Japanese, or the Devanagari
  script used for Hindi. (Emoji were also not possible, though we are
  unsure whether being able to directly render an image named “ 魄.exr ”
  is a feature worth devoting attention to.)
][
  采用 ASCII
  意味着文本中只能使用 A 到 Z
  的拉丁字母。不允许使用带重音符的字母，也无法使用中文、日文或印地语所用的天城文。（Emoji
  同样也不可能使用，尽管我们不确定能否直接渲染一个名为 "魄.exr"
  的图像是否值得特别关注。）
]

#parec[
  This version of `pbrt` uses Unicode (Unicode Consortium 2020)
  to represent text. At writing, Unicode allows the representation of
  nearly 150,000 characters, drawn from scripts that cover a wide variety
  of languages. (In Unicode, a script is a collection of letters and
  symbols used in the writing system for a language.) Fortunately, most of
  the code that handles text in `pbrt` was minimally affected by the
  change to Unicode, though it is important to understand the underlying
  principles if one is to read or modify code in `pbrt` that works with
  character strings.
][
  本版本的 `pbrt` 使用 Unicode（Unicode Consortium
  2020）来表示文本。在撰写本文时，Unicode 可以表示接近 150,000
  个字符，涵盖了多种语言的书写系统。（在 Unicode 中，script
  指某种语言使用的字母和符号集合。）幸运的是，`pbrt`
  中处理文本的大部分代码只受到极小的影响，不过若要阅读或修改与字符串相关的代码，理解其基本原理仍然很重要。
]

#parec[
  Unicode associates a unique numeric code point with each
  character; code points are denoted by U+$n$, where $n$ is a
  hexadecimal integer.
][
  Unicode
  为每个字符分配一个唯一的数值码点；码点记作 U+$n$，其中 $n$
  是一个十六进制整数。
]

#parec[
  The code points for ASCII characters match the ASCII encoding,
  so ";” corresponds to both ASCII $7E\_{16}$ and U+007E. The
  letter ü is represented by U+00FC, and the Chinese character 魄 is
  U+5149.
][
  ASCII 字符的码点与 ASCII 编码一致，因此 “\~" 同时对应 ASCII
  $7E\_{16}$ 和 U+007E。字母 "ü" 表示为 U+00FC，而汉字 "魄" 的码点是
  U+5149。
]

#parec[
  Unicode also defines a number of encodings that map code points
  to sequences of byte values. The simplest is UTF-32, which uses 4 bytes
  (32 bits) to represent each code point. UTF-32 has the advantage that
  all code points use the same amount of storage, which makes it easy to
  perform operations like finding the n-th code point in a string, though
  it uses four times more storage for ASCII characters than ASCII does,
  which is a disadvantage if text is mostly ASCII.
][
  Unicode
  还定义了一些编码方式，将码点映射为字节序列。最简单的是 UTF-32，它用 4
  个字节（32 位）表示每个码点。UTF-32
  的优点是所有码点都占用相同大小的存储空间，因此可以方便地执行诸如查找字符串中第
  n 个码点这样的操作。但缺点是它对 ASCII 字符的存储开销比 ASCII 多 4
  倍，如果文本主要是 ASCII，这就不利。
]

#parec[
  UTF-8 uses a variable number of bytes to represent each code
  point. ASCII characters are represented with a single byte equal to
  their code point’s value and thus pure ASCII text is by construction
  UTF-8 encoded. Code points after U+007F are encoded using 2, 3, or 4
  bytes depending on their magnitude. Therefore, finding the n-th code
  point requires scanning from the start of a string in the absence of
  auxiliary data structures. (That operation is not important in `pbrt`,
  however.)
][
  UTF-8 使用可变长度字节表示每个码点。ASCII
  字符用单字节表示，其值等于码点值，因此纯 ASCII 文本天然就是 UTF-8
  编码。大于 U+007F 的码点根据大小需要 2、3 或 4
  个字节进行编码。因此，在没有辅助数据结构的情况下，要找到字符串中的第 n
  个码点必须从头扫描。（不过在 `pbrt` 中，这种操作并不重要。）
]

#parec[
  UTF-16 occupies an awkward middle ground; it uses two bytes to
  encode most code points, though it requires four for the ones that
  cannot fit in two. It offers the disadvantages of UTF-32 (wasted space
  if text is primarily ASCII), with few advantages in return. UTF-16 is
  used in the Windows APIs, however, which requires us to be aware of
  it.
][
  UTF-16
  处于一个尴尬的中间地带：它用两个字节编码大部分码点，但对无法容纳在两个字节中的码点则需要四个字节。它既继承了
  UTF-32 的劣势（若文本主要是 ASCII
  则浪费空间），又几乎没有带来多少优势。不过 Windows API 使用
  UTF-16，因此我们必须加以注意。
]

#parec[
  Rather than supporting multiple encodings, `pbrt` standardizes
  on UTF-8. It uses `std::string`s to represent UTF-8-encoded strings,
  which poses no problems since, in C++, `std::string`s are just arrays of
  bytes. It is, however, important to keep in mind that indexing to the
  n-th element in a `std::string` does not necessarily return the n-th
  character of the string and that the `size()` method returns the number
  of bytes stored in the string and not necessarily the number of
  characters it holds.
][
  与其支持多种编码，`pbrt` 统一采用 UTF-8。它使用
  `std::string` 来表示 UTF-8 编码的字符串，这没有问题，因为在 C++
  中，`std::string` 本质上就是字节数组。不过需要注意的是，访问
  `std::string` 的第 n 个元素并不一定对应字符串的第 n 个字符，而 `size()`
  返回的是字节数，而不一定是字符数。
]

#parec[
  Given the choice of UTF-8, we must ensure that any input from
  the user in a different encoding is converted to UTF-8 and that any use
  of strings in calls to system library functions is converted to the
  character encoding they use. For example, OS X and most versions of
  Linux now set the system locale to use a UTF-8 encoding. This causes
  command shells to encode programs’ command-line arguments as UTF-8. On
  those systems, `pbrt` therefore assumes that the `argv` parameters
  passed to the `main()` function are already UTF-8 encoded. On Windows,
  however, command-line arguments are available in ASCII or UTF-16; `pbrt`
  takes the latter and converts them to UTF-8.
][
  既然选择了
  UTF-8，就必须保证用户输入的其他编码文本在使用前被转换为
  UTF-8，并且调用系统库函数时传递的字符串也要转换为它们所需的编码。例如，OS
  X 和大多数 Linux 系统现在的区域设置都采用 UTF-8 编码，因此命令行 shell
  会将程序的命令行参数编码为 UTF-8。在这些系统上，`pbrt` 假定传递给
  `main()` 的 `argv` 参数已经是 UTF-8 编码。而在 Windows
  上，命令行参数可用 ASCII 或 UTF-16；`pbrt` 会取 UTF-16 并将其转换为
  UTF-8。
]

```cpp
std::vector<std::string> GetCommandLineArguments(char *argv[]);
```

#parec[
  `pbrt` provides two functions that convert both ways between
  the UTF-8 and UTF-16 encodings, where strings of 16-bit values,
  `std::u16string`, are used for UTF-16. These are both thin wrappers
  around functionality provided by the C++ standard library.
][
  `pbrt`
  提供了两个函数，用于在 UTF-8 与 UTF-16 编码之间相互转换，其中 UTF-16
  使用 `std::u16string` 表示。这两个函数是对 C++ 标准库功能的简单封装。
]

```cpp
std::string UTF8FromUTF16(std::u16string str);
std::u16string UTF16FromUTF8(std::string str);
```

#parec[
  Windows introduces the additional complication of using the
  type `std::wchar_t` for the elements of UTF-16-encoded strings. On
  Windows, this type is 16 bits, though the C++ standard does not specify
  its size. Therefore, `pbrt` provides additional functions on Windows to
  convert to and from UTF-16-encoded `std::wstring`s, which store elements
  using `std::wchar_t`.
][
  Windows 还引入了一个额外复杂性：它使用
  `std::wchar_t` 类型来表示 UTF-16 编码字符串的元素。在 Windows
  上，这个类型是 16 位的，尽管 C++ 标准并未规定其大小。因此，`pbrt` 在
  Windows 上还提供了额外的函数，用于在 UTF-8 与 UTF-16 编码的
  `std::wstring`（存储 `std::wchar_t` 元素）之间相互转换。
]

```cpp
#ifdef PBRT_IS_WINDOWS
std::wstring WStringFromUTF8(std::string str);
std::string UTF8FromWString(std::wstring str);
#endif // PBRT_IS_WINDOWS
```

=== B.3.3 Printing and Formatting Strings
<b.3.3-printing-and-formatting-strings>
#parec[
  `Printf()` and `StringPrintf()` respectively provide
  improvements to C’s `printf()` and `sprintf()` functions. Both support
  all the formatting directives of `printf()` and `sprintf()`, but with
  the following improvements:
][
  `Printf()` 和 `StringPrintf()` 分别改进了
  C 语言的 `printf()` 和 `sprintf()` 函数。它们支持 `printf()` 和
  `sprintf()` 的所有格式化指令，但有以下改进：
]

#parec[
  - When `%f` is used, floating-point values are printed out with
  a sufficient number of digits to exactly specify their value. This is,
  unfortunately, not the default behavior of C’s routines.

  - The `%d` directive works directly for all integer types; there is no
    need for additional qualifiers for `int64_t` or `size_t` values, etc.
  - `%s` can be used for any class that provides a `ToString()` method, as
    almost all of `pbrt`’s classes do. (It can also be used for
    `std::string`s and many of the container classes in the C++ standard
    library.)
][
  - 使用 `%f`
    时，浮点数会以足够的精度输出，以确保其值能够被完全指定。不幸的是，这并不是
    C 库函数的默认行为。
  - `%d` 可直接用于所有整数类型；不需要针对 `int64_t` 或 `size_t`
    等类型添加额外限定符。
  - `%s` 可用于任何实现了 `ToString()` 方法的类，几乎所有 `pbrt`
    的类都符合这一点。（它也可用于 `std::string` 以及 C++
    标准库中的许多容器类。）
]

#parec[
  We have found the last of these three capabilities to be
  particularly useful for debugging and tracing the system’s operation.
  These functions are implemented in util/print.h and
  util/print.cpp.
][
  我们发现第三点在调试和跟踪系统运行时特别有用。这些函数定义在
  util/print.h 和 util/print.cpp 中。
]

```cpp
template <typename... Args>
void Printf(const char *fmt, Args &&... args);
template <typename... Args>
std::string StringPrintf(const char *fmt, Args &&... args);
```

#parec[
  `StringPrintf()` has the added enhancement that it returns its
  result directly as a `std::string`, freeing the caller from needing to
  worry about allocating a sufficient amount of memory for the
  result.
][
  `StringPrintf()` 还有一个额外优点：它直接返回
  `std::string`，调用者无需担心为结果分配足够的内存。
]



=== B.3.4 Error Reporting
<b.3.4-error-reporting>
#parec[
  There are variants of all of these that call StringPrintf() so
  that printf-style formatting strings can be used to print the values of
  additional arguments. Here is the one for Warning():
][
  这些函数都有使用
  `StringPrintf()` 的变体，因此可以使用 printf
  风格的格式化字符串来打印额外参数的值。下面是 `Warning()` 的实现：
]

```cpp
template <typename... Args>
void Warning(const FileLoc *loc, const char *fmt, Args &&... args) {
    Warning(loc, StringPrintf(fmt, std::forward<Args>(args)...).c_str());
}
```

#parec[
  For cases where a FileLoc \* is not available, there are
  corresponding warning and error functions that take just a format string
  and arguments. (Alternatively, `nullptr` can be passed for the FileLoc
  \* to the methods declared above.)
][
  当 `FileLoc *`
  不可用时，可以使用只接受格式化字符串和参数的警告与错误函数。（或者，也可以为上述方法的
  `FileLoc *` 参数传递 `nullptr`。）
]

```cpp
template <typename... Args>
void Warning(const char *fmt, Args &&... args);
template <typename... Args>
void Error(const char *fmt, Args &&... args);
template <typename... Args>
[[noreturn]] void ErrorExit(const char *fmt, Args &&... args);
```



=== B.3.5 Logging
<b.3.5-logging>
#parec[
  Mechanisms for logging program execution are provided in the
  files util/log.h and util/log.cpp. These are intended to be used for
  debugging and other programmer-focused tasks; when printed, they include
  information such as the source file and line number of the logging call,
  the date and time that it was made, and which thread made
  it.
][
  程序执行的日志机制定义在 util/log.h 和 util/log.cpp
  中。它们主要用于调试和面向开发者的任务；日志输出时会包含调用日志的源文件与行号、调用的日期与时间，以及发出日志的线程信息。
]

#parec[
  The most important of them are `LOG_VERBOSE()`, `LOG_ERROR()`,
  and `LOG_FATAL()`. Each takes a formatting string with printf-style
  formatting directives and then a variable number of arguments to provide
  values. Their implementations all end up calling `StringPrintf()`, so
  all the additional capabilities it provides can be used.
][
  最重要的宏是
  `LOG_VERBOSE()`、`LOG_ERROR()` 和 `LOG_FATAL()`。它们都接受一个带有
  printf 风格格式指令的格式化字符串和若干参数。它们的最终实现都会调用
  `StringPrintf()`，因此可以利用其所有扩展功能。
]

#parec[
  Which messages are printed can be controlled by the
  `--log-level` command line option to `pbrt`. The specified logging level
  is represented with the `LogLevel` enumeration, an enumerator of which
  is stored in a global variable. If the `--log-file` option is used, a
  `FILE *` is opened to store the logging
  messages.
][
  输出哪些日志消息可以通过 `pbrt` 的命令行选项 `--log-level`
  控制。日志等级由 `LogLevel` 枚举表示，并存储在一个全局变量中。如果使用了
  `--log-file` 选项，则会打开一个 `FILE *` 来保存日志消息。
]

```cpp
enum class LogLevel { Verbose, Error, Fatal, Invalid };
```

```cpp
namespace logging {
extern LogLevel logLevel;
extern FILE *logFile;
} // namespace logging
```

#parec[
  Here is the implementation of `LOG_VERBOSE()`; the other two
  are similar. There is one trick to note: the macro is carefully written
  using the short-circuit `&&` operator so that not only does it expand to
  a single statement, making it safe to use after an `if` statement
  without braces, but the arguments after the formatting string are also
  not evaluated if verbose logging has not been specified. In this way, it
  is safe to write logging code that calls functions that may do
  meaningful amounts of computation for the parameter values while not
  paying the cost for them if their results are unneeded.
][
  以下是
  `LOG_VERBOSE()`
  的实现；其他两个类似。需要注意的一个技巧是：该宏使用了短路求值的 `&&`
  运算符，因此它展开后始终是一个单独的语句，可以安全地在没有花括号的 `if`
  语句后使用；而且如果没有启用详细日志，那么格式化字符串之后的参数表达式也不会被求值。这样，就可以安全地写一些可能涉及较大计算开销的参数表达式，而在结果不需要时不会造成性能损失。
]

```cpp
#define LOG_VERBOSE(...)                                             \
    (pbrt::LogLevel::Verbose >= logging::logLevel &&                 \
     (pbrt::Log(LogLevel::Verbose, __FILE__, __LINE__, __VA_ARGS__), \
      true))
```



=== B.3.6 Assertions and Runtime Error Checking
<b.3.6-assertions-and-runtime-error-checking>
#parec[
  A few capabilities are provided for checking for unexpected
  values at runtime, all defined in the file util/check.h. `pbrt` uses
  these in place of the system-provided `assert()` macro as they provide
  more information about which values led to assertion failures, when they
  occur. These should only be used for errors that the system cannot
  recover from and only for errors that are due to the system’s
  implementation: errors in user input and such should be detected and
  reported using the more friendly mechanisms of the Warning() and Error()
  functions.
][
  `pbrt`
  提供了一些运行时检查工具，用于检测异常值，它们定义在 util/check.h
  中。`pbrt` 使用这些工具替代系统提供的 `assert()`
  宏，因为它们能在断言失败时提供更详细的信息，说明导致失败的具体值。这些工具只应用于系统无法恢复的错误，并且仅限于系统实现本身的问题；用户输入错误等应通过更友好的
  `Warning()` 和 `Error()` 机制来检测和报告。
]

#parec[
  First, `CHECK()` replaces `assert()`, issuing a fatal error if
  the specified condition is not true. A `DCHECK()` macro, not included
  here, performs similar functionality, though only in debug
  builds.
][
  首先，`CHECK()` 替代了
  `assert()`，如果条件不成立则触发致命错误。另有 `DCHECK()`
  宏（未在此列出），功能类似，但仅在调试构建中启用。
]

```cpp
#define CHECK(x) (!(!(x) && (LOG_FATAL("Check failed: %s", #x), true)))
```

#parec[
  A common use of assertions is to check a relationship between
  two values (e.g., that they are equal, or that one is strictly less than
  another). These operations are performed by the following macros, which
  dispatch to another one that they all share. (There are similarly
  D-prefixed variants of these for debug builds
  only.)
][
  断言常用于检查两个值之间的关系（例如它们是否相等，或者一个是否严格小于另一个）。以下宏执行这些检查，它们最终都会调用同一个实现宏。（类似地，带
  `D` 前缀的变体仅在调试构建中启用。）
]

```cpp
#define CHECK_EQ(a, b) CHECK_IMPL(a, b, ==)
#define CHECK_NE(a, b) CHECK_IMPL(a, b, !=)
#define CHECK_GT(a, b) CHECK_IMPL(a, b, >)
#define CHECK_GE(a, b) CHECK_IMPL(a, b, >=)
#define CHECK_LT(a, b) CHECK_IMPL(a, b, <)
#define CHECK_LE(a, b) CHECK_IMPL(a, b, <=)
```

#parec[
  There are three things to see in `CHECK_IMPL()`. First, it is
  careful to evaluate the provided expressions only once, storing their
  values in the `va` and `vb` variables. This ensures that they do not
  introduce unexpected behavior if they are invoked with an expression
  that includes side effects (e.g., `var++`). Second, when the check
  fails, the error message includes not just the source code form of the
  check, but also the values that caused the failure. This additional
  information alone is sometimes enough to debug an issue. Finally, it is
  implemented in terms of a single iteration do/while loop; in this way,
  it is a single C++ statement and therefore can be used with if
  statements without braces.
][
  `CHECK_IMPL()`
  有三点值得注意。第一，它会确保只对给定的表达式求值一次，并将结果存储在
  `va` 和 `vb` 中，从而避免在表达式包含副作用（如
  `var++`）时引发意外行为。第二，当检查失败时，错误信息不仅包含检查的源码形式，还包含实际导致失败的值，这些信息往往足以定位问题。最后，它使用了单次迭代的
  do/while 循环实现，因此作为一个单独的 C++ 语句，可以与没有花括号的 if
  语句安全组合使用。
]

```cpp
#define CHECK_IMPL(a, b, op)                                              \
    do {                                                                  \
        auto va = a;                                                      \
        auto vb = b;                                                      \
        if (!(va op vb))                                                  \
            LOG_FATAL("Check failed: %s " #op " %s with %s = %s, %s = %s",\
                      #a, #b, #a, va, #b, vb);                            \
    } while (false) /* swallow semicolon */
```

#parec[
  When a `CHECK` fails, not only is the error message printed,
  but `pbrt` also prints a stack trace that shows some context of the
  program’s state of execution at that point. In addition, the
  `CheckCallbackScope` class can be used to provide additional information
  about the current program state that is printed upon a `CHECK`
  failure.
][
  当 `CHECK` 失败时，除了打印错误消息，`pbrt`
  还会输出堆栈跟踪，以展示程序在该时刻的执行上下文。此外，可以使用
  `CheckCallbackScope` 类提供额外的程序状态信息，当 `CHECK`
  失败时一并打印。
]

```cpp
CheckCallbackScope(std::function<std::string(void)&> callback);
```

#parec[
  Thus, it might be used as
][
  例如，可以这样使用：
]

```cpp
Point2i currentPixel; /* Variable that is updated during rendering */
CheckCallbackScope callbackScope([&]() {
    return StringPrintf("The current pixel is %s", currentPixel);
});
// Render...
```

#parec[
  to include the current pixel coordinates in the error output.
  The expectation is that CheckCallbackScope objects will be
  stack-allocated, such that when a function returns, for example, then a
  CheckCallbackScope that it declared will go out of scope and thence be
  removed from the active callback scopes by its
  destructor.
][
  这样就可以在错误输出中包含当前像素坐标。通常假设
  `CheckCallbackScope` 对象是栈上分配的，因此当函数返回时，其声明的
  `CheckCallbackScope`
  会随之离开作用域，并由析构函数从活动回调列表中移除。
]

#parec[
  There are unusual conditions that are allowed to happen rarely,
  but where their frequent occurrence would be a bug. (One example that
  comes up in the implementation of microfacet distributions is when the
  incident and outgoing directions are exactly opposite, in which case the
  half angle vector is degenerate. The renderer needs to handle this case
  when it happens, but it should only happen rarely.) `pbrt` therefore
  also provides a `CHECK_RARE(freq, cond)` macro that takes a maximum
  frequency of failure and a condition to check. An error is issued at the
  end of program execution for any of them where the condition occurred
  too frequently.
][
  有些异常情况允许偶尔发生，但若频繁出现则表明存在
  bug。（例如，在实现微表面分布时，若入射方向与出射方向正好相反，则半角向量退化。渲染器需要能处理这种情况，但它应当极少发生。）因此，`pbrt`
  提供了 `CHECK_RARE(freq, cond)`
  宏，它接受一个最大允许失败频率和一个需要检查的条件。如果该条件出现过于频繁，则在程序结束时报告错误。
]



=== B.3.7 Displaying Images
<b.3.7-displaying-images>
#parec[
  `pbrt` supports a simple socket-based protocol that allows it
  to communicate with external programs that can display images, both on
  the same machine and on a remote system from the one that `pbrt` is
  running on. This is the mechanism that is invoked when the
  `--display-server` option is provided on the command line.
][
  `pbrt`
  支持一个基于 socket
  的简单协议，允许它与外部图像显示程序通信，这些程序可以运行在同一台机器上，也可以运行在远程系统上。当命令行提供
  `--display-server` 选项时，就会启用这一机制。
]

#parec[
  If a connection has been made with such a display program,
  there are a number of functions that make it easy to visualize arbitrary
  image data using it. This can be especially useful for debugging or for
  understanding `pbrt`’s
  execution.
][
  如果与此类显示程序建立了连接，就可以通过一组函数方便地可视化任意图像数据。这在调试或理解
  `pbrt` 的执行过程时尤其有用。
]

#parec[
  `DisplayStatic()` causes an image of the specified size to be
  displayed. The number of specified image channel names determines the
  number of channels in the image. The provided callback will be called
  repeatedly for tiles of the overall image, where each call is provided a
  separate buffer for each specified image channel. These buffers should
  be filled with values for the given tile bounds in scanline
  order.
][
  `DisplayStatic()`
  会显示一幅指定尺寸的图像。指定的通道名称数量决定图像的通道数。系统会为整幅图像的分块多次调用提供的回调函数，每次调用都会提供每个通道的独立缓冲区。这些缓冲区应按扫描线顺序填充该分块范围内的像素值。
]

```cpp
void DisplayStatic(std::string title, Point2i resolution,
    std::vector<std::string> channelNames,
    std::function<void(Bounds2i, pstd::span<pstd::span<Float>>)> getValues);
```

#parec[
  `DisplayDynamic()` is similar, but the callback will be called
  repeatedly during program execution to get the latest values for dynamic
  data.
][
  `DisplayDynamic()`
  与之类似，但回调会在程序运行过程中被多次调用，用于获取动态数据的最新值。
]

```cpp
void DisplayDynamic(std::string title, Point2i resolution,
    std::vector<std::string> channelNames,
    std::function<void(Bounds2i, pstd::span<pstd::span<Float>>)> getValues);
```

#parec[
  There are additional convenience functions that take Images for
  both static and dynamic display. Their implementations take care of
  providing the necessary callback routines to copy data from the image to
  the provided buffers.
][
  此外，还提供了便捷函数，可以直接将 `Image`
  用于静态和动态显示。它们的实现会负责提供所需的回调，将图像数据复制到给定的缓冲区。
]

```cpp
void DisplayStatic(std::string title, const Image &image,
                   pstd::optional<ImageChannelDesc> channelDesc = {});
void DisplayDynamic(std::string title, const Image &image,
                    pstd::optional<ImageChannelDesc> channelDesc = {});
```

=== B.3.8 Reporting Progress
<b.3.8-reporting-progress>
#parec[
  The ProgressReporter class gives the user feedback about how
  much of a task has been completed and how much longer it is expected to
  take. For example, implementations of the various Integrator::Render()
  methods generally use a ProgressReporter to show rendering progress. The
  implementation prints a row of plus signs

  , the elapsed time, and the estimated remaining
  time.
][
  `ProgressReporter`
  类用于向用户反馈任务完成的进度以及预计剩余时间。例如，各种
  `Integrator::Render()` 方法的实现通常会使用 `ProgressReporter`
  来显示渲染进度。它的实现会输出一行加号、已用时间以及预计剩余时间。
]

```cpp
class ProgressReporter {
  public:
    ProgressReporter(int64_t totalWork, std::string title, bool quiet,
                     bool gpu = false);
       ~ProgressReporter();
       void Update(int64_t num = 1);
       void Done();
       double ElapsedSeconds() const;
       std::string ToString() const;
  private:
       void printBar();
       int64_t totalWork;
       std::string title;
       bool quiet;
       Timer timer;
       std::atomic<int64_t> workDone;
       std::atomic<bool> exitThread;
       std::thread updateThread;
       pstd::optional<float> finishTime;

       #ifdef PBRT_BUILD_GPU_RENDERER
       std::vector<cudaEvent_t> gpuEvents;
       std::atomic<size_t> gpuEventsLaunchedOffset;
       int gpuEventsFinishedOffset;
       #endif
};
```

#parec[
  The constructor takes the total number of units of work to be
  done (e.g., the total number of camera rays that will be traced) and a
  short string describing the task being performed. If the `gpu` parameter
  is true, then execution on the GPU is tracked. In that case, the
  implementation must handle the fact that CPU and GPU operation is
  asynchronous, which it does by adding events to the GPU command stream
  at each `Update()` call and then periodically determining which events
  have been completed to report the appropriate degree of progress. See
  the source code for
  details.
][
  构造函数接受任务的总工作量（例如需要追踪的相机光线总数）以及一个简短的任务描述字符串。如果
  `gpu` 参数为 true，则会跟踪 GPU 上的执行情况。这时实现必须处理 CPU 与
  GPU 异步执行的问题，它通过在每次 `Update()` 调用时向 GPU
  命令流添加事件，并定期检查已完成的事件，从而报告适当的进度。具体细节可见源码。
]

#parec[
  Once the `ProgressReporter` has been created, each call to its
  `Update()` method signifies that one unit of work has been completed. An
  optional integer value can be passed to indicate that multiple units
  have been done. A call to `Done()` indicates that all work has been
  completed. Finally, the elapsed time since the `ProgressReporter` was
  created is available via the `ElapsedSeconds()` method. This quantity
  must be tracked for the progress updates and is often useful to have
  available.
][
  一旦创建了 `ProgressReporter`，每次调用其 `Update()`
  方法都表示完成了一个工作单元。可选地，还可以传递一个整数来表示完成了多个工作单元。调用
  `Done()` 表示所有工作已完成。最后，可以通过 `ElapsedSeconds()`
  方法获取自 `ProgressReporter`
  创建以来的耗时。这一数值既用于进度更新，也常常很有参考价值。
]

```cpp
void Update(int64_t num = 1);
void Done();
double ElapsedSeconds() const;
```
