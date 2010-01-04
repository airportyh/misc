require 'hotcocoa'
include HotCocoa
application do |app|
  win = window :size => [100,50]
  b = button :title => 'Hello'
  b.click { puts 'World!' }
  win << b
end