# encoding: utf-8

require "./jpeg"

cmd = CommandBuilder::new(:jpegoptim)
cmd << :preserve
cmd << :p
cmd << "file.jpg"
cmd << ["1.jpg", "2.jpg"]
cmd.arg(:max, 3)
cmd.arg(:m, 3)
cmd[:other] = "value"
cmd[:o] = "another '\" value"
puts cmd

puts cmd[:max].inspect
