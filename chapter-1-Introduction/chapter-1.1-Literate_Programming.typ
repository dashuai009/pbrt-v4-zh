#import "../template.typ": parec, translator, ez_caption

== #ez_caption[Literate Programming][文学编程]
<Literate-Programming>

#parec[
  While creating the T#sub[E]X typesetting system, Donald Knuth developed a new programming methodology based on a simple but revolutionary idea. To quote Knuth, “let us change our traditional attitude to the construction of programs: Instead of imagining that our main task is to instruct a computer what to do, let us concentrate rather on explaining to human beings what we want a computer to do.” He named this methodology _literate programming_. This book (including the chapter you are reading now) is a long literate program. This means that in the course of reading this book, you will read the full implementation of the `pbrt` rendering system, not just a high-level description of it.
][
  在开发 T#sub[E]X 排版系统时，Donald Knuth 提出了一种新的编程方法，其出发点是一个简单却具有革命性的想法。用 Knuth 的话说：“让我们改变构建程序时的传统态度：与其认为我们的主要任务是指示计算机做什么，不如专注于向人解释我们希望计算机做什么。”他将这种方法称为文学编程。本书（包括你正在阅读的这一章）就是一个篇幅很长的文学程序。这意味着，阅读本书时，你将读到 `pbrt` 渲染系统的完整实现，而不只是对它的高层描述。
]

#parec[
  Literate programs are written in a metalanguage that mixes a document formatting language (e.g., T#sub[E]X or HTML) and a programming language (e.g., C++). Two separate systems process the program: a “weaver” that transforms the literate program into a document suitable for typesetting and a “tangler” that produces source code suitable for compilation. Our literate programming system is homegrown, but it was heavily influenced by Norman Ramsey's `noweb` system.
][
  文学程序用一种元语言编写，其中混合了文档排版语言（如 T#sub[E]X 或 HTML）与编程语言（如 C++）。两个独立的系统负责处理这种程序：“编织器”将文学程序转换为适合排版的文档，“代码抽取器”则生成可供编译的源代码。我们的文学编程系统是自行开发的，但深受 Norman Ramsey 的 `noweb` 系统影响。
]

#parec[
  The literate programming metalanguage provides two important features. The first is the ability to mix prose with source code. This feature puts the description of the program on equal footing with its actual source code, encouraging careful design and documentation. Second, the language provides mechanisms for presenting the program code to the reader in an order that is entirely different from the compiler input. Thus, the program can be described in a logical manner. Each named block of code is called a _fragment_, and each fragment can refer to other fragments by name.
][
  文学编程的元语言提供了两项重要功能。第一，它允许将文字说明与源代码交织在一起，使程序说明与实际源代码处于同等地位，从而鼓励仔细设计程序并编写文档。第二，它允许按与编译器输入完全不同的顺序向读者呈现程序代码。因此，我们可以按照合乎逻辑的方式讲解程序。每个具名的代码块称为一个代码片段，每个片段都可以通过名称引用其他片段。
]

#parec[
  As a simple example, consider a function `InitGlobals()` that is responsible for initializing all of a program's global variables: #footnote[The example code in this section is merely illustrative and is not part of `pbrt` itself.]
][
  举一个简单的例子，考虑负责初始化程序所有全局变量的函数 `InitGlobals()`：#footnote[本节示例代码仅用于说明，并非 `pbrt` 本身的一部分。]
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
  这个函数虽然简短，但没有上下文就很难理解。例如，为什么变量 `nMarbles` 可以取浮点值？仅看这段代码，我们还得搜索整个程序，找出每个变量的声明及其用法，才能理解它的用途以及合法取值的含义。这样的系统组织方式适合编译器，但人类读者更希望分别看到各个变量的初始化代码，而且这些代码应靠近相应变量的声明和使用位置。
]

#parec[
  In a literate program, one can instead write `InitGlobals()` like this:
][
  在文学程序中，我们可以将 `InitGlobals()` 改写如下：
]

#block(sticky: true)[#raw("<<Function Definitions>>=") #link(<fragment-FunctionDefinitions-1>)[▼]] <fragment-FunctionDefinitions-0>
```cpp
void InitGlobals() {
    <<Initialize Global Variables>>
}
```


#parec[
  This defines a fragment, called `<<Function Definitions>>`, that contains the definition of the `InitGlobals()` function. The `InitGlobals()` function itself refers to another fragment, `<<Initialize Global Variables>>`. Because the initialization fragment has not yet been defined, we do not know anything about this function except that it will presumably contain assignments to global variables. (However, we can peek ahead by clicking on the plus sign on the right side of it; doing so expands out all the fragment's final code.)
][
  这里定义了名为 `<<Function Definitions>>` 的代码片段，其中包含 `InitGlobals()` 函数的定义。`InitGlobals()` 函数本身又引用了另一个片段 `<<Initialize Global Variables>>`。由于初始化片段尚未定义，我们对这个函数一无所知，只能推测它会包含对全局变量的赋值。（不过，可以单击其右侧的加号提前查看；这会展开该片段最终包含的全部代码。）#translator[这里的加号展开功能指英文原书网站中的交互功能。]
]

#parec[
  Just having the fragment name is just the right level of abstraction for now, since no variables have been declared yet. When we introduce the global variable `shoeSize` somewhere later in the program, we can then write
][
  目前尚未声明任何变量，因此只列出片段名称，抽象程度恰到好处。之后在程序的某处引入全局变量 `shoeSize` 时，我们便可以写：
]

#block(sticky: true)[#raw("<<Initialize Global Variables>>=") #link(<fragment-InitializeGlobalVariables-1>)[▼]] <fragment-InitializeGlobalVariables-0>
```cpp
shoeSize = 13;
```

#parec[
  Here we have started to define the contents of `<<Initialize Global Variables>>`. When the literate program is tangled into source code for compilation, the literate programming system will substitute the code `shoeSize = 13;` inside the definition of the `InitGlobals()` function. The ▼ symbol after the equals sign indicates that more code will later be added to this fragment. Clicking on it brings you to where that happens.
][
  这里开始定义 `<<Initialize Global Variables>>` 的内容。将文学程序抽取为可供编译的源代码时，文学编程系统会把代码 `shoeSize = 13;` 代入 `InitGlobals()` 函数的定义。等号后的 ▼ 符号表示，后面还会向这个片段添加代码。单击该符号即可跳转到继续添加代码的位置。
]

#parec[
  Later in the text, we may define another global variable, `dielectric`, and we can append its initialization to the fragment:
][
  后文中，我们可能还会定义全局变量 `dielectric`，并将它的初始化代码追加到该片段：
]

#block(sticky: true)[#raw("<<Initialize Global Variables>>+=") #link(<fragment-InitializeGlobalVariables-0>)[▲]] <fragment-InitializeGlobalVariables-1>
```cpp
dielectric = true;
```

#parec[
  The `+=` symbol after the fragment name shows that we have added to a previously defined fragment. Further, the ▲ symbol links back to the previous place where `<<Initialize Global Variables>>` had code added to it.
][
  片段名称后的 `+=` 符号表示，我们向一个已经定义的片段追加了代码。此外，▲ 符号还链接到上一次向 `<<Initialize Global Variables>>` 添加代码的位置。
]

#parec[
  When tangled, these three fragments turn into the code
][
  经过代码抽取，这三个片段会生成以下代码：
]
```cpp
void InitGlobals() {
    // Initialize Global Variables
    shoeSize = 13;
    dielectric = true;
}
```

#parec[
  In this way, we can decompose complex functions into logically distinct parts, making them much easier to understand. For example, we can write a complicated function as a series of fragments:
][
  这样就可以将复杂函数拆分成逻辑上相互独立的部分，使其更容易理解。例如，我们可以将一个复杂函数写成一系列片段：
]
#block(sticky: true)[#raw("<<Function Definitions>>+=") #link(<fragment-FunctionDefinitions-0>)[▲]] <fragment-FunctionDefinitions-1>
```cpp
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
  同样，编译时各片段的内容会在 `complexFunc()` 中就地展开。在文档中，我们可以依次介绍各片段及其实现。这样的拆分让我们每次只呈现几行代码，便于理解。这种编程方式的另一个优点是：函数被拆分为逻辑片段，每个片段都只有一个明确且界限清楚的用途，因此可以独立编写、验证或阅读。一般来说，我们会尽量让每个片段少于 10 行。
]

#parec[
  In some sense, the literate programming system is just an enhanced macro substitution package tuned to the task of rearranging program source code. This may seem like a trivial change, but in fact literate programming is quite different from other ways of structuring software systems.
][
  从某种意义上说，文学编程系统只是一个增强的宏替换工具包，专门用于重新组织程序源代码。这看似只是微小的改变，实际上，文学编程与其他软件系统组织方式有很大不同。
]
