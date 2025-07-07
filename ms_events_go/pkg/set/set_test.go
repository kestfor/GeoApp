package set

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestSet_Add(t *testing.T) {
	set := make(IntSet)
	set.Add(1)
	set.Add(2)
	set.Add(1)
	assert.Equalf(t, set.Size(), 2, "Size should be 2")
}

func TestSet_Remove(t *testing.T) {
	set := make(IntSet)
	set.Add(1)
	set.Add(2)
	set.Remove(2)
	assert.Equalf(t, set.Size(), 1, "Size should be 1")
}

func TestSet_Contains(t *testing.T) {
	set := make(IntSet)
	set.Add(1)
	set.Add(2)
	assert.Truef(t, set.Contains(1), "Set contains 1 must be true")
	assert.Truef(t, set.Contains(2), "Set contains 2 must be true")
	assert.Falsef(t, set.Contains(3), "Set contains 3 must be false")
}

func TestSet_Union(t *testing.T) {
	set1 := make(IntSet)
	set1.Add(1)
	set1.Add(2)
	set2 := make(IntSet)
	set2.Add(1)
	set2.Add(3)
	union := set1.Union(set2)
	assert.Equalf(t, 3, union.Size(), "Set union size must be equal to 3")
}

func TestSet_Intersection(t *testing.T) {
	set1 := make(IntSet)
	set1.Add(1)
	set1.Add(2)
	set2 := make(IntSet)
	set2.Add(1)
	set2.Add(3)
	intersection := set1.Intersection(set2)
	assert.Equalf(t, 1, intersection.Size(), "Set intersection size must be equal to 1")
}
