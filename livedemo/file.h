

#nep1

#define foo 1
#define bar 12


#def WXDLLIMPEXP_CORE


#discardablePrefix Set

template <typename T>

class WXDLLIMPEXP_CORE Foo {
public:
  T value;
  T GetValue() { return value; }
  T& SetValue(int x) { field = x; return &field; }
  Foo(T x) {}

  ~Foo() {}

  bool operator ==(Foo<T>& const other) const;
  bool operator !=(Foo& other);
};

