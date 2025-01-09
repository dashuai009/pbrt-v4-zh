#import "../template.typ": parec, translator

// 2025.1.9 已整理
// 文学编程（Literate Programming）
// 元语言（Metalanguage）
// 代码片（Fragment）
// 编织器（Weaver）
// 解构器（Tangler）

== Literate Programming

#parec[
  While creating the TEX typesetting system, Donald Knuth developed a new programming methodology based on a simple but revolutionary idea. To quote Knuth,"let us change our traditional attitude to the construction of programs: Instead of imagining that our main task is to instruct a computer what to do, let us concentrate rather on explaining to human beings what we want a computer to do.” He named this methodology literate programming. This book (including the chapter you are reading now) is a long literate program. This means that in the course of reading this book, you will read the full implementation of the `pbrt` rendering system, not just a high-level description of it.
][
  在创建 TEX 排版系统时，Donald Knuth 基于一个简单但革命性的想法开发了一种新编程方法论。
  引用 Knuth 的原话：“让我们改变对程序构建的传统观念：不要再认为我们的主要任务是指示计算机该做什么，而是更应专注于向人类解释我们希望计算机完成的任务。”
  他将这种方法命名为“文学编程”（Literate Programming）。本书（包括你现在正在阅读的章节）就是一部完整的文学程序（Literate Program）。
  这意味着，在阅读本书的过程中，你不仅会了解pbrt渲染系统（Rendering System）。
]

#parec[
  Literate programs are written in a metalanguage that mixes a document formatting language (e.g., TEX or HTML) and a programming language (e.g., C++). Two separate systems process the program: a “weaver” that transforms the literate program into a document suitable for typesetting and a “tangler” that produces source code suitable for compilation. Our literate programming system is homegrown, but it was heavily influenced by Norman Ramsey's noweb system.
][
  文学程序使用一种元语言（Metalanguage）编写，这种语言将文档排版语言（如 TEX 或 HTML ）与编程语言（如C++）相结合。
  文学程序由两个独立的系统进行处理：一个是*编织器（Weaver）*，用于将文学程序转换为适合排版的文档；另一个是*解构器（Tangler）*，用于生成可供编译的源代码。
  我们的文学编程系统是自制的，但其设计受到了诺曼·拉姆齐（Norman Ramsey）的noweb系统的深刻影响。
]

#parec[
  The literate programming metalanguage provides two important features. The first is the ability to mix prose with source code. This feature puts the description of the program on equal footing with its actual source code, encouraging careful design and documentation. Second, the language provides mechanisms for presenting the program code to the reader in an order that is entirely different from the compiler input. Thus, the program can be described in a logical manner. Each named block of code is called a fragment, and each fragment can refer to other fragments by name.
][
  文学编程元语言提供了两个重要特性。
  首先，它允许将文本文字与源代码混合编写。
  这一特性使程序的描述与实际源代码具有同等的重要性，从而鼓励更严谨的设计与文档撰写。
  其次，该语言提供了以完全不同于编译器输入顺序的方式向读者呈现程序代码的机制。
  因此，程序可以以逻辑清晰的方式进行描述。
  每一段具有名称的代码块称为一个代码片（Fragment），每个代码片可以通过名称引用其他片段。
]

#parec[
  As a simple example, consider a function `InitGlobals()` that is responsible for initializing all of a program's global variables: #footnote["The example code in this section is merely illustrative and is not part of `pbrt` itself."]
][
  举个简单的例子，考虑一个函数 `InitGlobals()` 负责初始化程序的所有全局变量 #footnote[本节中的示例代码仅用于说明，并不是 `pbrt` 本身的一部分。] ：
]

```cpp
void InitGlobals() {
    nMarbles = 25.7;
    shoeSize = 13;
    dielectric = true;
}
```

#parec[
  Despite its brevity, this function is hard to understand without any context. Why, for example, can the variable `nMarbles` take on floating-point values? Just looking at the code, one would need to search through the entire program to see where each variable is declared and how it is used in order to understand its purpose and the meanings of its legal values. Although this structuring of the system is fine for a compiler, a human reader would much rather see the initialization code for each variable presented separately, near the code that declares and uses the variable.
][
  尽管这个函数很简短，但是在没有上下文的情况下依旧很难搞懂它。
  例如，为什么变量 `nMarbles` 是浮点值？
  仅凭代码本身，读者需要在整个程序中搜索每个变量的声明和使用位置，才能理解它们的用途及其合法取值的含义。
  尽管这种系统结构对于编译器来说很好，但对于人类读者而言，更希望能在靠近变量声明和使用的位置单独展示每个变量的初始化代码，以便更容易理解程序逻辑。
]

#parec[
  In a literate program, one can instead write `InitGlobals()` like this:
][
  在一个有文字的程序中，我们可以写 `InitGlobals()` 像这样：
]

`<<Function Definitions>>=` #sym.triangle.filled.small.b
```cpp
void InitGlobals() {
    <<Initialize Global Variables>>
}
```


#parec[
  This defines a fragment, called `<<Function Definitions>>`, that contains the definition of the `InitGlobals()` function. The `InitGlobals()` function itself refers to another fragment,`<<Initialize Global Variables>>`. Because the initialization fragment has not yet been defined, we do not know anything about this function except that it will presumably contain assignments to global variables.(However, we can peek ahead by clicking on the plus sign on the right side of it; doing so expands out all the fragment's final code.)
][
  这定义了一个名为 `<<Function Definitions>>` 的代码片，其中包含了 `InitGlobals()` 函数的定义。
  而 `InitGlobals()` 函数本身又引用了另一个片段片 `<<Initialize Global Variables>>` 。由于该初始化代码片尚未被定义，目前我们对其具体内容一无所知，只能推测它应该包含一些对全局变量的赋值操作。
  （但是，我们可以通过单击其右侧的加号来查看；这样做会展开所有片段的最终代码。
  #translator[在线版有加号，pdf没法实现这个效果。]
]

#parec[
  Just having the fragment name is just the right level of abstraction for now, since no variables have been declared yet. When we introduce the global variable `shoeSize` somewhere later in the program, we can then write
][
  目前仅使用代码片名称正好保持了合适的抽象层级，因为此时还没有声明任何变量。
  当我们在程序的后续部分引入全局变量 `shoeSize` 时，就可以这样写：
]

```cpp
// <<Initialize Global Variables>>=  < >=
shoeSize = 13;
``` <fragment-InitializeGlobalVariables-0>

#parec[
  Here we have started to define the contents of `<<Initialize Global Variables>>`. When the literate program is tangled into source code for compilation, the literate programming system will substitute the code `shoeSize = 13`; inside the definition of the `InitGlobals()` function. The symbol after the equals sign indicates that more code will later be added to this fragment. Clicking on it brings you to where that happens.
][
  这里我们开始定义 `<<Initialize Global Variables>>` 代码片的内容。当文学程序源代码被解构（Tangled）成用于编译的源代码时，文学编程系统会将代码 `shoeSize = 13` 替换到 `InitGlobals()` 里面。
  等号后面的符号表示该代码片中后续仍会添加更多代码。
  点击该符号可以跳转到添加更多代码的具体位置。
]

#parec[
  Later in the text, we may define another global variable,`dielectric`, and we can append its initialization to the fragment:
][
  后文我们可能会定义另一个全局变量 `dielectric` ，并将其初始化代码追加到代码片中：
]

```cpp
// <<Initialize Global Variables>>+=
dielectric = true;
```

#parec[
  The `+=` symbol after the fragment name shows that we have added to a previously defined fragment. Further, the symbol links back to the previous place where `<<Initialize Global Variables>>` had code added to it.
][
  片段名称后面的 `+=` 符号表明我们已添加到先前定义的片段。
  此外，符号链接回之前在 `<<Initialize Global Variables>>` 中添加代码的位置，以便读者追溯其初始定义。
]

#parec[
  When tangled, these three fragments turn into the code
][
  当文学程序被解构为源代码时，这三个代码片会合并生成如下代码：
]
```
void InitGlobals() {
    // Initialize Global Variables
    shoeSize = 13;
    dielectric = true;
}
```

#parec[
  In this way, we can decompose complex functions into logically distinct parts, making them much easier to understand. For example, we can write a complicated function as a series of fragments:
][
  通过这种方式，我们可以将复杂的函数分解为逻辑上不同的部分，使它们更容易理解。
  例如，我们可以将一个复杂的函数编写为一系列片段：
]
```cpp
// <<Function Definitions>>+=
void complexFunc(int x, int y, double *values) {
    <<Check validity of arguments>>
    if (x < y) {
        <<Swap x and y>>
    }
    <<Do precomputation before loop>>
    <<Loop through and update values array>>
}
```

#parec[
  Again, the contents of each fragment are expanded inline in `complexFunc()` for compilation. In the document, we can introduce each fragment and its implementation in turn. This decomposition lets us present code a few lines at a time, making it easier to understand. Another advantage of this style of programming is that by separating the function into logical fragments, each with a single and well-delineated purpose, each one can then be written, verified, or read independently. In general, we will try to make each fragment less than 10 lines long.
][
  同样，每个片段的内容都内联到`complexFunc()` 用于编译。
  在文档中，我们可以依次介绍每个片段及其实现。
  这种分解让我们一次只呈现几行代码，从而更容易理解。
  这种编程风格的另一个优点是，通过将函数分成逻辑片段，每个片段都有一个明确的目的，然后每个片段都可以独立写入、验证或读取。
  一般来说，我们会尽量使每个片段的长度小于10行。
]

#parec[
  In some sense, the literate programming system is just an enhanced macro substitution package tuned to the task of rearranging program source code. This may seem like a trivial change, but in fact literate programming is quite different from other ways of structuring software systems.
][
  从某种意义上说，文学编程系统只是一个增强的宏替换包，用于重新排列程序源代码的任务。
  这看起来似乎是一个微不足道的改变，但事实上，文学编程系统与其他构建软件系统有很大不同。
]
