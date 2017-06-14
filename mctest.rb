#!/usr/bin/env ruby

require 'memcached'
require 'ruby-progressbar'

client = Memcached.new('mcrouter-provisioner:5000')
client = Memcached.new('10.206.7.200:5000')

TOTAL=ENV.fetch('TOTAL', 500).to_i


def generate_key(number)
  charset = Array('A'..'Z') + Array('a'..'z')
  Array.new(number) { charset.sample }.join
end

KEYS = {}
FOUND = []
WRITE_ERRORS = []
READ_ERRORS = []

write_bar = ProgressBar.create(title: "writes", total: TOTAL)
read_bar = ProgressBar.create(title: "reads", total: TOTAL)

# pre-generate all the keys to make timing easier
1.upto(TOTAL) { |i| KEYS[generate_key(20)] = rand(1000000000).to_s }

write_begin = (Time.now.to_f * 1000)
KEYS.each do |key, value|
	begin
	client.set(key, value)
	rescue => e
	WRITE_ERRORS << "write missed with #{e.message}"
	end
	write_bar.increment
end
write_end = (Time.now.to_f * 1000)

read_begin = (Time.now.to_f * 1000)
KEYS.keys.each do |key|
	begin
	FOUND << client.get(key)
	rescue => e
	READ_ERRORS << "read failed #{e.message}"
	end
	read_bar.increment
end
read_end = (Time.now.to_f * 1000)

total_read = (read_end - read_begin)
total_write = (write_end - write_begin)

puts "***** RESULTS *****"
puts "found #{FOUND.count} keys out of #{TOTAL} attempted writes"
puts "there were #{WRITE_ERRORS.count} total write misses"
puts "there were #{READ_ERRORS.count} total read misses"
puts "total time writing #{total_write}ms avg per op: #{(total_write / TOTAL).round(2)}ms"
puts "total time reading #{total_read}ms avg per op: #{(total_read / TOTAL).round(2)}ms"
