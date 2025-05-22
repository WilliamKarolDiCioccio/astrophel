# ✨ Astrophel

Astrophel began as a **learning project** aimed at building a simple programming
language. The original goal was straightforward: explore compiler construction
and gain hands-on experience with language design, parsing, and execution.

Things escalated quickly as I dove deeper into the books and YouTube series that
inspired this project:

- 🎥
  [Tyler Laceby’s "How to Build a Programming Language" series](https://www.youtube.com/watch?v=8VB5TY1sIRo&list=PL_2VhOvlMk4UHGqYCLWc6GO8FaPl8fQTh)
- 📚 _Compilers: Principles, Techniques, and Tools_ by Alfred Aho, Monica Lam,
  Ravi Sethi, and Jeffrey Ullman (a.k.a. "The Dragon Book")

And here I am, writing a compiler. For real! For production! Will I be able to
overcome this daunting challenge? Stay tuned because we're going to discover it
quite soon. Fingers crossed 🤞!

---

## 🚀 What is Astrophel?

Astrophel is a **low-level, memory-safe programming language** focused on
**readability and explicit behavior**. It enforces safety and clarity by relying
heavily on **code generation** while giving developers fine-grained control over
execution.

Key design choices:

- **Readable Syntax**: Uses full-length keywords to avoid ambiguity and improve
  clarity.
- **Strong Typing**: Supports explicit type annotations and compile-time safety
  checks.
- **Explicit memory management:** Uses `allocate` and `deallocate` for manual
  memory control, with strict compile-time checks to ensure safety.
- **No implicit conversions:** Prevents unintended behavior and enforces strict
  typing.
- **Annotations for safety and behavior control:** Inspired by Dart, annotations
  like `@safe`, `@abstract`, and `@implement(...)` improve code clarity.
- **Powerful module system:** A JS-like module system allows fine-grained
  control over what to import/export.
- **Strong concurrency model:** Supports built-in multi-threaded and parallel
  execution.
- **Storage Specifiers:**
  - `global` (equivalent to `static` in C++)
  - `thread_local` (thread-specific storage)
- **Mutability Specifiers:**
  - `constexpr` (evaluated at compile-time, unifying `constinit` and `constexpr`
    in C++)
  - `const` (immutable at runtime)
  - `latevar` (initialized later but and mutable afterward)
  - `var` (mutable variable)
- **Structured Data Types:**
  - `struct`: A data structure that cannot have methods.
  - `class`: A full-featured object-like structure that supports methods.
  - `union`: Allows multiple members sharing the same memory space.
- **Templates & Lambdas**: Provides generic programming capabilities without
  unnecessary complexity.
- **Interfaces Instead of Inheritance**: Uses a trait-like system, where
  `interface` defines expected behavior for types.
- **Enumerations**: Defines named constants using `enum`.

---

## 🧐 Why Dart?

The initial compiler (a.k.a. "legacy compiler") is written in **Dart**. If
Astrophel ever becomes something serious, the long-term plan is to transition to
a **self-hosted compiler**.

You might wonder: _Why Dart?_ While it may not be the first choice for compiler
development, it offers several advantages:

- **Good performance for command-line tools**
- **Strong standard library** (string manipulation, file handling, collections)
- **Fast development cycles**
- **Simple and readable syntax**

Other languages I considered include C++, Haskell, and Go, but Dart provides the
best balance of ease of use and power for the initial phase. Performance
optimizations will be addressed in the self-hosted version.

---

## 🌌 Language Features

### 📌 Variables & Constants

Astrophel variables default to **immutable**. Mutability and storage specifiers
are explicitly declared:

```astro
const i32 x = 10;
global constexpr i32[4] secretList = [1, 2, 3, 4];
```

### 📌 Structs & Classes

```astro
template <T>
struct Point {
  const T x;
  const T y;
  constructor() : x = 0, y = 0 : {}
}

class Thingamajig {
  union {
    const i32 x, r;
  }
  constructor() { print("Created!"); }
  destructor() { print("Destroyed!"); }
}
```

### 📌 Interfaces (Rust-like Traits)

```astro
interface Actionable {
  function doSomething(i32 n) -> void {}
  parallel function _doTheThing(String msg) -> void {}
}

implement Actionable for Thingamajig {
  function doSomething(i32 n = 0) -> void {
    for (i = 0; i < n; i++) {
      print("Did something!");
    }
  }
}
```

### 📌 Memory Management

```astro
const Pair<i32, f32> *secretValue = allocate(Pair(0, 0.0));
deallocate(secretValue);
```

### 📌 Modules & Imports

Modules follow a **JS-like system** with `import` and `export` statements.

```astro
// src/core/math.astro
export func square(i32 x) -> i32 {
    return x * x;
}
```

```astro
// main.astro
import src.core.math as math;

func main() -> void {
    var result = math.square(5);
    print(result); // 25
}
```

### 📌 Concurrency & Parallelism

Astrophel integrates **safe multithreading** without requiring extra libraries.
Three execution models are supported:

```astro
async func fetchData() -> void { ... } // Single-threaded async
parallel func heavyTask() -> void { ... } // Multi-threaded parallel execution
func standardTask() -> void { ... } // Standard execution
```

### 📌 Templates (Generics)

Astrophel provides **C++-inspired templates** for generic programming.

```astro
[@templated(T)]
func identity(T value) -> T {
    return value;
}

var num = identity(42);   // Inferred as i32
var text = identity("Hi"); // Inferred as string
```

Templates support **concepts-like constraints** for compile-time checks.

---

## 🔮 Future Plans

- Advanced metaprogramming (akin to C++'s concepts).
- Improved compile-time optimizations for safety.

---

## 🔥 Getting Started

To try Astrophel, you'll need:

- Dart SDK (for the compiler)
- A basic understanding of language concepts

More documentation and installation instructions coming soon!

---

## ⚖ License

**Astrophel** is open-source and released under the **MIT License**.
Contributions are welcome!
