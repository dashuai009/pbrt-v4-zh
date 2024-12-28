#import "../template.typ": parec, translator

== Literate Programming

#parec[
  While creating the TEX typesetting system, Donald Knuth developed a new programming methodology based on a simple but revolutionary idea. To quote Knuth,"let us change our traditional attitude to the construction of programs: Instead of imagining that our main task is to instruct a computer what to do, let us concentrate rather on explaining to human beings what we want a computer to do.” He named this methodology literate programming. This book (including the chapter you are reading now) is a long literate program. This means that in the course of reading this book, you will read the full implementation of the `pbrt` rendering system, not just a high-level description of it.
][
  在创建TEX排版系统时，Donald Knuth 基于一个简单但革命性的想法开发了一种新的编程方法。引用 Knuth 的话说：“让我们改变对程序构建的传统态度：不要想象我们的主要任务是指导计算机做什么，而是让我们集中精力向人类解释我们希望计算机做什么。”他将这种方法命名为“读写编程” 。本书（包括你现在正在阅读的章节）是一个很长的识字节目。这意味着在阅读本书的过程中，您将阅读到 `pbrt` 渲染系统，而不仅仅是它的高级描述。
]

#parec[
  Literate programs are written in a metalanguage that mixes a document formatting language (e.g., TEX or HTML) and a programming language (e.g., C++). Two separate systems process the program: a “weaver” that transforms the literate program into a document suitable for typesetting and a “tangler” that produces source code suitable for compilation. Our literate programming system is homegrown, but it was heavily influenced by Norman Ramsey's noweb system.
][
  文字程序是用混合文档格式化语言（例如， TEX或 HTML）和编程语言（例如，C++）的元语言编写的。两个独立的系统处理该程序：一个“weaver”将文字程序转换为适合排版的文档，另一个“tangler”生成适合编译的源代码。我们的文学编程系统是本土开发的，但它深受 Norman Ramsey 的影响 noweb 系统。
]

#parec[
  The literate programming metalanguage provides two important features. The first is the ability to mix prose with source code. This feature puts the description of the program on equal footing with its actual source code, encouraging careful design and documentation. Second, the language provides mechanisms for presenting the program code to the reader in an order that is entirely different from the compiler input. Thus, the program can be described in a logical manner. Each named block of code is called a fragment, and each fragment can refer to other fragments by name.
][
  文学编程元语言提供了两个重要的功能。第一个是将散文与源代码混合的能力。此功能使程序的描述与其实际源代码处于同等地位，鼓励仔细的设计和文档记录。其次，该语言提供了以与编译器输入完全不同的顺序向读者呈现程序代码的机制。因此，可以用逻辑方式描述程序。每个命名的代码块称为一个片段，每个片段可以通过名称引用其他片段。
]

#parec[
  As a simple example, consider a function `InitGlobals()` that is responsible for initializing all of a program's global variables: #footnote["The example code in this section is merely illustrative and is not part of `pbrt` itself."]
][
  作为一个简单的例子，考虑一个函数 `InitGlobals()` 负责初始化程序的所有全局变量：#footnote["本节中的示例代码仅用于说明，并不是 `pbrt` 本身的一部分。"]
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
  尽管很简短，但如果没有任何上下文，这个函数就很难理解。例如，为什么变量可以 `nMarbles` 接受浮点值？仅看代码，就需要搜索整个程序，看看每个变量是在哪里声明的以及如何使用的，才能理解其目的及其合法值的含义。尽管这种系统结构对于编译器来说很好，但人类读者更愿意看到每个变量的初始化代码单独呈现在声明和使用变量的代码附近。
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
  这定义了一个名为 `<<Function Definitions>>` 的片段，其中包含 `InitGlobals()` 功能。这 `InitGlobals()` 函数本身引用另一个片段，`<<Initialize Global Variables>>`。因为初始化片段尚未定义，所以我们对这个函数一无所知，除了它可能包含对全局变量的赋值之外。（但是，我们可以通过单击其右侧的加号来查看；这样做会展开所有片段的最终代码。#translator[在线版有加号，pdf没法实现这个效果]）
]

#parec[
  Just having the fragment name is just the right level of abstraction for now, since no variables have been declared yet. When we introduce the global variable `shoeSize` somewhere later in the program, we can then write
][
  目前，仅具有片段名称就是正确的抽象级别，因为尚未声明任何变量。当我们引入全局变量时 `shoeSize` 在程序稍后的某个地方，我们可以编写
]


```cpp
// <<Initialize Global Variables>>=  < >=
shoeSize = 13;
``` <fragment-InitializeGlobalVariables-0>


#parec[
  Here we have started to define the contents of `<<Initialize Global Variables>>`. When the literate program is tangled into source code for compilation, the literate programming system will substitute the code `shoeSize = 13`; inside the definition of the `InitGlobals()` function. The symbol after the equals sign indicates that more code will later be added to this fragment. Clicking on it brings you to where that happens.
][
  这里我们开始定义`<<Initialize Global Variables>>`的内容。当文学程序源代码编译时，文学编程系统将代码 `shoeSize = 13` 替换到`InitGlobals()`里面。这等号后面的符号表示稍后将添加更多代码到此片段。单击它会将您带到实际添加的地方。
]

#parec[
  Later in the text, we may define another global variable,`dielectric`, and we can append its initialization to the fragment:
][
  在本文后面，我们可以定义另一个全局变量，`dielectric` ，我们可以将其初始化附加到片段中：
]

```cpp
// <<Initialize Global Variables>>+=
dielectric = true;
```

#parec[
  The `+=` symbol after the fragment name shows that we have added to a previously defined fragment. Further, the symbol links back to the previous place where `<<Initialize Global Variables>>` had code added to it.
][
  片段名称后面的`+=`符号表明我们已添加到先前定义的片段。此外，符号链接回之前在 `<<Initialize Global Variables>>` 中添加代码的位置。
]

#parec[
  When tangled, these three fragments turn into the code
][
  当纠缠在一起时，这三个片段变成了代码
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
  通过这种方式，我们可以将复杂的函数分解为逻辑上不同的部分，使它们更容易理解。例如，我们可以将一个复杂的函数编写为一系列片段：
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
  同样，每个片段的内容都内联到`complexFunc()` 用于编译。在文档中，我们可以依次介绍每个片段及其实现。这种分解让我们一次只呈现几行代码，从而更容易理解。这种编程风格的另一个优点是，通过将函数分成逻辑片段，每个片段都有一个明确的目的，然后每个片段都可以独立写入、验证或读取。一般来说，我们会尽量使每个片段的长度小于10行。
]

#parec[
  In some sense, the literate programming system is just an enhanced macro substitution package tuned to the task of rearranging program source code. This may seem like a trivial change, but in fact literate programming is quite different from other ways of structuring software systems.
][
  从某种意义上说，文学编程系统只是一个增强的宏替换包，用于重新排列程序源代码的任务。这看起来似乎是一个微不足道的改变，但事实上，文学编程系统与其他构建软件系统有很大不同。
]
