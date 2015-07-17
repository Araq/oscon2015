
#def WXDLLIMPEXP_CORE

#define constantA 1
#define constantB 2


namespace Name {



template <typename T>
class  WXDLLIMPEXP_CORE Foo {
public:
  T value = {. NimConstant + 78 shr 9 .};
  T GetValue() { return value; }
  T& SetValue(int x) { field = x; return &field; }

  Foo(T x): field(x) {}
  ~Foo() {}

  bool operator==(Foo<T>& const other) const;
  bool operator!=(Foo other);
};

}

