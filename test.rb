# encoding: utf-8

$:.push("./lib")
require "command-builder"

cmd = CommandBuilder::new(:jpegoptim)
cmd << :preserve
cmd << :p
cmd << "file.jpg"
cmd << ["1 1.jpg", "2.jpg"]
cmd.arg(:max, 3)
cmd.arg(:m, 3)
cmd[:other] = "value"
cmd[:o] = "another '\" value"
puts cmd

puts cmd[:max].inspect

cmd.reset!
puts cmd
