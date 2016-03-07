#! /bin/sh

mkdir -p $1/Foo
cd $1
echo "module Foo.First where" > Foo/First.hs
echo "module Foo.Second where" > Foo/Second.hs
echo "Foo.First\nFoo.Second" > filelist
