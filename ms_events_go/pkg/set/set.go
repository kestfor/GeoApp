package set

type emptyStruct struct{}
type Set[T comparable] map[T]emptyStruct
type IntSet = Set[int]
type FloatSet = Set[float64]
type StringSet = Set[string]

func NewSet[T comparable]() Set[T] {
	return make(Set[T])
}

func (s Set[T]) Add(item T) {
	s[item] = emptyStruct{}
}

func (s Set[T]) Remove(item T) {
	delete(s, item)
}

func (s Set[T]) Contains(item T) bool {
	_, exists := s[item]
	return exists
}

func (s Set[T]) Size() int {
	return len(s)
}

func (s Set[T]) Clear() {
	clear(s)
}

func (s Set[T]) Intersection(other Set[T]) Set[T] {
	intersection := NewSet[T]()
	for item := range s {
		if other.Contains(item) {
			intersection.Add(item)
		}
	}
	return intersection
}

func (s Set[T]) Union(other Set[T]) Set[T] {
	union := NewSet[T]()
	for item := range s {
		union.Add(item)
	}
	for item := range other {
		union.Add(item)
	}
	return union
}
