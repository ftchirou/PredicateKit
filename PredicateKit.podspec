#  Copyright 2020 Faiçal Tchirou
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
#  documentation files (the "Software"), to deal in the Software without restriction, including without limitation
#  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
#  to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all copies or substantial portions of
#  the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
#  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
#  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
#  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Pod::Spec.new do |spec|
  spec.name = "PredicateKit"
  spec.version = "1.10.0"
  spec.summary = "Write expressive and type-safe predicates for CoreData using key-paths, comparisons and logical operators, literal values, and functions."
  spec.description = <<-DESC
  PredicateKit allows Swift developers to write expressive and type-safe predicates for CoreData using key-paths, comparisons and logical operators, literal values, and functions.
                   DESC
  spec.homepage = "https://github.com/ftchirou/PredicateKit"
  spec.license = { :type => "MIT", :file => "LICENSE.md" }
  spec.author = { "Faiçal Tchirou" => "ftchirou@gmail.com" }
  spec.ios.deployment_target = "11.0"
  spec.osx.deployment_target = "10.15"
  spec.watchos.deployment_target = "5.0"
  spec.tvos.deployment_target = "11.0"
  spec.source = { :git => "https://github.com/ftchirou/PredicateKit.git", :tag => "#{spec.version}" }
  spec.source_files = "PredicateKit/**/*.swift"
  spec.swift_versions = ['5.1', '5.2', '5.3']
end
