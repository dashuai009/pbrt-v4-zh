#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original collapsed panels][原网页折叠面板中的补充代码]]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#fragbit-965")[`fragbit-965`]]
#block(breakable: false)[
```cpp
using TaggedPointer::TaggedPointer;
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#fragbit-966")[`fragbit-966`]]
#block(breakable: false)[
```cpp
if (primMediumInterface && primMediumInterface->IsMediumTransition())
    mediumInterface = primMediumInterface;
else
    medium = rayMedium;
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#fragbit-967")[`fragbit-967`]]
#block(breakable: false)[
```cpp
GeometricPrimitive(Shape shape, Material material, Light areaLight,
                   const MediumInterface &mediumInterface,
                   FloatTexture alpha = nullptr);
Bounds3f Bounds() const;
pstd::optional<ShapeIntersection> Intersect(const Ray &r, Float tMax) const;
bool IntersectP(const Ray &r, Float tMax) const;
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#fragbit-976")[`fragbit-976`]]
#block(breakable: false)[
```cpp
Bounds3f Bounds() const;
pstd::optional<ShapeIntersection> Intersect(const Ray &r, Float tMax) const;
bool IntersectP(const Ray &r, Float tMax) const;
SimplePrimitive(Shape shape, Material material);
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#fragbit-978")[`fragbit-978`]]
#block(breakable: false)[
```cpp
pstd::optional<ShapeIntersection> Intersect(const Ray &r, Float tMax) const;
bool IntersectP(const Ray &r, Float tMax) const;
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#fragbit-982")[`fragbit-982`]]
#block(breakable: false)[
```cpp
AnimatedPrimitive(Primitive primitive,
                  const AnimatedTransform &renderFromPrimitive);
pstd::optional<ShapeIntersection> Intersect(const Ray &r, Float tMax) const;
bool IntersectP(const Ray &r, Float tMax) const;
```
]
